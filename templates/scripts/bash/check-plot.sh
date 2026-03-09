#!/usr/bin/env bash
# 줄거리 전개의 일관성과 연속성 검사

set -e

# 공통 함수 로드
SCRIPT_DIR=$(dirname "$0")
source "$SCRIPT_DIR/common.sh"

# 체크리스트 모드 확인
CHECKLIST_MODE=false
if [ "$1" = "--checklist" ]; then
    CHECKLIST_MODE=true
fi

# 현재 스토리 디렉토리 가져오기
STORY_DIR=$(get_current_story)

if [ -z "$STORY_DIR" ]; then
    echo "오류: 스토리 프로젝트를 찾을 수 없습니다" >&2
    exit 1
fi

# 파일 경로
PLOT_TRACKER="$STORY_DIR/spec/tracking/plot-tracker.json"
OUTLINE="$STORY_DIR/outline.md"
PROGRESS="$STORY_DIR/progress.json"

# 필수 파일 확인
check_required_files() {
    local missing=false

    if [ ! -f "$PLOT_TRACKER" ]; then
        echo "⚠️  줄거리 추적 파일을 찾을 수 없어 생성 중..." >&2
        mkdir -p "$STORY_DIR/spec/tracking"
        # 템플릿 복사
        if [ -f "$SCRIPT_DIR/../../templates/tracking/plot-tracker.json" ]; then
            cp "$SCRIPT_DIR/../../templates/tracking/plot-tracker.json" "$PLOT_TRACKER"
        else
            echo "오류: 템플릿 파일을 찾을 수 없습니다" >&2
            exit 1
        fi
    fi

    if [ ! -f "$OUTLINE" ]; then
        echo "오류: 챕터 개요를 찾을 수 없습니다 (outline.md)" >&2
        echo "먼저 /outline 명령어를 사용하여 개요를 작성하세요" >&2
        exit 1
    fi
}

# 현재 진행도 읽기
get_current_progress() {
    if [ -f "$PROGRESS" ]; then
        CURRENT_CHAPTER=$(jq -r '.statistics.currentChapter // 1' "$PROGRESS")
        CURRENT_VOLUME=$(jq -r '.statistics.currentVolume // 1' "$PROGRESS")
    else
        CURRENT_CHAPTER=$(jq -r '.currentState.chapter // 1' "$PLOT_TRACKER")
        CURRENT_VOLUME=$(jq -r '.currentState.volume // 1' "$PLOT_TRACKER")
    fi
}

# 줄거리 정합성 분석
analyze_plot_alignment() {
    echo "📊 줄거리 전개 검사 보고서"
    echo "━━━━━━━━━━━━━━━━━━━━"

    # 현재 진행도
    echo "📍 현재 진행: 제${CURRENT_CHAPTER}장 (제${CURRENT_VOLUME}권)"

    # 줄거리 추적 데이터 읽기
    if [ -f "$PLOT_TRACKER" ]; then
        MAIN_PLOT=$(jq -r '.plotlines.main.currentNode // "미설정"' "$PLOT_TRACKER")
        PLOT_STATUS=$(jq -r '.plotlines.main.status // "unknown"' "$PLOT_TRACKER")
        echo "📖 메인 스토리 진행: $MAIN_PLOT [$PLOT_STATUS]"

        # 완료된 노드
        COMPLETED_COUNT=$(jq '.plotlines.main.completedNodes | length' "$PLOT_TRACKER")
        echo ""
        echo "✅ 완료된 노드: ${COMPLETED_COUNT}개"
        jq -r '.plotlines.main.completedNodes[]? | "  • " + .' "$PLOT_TRACKER" 2>/dev/null || true

        # 다가오는 노드
        UPCOMING_COUNT=$(jq '.plotlines.main.upcomingNodes | length' "$PLOT_TRACKER")
        if [ "$UPCOMING_COUNT" -gt 0 ]; then
            echo ""
            echo "→ 다음 노드:"
            jq -r '.plotlines.main.upcomingNodes[0:3][]? | "  • " + .' "$PLOT_TRACKER" 2>/dev/null || true
        fi
    fi
}

# 복선 상태 확인
check_foreshadowing() {
    echo ""
    echo "🎯 복선 추적"
    echo "───────────"

    if [ -f "$PLOT_TRACKER" ]; then
        # 복선 집계
        TOTAL_FORESHADOW=$(jq '.foreshadowing | length' "$PLOT_TRACKER")
        ACTIVE_FORESHADOW=$(jq '[.foreshadowing[] | select(.status == "active")] | length' "$PLOT_TRACKER")
        RESOLVED_FORESHADOW=$(jq '[.foreshadowing[] | select(.status == "resolved")] | length' "$PLOT_TRACKER")

        echo "통계: 총 ${TOTAL_FORESHADOW}개, 활성 ${ACTIVE_FORESHADOW}개, 회수됨 ${RESOLVED_FORESHADOW}개"

        # 처리 대기 중인 복선 목록
        if [ "$ACTIVE_FORESHADOW" -gt 0 ]; then
            echo ""
            echo "⚠️ 처리 대기 복선:"
            jq -r '.foreshadowing[] | select(.status == "active") |
                "  • " + .content + " (제" + (.planted.chapter | tostring) + "장에서 배치)"' \
                "$PLOT_TRACKER" 2>/dev/null || true
        fi

        # 만료된 복선 확인 (30챕터 이상 미처리)
        OVERDUE=$(jq --arg current "$CURRENT_CHAPTER" '
            [.foreshadowing[] |
             select(.status == "active" and .planted.chapter and
                    (($current | tonumber) - .planted.chapter) > 30)] |
            length' "$PLOT_TRACKER")

        if [ "$OVERDUE" -gt 0 ]; then
            echo ""
            echo "⚠️ 경고: ${OVERDUE}개의 복선이 30챕터 이상 미처리"
        fi
    fi
}

# 갈등 전개 확인
check_conflicts() {
    echo ""
    echo "⚔️ 갈등 추적"
    echo "───────────"

    if [ -f "$PLOT_TRACKER" ]; then
        ACTIVE_CONFLICTS=$(jq '.conflicts.active | length' "$PLOT_TRACKER")

        if [ "$ACTIVE_CONFLICTS" -gt 0 ]; then
            echo "현재 활성 갈등: ${ACTIVE_CONFLICTS}개"
            jq -r '.conflicts.active[] |
                "  • " + .name + " [" + .intensity + "]"' \
                "$PLOT_TRACKER" 2>/dev/null || true
        else
            echo "현재 활성 갈등 없음"
        fi
    fi
}

# 제안 생성
generate_suggestions() {
    echo ""
    echo "💡 제안"
    echo "───────"

    # 현재 챕터 기반 제안
    if [ "$CURRENT_CHAPTER" -lt 10 ]; then
        echo "• 초반 10장은 매우 중요합니다. 독자를 끌어당길 충분한 훅이 있는지 확인하세요"
    elif [ "$CURRENT_CHAPTER" -lt 30 ]; then
        echo "• 첫 번째 소규모 클라이맥스에 접근 중입니다. 갈등이 충분히 격렬한지 확인하세요"
    elif [ "$((CURRENT_CHAPTER % 60))" -gt 50 ]; then
        echo "• 권말에 접근 중입니다. 클라이맥스와 서스펜스 설정을 준비하세요"
    fi

    # 복선 상태 기반 제안
    if [ "$ACTIVE_FORESHADOW" -gt 5 ]; then
        echo "• 활성 복선이 많습니다. 다음 몇 장에서 일부를 회수하는 것을 고려하세요"
    fi

    # 갈등 상태 기반 제안
    if [ "$ACTIVE_CONFLICTS" -eq 0 ] && [ "$CURRENT_CHAPTER" -gt 5 ]; then
        echo "• 현재 활성 갈등이 없습니다. 새로운 갈등 포인트 도입을 고려하세요"
    fi
}

# 체크리스트 형식 출력 생성
output_checklist() {
    # 필수 파일 확인 (묵음)
    check_required_files > /dev/null 2>&1 || true

    # 현재 진행도 가져오기
    get_current_progress

    # 데이터 수집
    local main_plot="미설정"
    local plot_status="unknown"
    local completed_count=0
    local upcoming_count=0
    local total_foreshadow=0
    local active_foreshadow=0
    local resolved_foreshadow=0
    local overdue_foreshadow=0
    local active_conflicts=0

    if [ -f "$PLOT_TRACKER" ]; then
        main_plot=$(jq -r '.plotlines.main.currentNode // "미설정"' "$PLOT_TRACKER")
        plot_status=$(jq -r '.plotlines.main.status // "unknown"' "$PLOT_TRACKER")
        completed_count=$(jq '.plotlines.main.completedNodes | length' "$PLOT_TRACKER")
        upcoming_count=$(jq '.plotlines.main.upcomingNodes | length' "$PLOT_TRACKER")

        total_foreshadow=$(jq '.foreshadowing | length' "$PLOT_TRACKER")
        active_foreshadow=$(jq '[.foreshadowing[] | select(.status == "active")] | length' "$PLOT_TRACKER")
        resolved_foreshadow=$(jq '[.foreshadowing[] | select(.status == "resolved")] | length' "$PLOT_TRACKER")

        overdue_foreshadow=$(jq --arg current "$CURRENT_CHAPTER" '
            [.foreshadowing[] |
             select(.status == "active" and .planted.chapter and
                    (($current | tonumber) - .planted.chapter) > 30)] |
            length' "$PLOT_TRACKER")

        active_conflicts=$(jq '.conflicts.active | length' "$PLOT_TRACKER")
    fi

    # 체크리스트 형식 출력
    cat <<EOF
# 줄거리 정합성 검사 체크리스트

**검사 시간**: $(date '+%Y-%m-%d %H:%M:%S')
**검사 대상**: plot-tracker.json, outline.md, progress.json
**현재 진행**: 제 ${CURRENT_CHAPTER} 장 (제 ${CURRENT_VOLUME} 권)

---

## 파일 무결성

- [$([ -f "$PLOT_TRACKER" ] && echo "x" || echo " ")] CHK001 plot-tracker.json 존재
- [$([ -f "$OUTLINE" ] && echo "x" || echo " ")] CHK002 outline.md 존재
- [$([ -f "$PROGRESS" ] && echo "x" || echo " ")] CHK003 progress.json 존재

## 줄거리 진행

- [$([ "$plot_status" != "unknown" ] && echo "x" || echo " ")] CHK004 메인 줄거리 상태 업데이트됨 (현재: $plot_status)
- [x] CHK005 메인 줄거리 노드 진행: $main_plot
- [$([ $completed_count -gt 0 ] && echo "x" || echo " ")] CHK006 완료된 줄거리 노드 ($completed_count 개)
- [$([ $upcoming_count -gt 0 ] && echo "x" || echo " ")] CHK007 후속 줄거리 노드 계획됨 ($upcoming_count 개)

## 복선 관리

EOF

    if [ $total_foreshadow -gt 0 ]; then
        echo "- [x] CHK008 복선 기록 존재 (총 $total_foreshadow 개)"
        echo "- [x] CHK009 복선 상태 추적 (활성 $active_foreshadow 개, 회수됨 $resolved_foreshadow 개)"

        if [ $overdue_foreshadow -eq 0 ]; then
            echo "- [x] CHK010 복선 회수 적시성 (30챕터 초과 미처리 없음)"
        else
            echo "- [!] CHK010 복선 회수 적시성 (⚠️ ${overdue_foreshadow}개가 30챕터 이상 미처리)"
        fi

        if [ $active_foreshadow -le 5 ]; then
            echo "- [x] CHK011 활성 복선 수 적정 ($active_foreshadow ≤ 5)"
        elif [ $active_foreshadow -le 10 ]; then
            echo "- [!] CHK011 활성 복선 수 다소 많음 ($active_foreshadow 개, 일부 회수 권장)"
        else
            echo "- [!] CHK011 활성 복선 수 과다 (⚠️ $active_foreshadow > 10, 혼란 야기 가능)"
        fi
    else
        echo "- [ ] CHK008 복선 기록 존재 (복선 기록 없음)"
        echo "- [ ] CHK009 복선 상태 추적 (데이터 없음)"
        echo "- [ ] CHK010 복선 회수 적시성 (데이터 없음)"
        echo "- [ ] CHK011 활성 복선 수 적정 (데이터 없음)"
    fi

    cat <<EOF

## 갈등 전개

EOF

    if [ $active_conflicts -gt 0 ]; then
        echo "- [x] CHK012 활성 갈등 존재 ($active_conflicts 개)"
    elif [ $CURRENT_CHAPTER -gt 5 ]; then
        echo "- [!] CHK012 활성 갈등 존재 (⚠️ 현재 활성 갈등 없음, 갈등 포인트 도입 권장)"
    else
        echo "- [x] CHK012 활성 갈등 존재 (초반부 챕터, 갈등 없어도 무방)"
    fi

    cat <<EOF

## 리듬 제안

EOF

    # 현재 챕터 기반 검사 항목
    if [ $CURRENT_CHAPTER -lt 10 ]; then
        echo "- [ ] CHK013 초반 10장 훅 설정 (충분한 흡인력 확보)"
    elif [ $CURRENT_CHAPTER -lt 30 ]; then
        echo "- [ ] CHK014 첫 번째 소규모 클라이맥스 준비 (갈등 강도 확인)"
    elif [ $((CURRENT_CHAPTER % 60)) -gt 50 ]; then
        echo "- [ ] CHK015 권말 클라이맥스 설정 (서스펜스와 클라이맥스 준비)"
    else
        echo "- [x] CHK016 리듬 정상 (특수 노드 알림 없음)"
    fi

    cat <<EOF

---

## 후속 조치

EOF

    # 동적 후속 조치 생성
    local has_actions=false

    if [ $overdue_foreshadow -gt 0 ]; then
        echo "- [ ] 만료 복선 회수 (${overdue_foreshadow}개)"
        has_actions=true
    fi

    if [ $active_foreshadow -gt 10 ]; then
        echo "- [ ] 활성 복선 수 줄이기 (현재 $active_foreshadow 개)"
        has_actions=true
    fi

    if [ $active_conflicts -eq 0 ] && [ $CURRENT_CHAPTER -gt 5 ]; then
        echo "- [ ] 새로운 갈등 포인트 도입"
        has_actions=true
    fi

    if [ $upcoming_count -eq 0 ]; then
        echo "- [ ] 후속 줄거리 노드 계획"
        has_actions=true
    fi

    if [ "$has_actions" = false ]; then
        echo "*현재 줄거리 전개 양호, 특별한 조치 불필요*"
    fi

    cat <<EOF

---

**검사 도구**: check-plot.sh
**버전**: 1.1 (체크리스트 출력 지원)
EOF
}

# 메인 함수
main() {
    if [ "$CHECKLIST_MODE" = true ]; then
        output_checklist
    else
        echo "🔍 줄거리 일관성 검사 시작..."
        echo ""

        # 필수 파일 확인
        check_required_files

        # 현재 진행도 가져오기
        get_current_progress

        # 각 항목 검사 실행
        analyze_plot_alignment
        check_foreshadowing
        check_conflicts
        generate_suggestions

        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━"
        echo "✅ 검사 완료"
    fi

    # 검사 시간 업데이트
    if [ -f "$PLOT_TRACKER" ]; then
        TEMP_FILE=$(mktemp)
        jq --arg date "$(date -Iseconds)" '.lastUpdated = $date' "$PLOT_TRACKER" > "$TEMP_FILE"
        mv "$TEMP_FILE" "$PLOT_TRACKER"
    fi
}

# 메인 함수 실행
main
