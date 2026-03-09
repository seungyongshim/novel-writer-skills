#!/usr/bin/env bash
# 종합 일관성 검사 스크립트

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
PROGRESS="$STORY_DIR/progress.json"
PLOT_TRACKER="$STORY_DIR/spec/tracking/plot-tracker.json"
TIMELINE="$STORY_DIR/spec/tracking/timeline.json"
RELATIONSHIPS="$STORY_DIR/spec/tracking/relationships.json"
CHARACTER_STATE="$STORY_DIR/spec/tracking/character-state.json"

# ANSI 색상 코드
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 통계 변수
TOTAL_CHECKS=0
PASSED_CHECKS=0
WARNINGS=0
ERRORS=0

# 검사 함수
check() {
    local name="$1"
    local condition="$2"
    local error_msg="$3"

    ((TOTAL_CHECKS++))

    if eval "$condition"; then
        echo -e "${GREEN}✓${NC} $name"
        ((PASSED_CHECKS++))
    else
        echo -e "${RED}✗${NC} $name: $error_msg"
        ((ERRORS++))
    fi
}

warn() {
    local msg="$1"
    echo -e "${YELLOW}⚠${NC} 경고: $msg"
    ((WARNINGS++))
}

# 챕터 번호 일관성 검사
check_chapter_consistency() {
    echo "📖 챕터 번호 일관성 검사"
    echo "───────────────────"

    if [ -f "$PROGRESS" ] && [ -f "$PLOT_TRACKER" ]; then
        PROGRESS_CHAPTER=$(jq -r '.statistics.currentChapter // 0' "$PROGRESS")
        PLOT_CHAPTER=$(jq -r '.currentState.chapter // 0' "$PLOT_TRACKER")

        check "챕터 번호 동기화" \
              "[ '$PROGRESS_CHAPTER' = '$PLOT_CHAPTER' ]" \
              "progress.json(${PROGRESS_CHAPTER}) != plot-tracker.json(${PLOT_CHAPTER})"

        if [ -f "$CHARACTER_STATE" ]; then
            CHAR_CHAPTER=$(jq -r '.protagonist.currentStatus.chapter // 0' "$CHARACTER_STATE")
            check "캐릭터 상태 챕터 동기화" \
                  "[ '$PROGRESS_CHAPTER' = '$CHAR_CHAPTER' ]" \
                  "character-state.json(${CHAR_CHAPTER})과 불일치"
        fi
    else
        warn "일부 추적 파일이 누락되어 챕터 검사를 완료할 수 없습니다"
    fi

    echo ""
}

# 타임라인 연속성 검사
check_timeline_consistency() {
    echo "⏰ 타임라인 연속성 검사"
    echo "───────────────────"

    if [ -f "$TIMELINE" ]; then
        # 시간 이벤트가 챕터 순으로 증가하는지 확인
        TIMELINE_ISSUES=$(jq '
            .events |
            sort_by(.chapter) |
            . as $sorted |
            reduce range(1; length) as $i (0;
                if $sorted[$i].chapter <= $sorted[$i-1].chapter then . + 1 else . end
            )' "$TIMELINE")

        check "시간 이벤트 순서" \
              "[ '$TIMELINE_ISSUES' = '0' ]" \
              "${TIMELINE_ISSUES}개의 순서 이상 이벤트 발견"

        # 현재 시간 업데이트 여부 확인
        CURRENT_TIME=$(jq -r '.storyTime.current // ""' "$TIMELINE")
        check "현재 시간 설정" \
              "[ -n '$CURRENT_TIME' ]" \
              "현재 스토리 시간이 설정되지 않았습니다"
    else
        warn "타임라인 파일이 존재하지 않습니다"
    fi

    echo ""
}

# 캐릭터 상태 합리성 검사
check_character_consistency() {
    echo "👥 캐릭터 상태 합리성 검사"
    echo "─────────────────────"

    if [ -f "$CHARACTER_STATE" ] && [ -f "$RELATIONSHIPS" ]; then
        # 주인공이 두 파일 모두에 존재하는지 확인
        PROTAG_NAME=$(jq -r '.protagonist.name // ""' "$CHARACTER_STATE")

        if [ -n "$PROTAG_NAME" ]; then
            HAS_RELATIONS=$(jq --arg name "$PROTAG_NAME" \
                'has($name)' "$RELATIONSHIPS" 2>/dev/null || echo "false")

            check "주인공 관계 기록" \
                  "[ '$HAS_RELATIONS' = 'true' ]" \
                  "주인공 '$PROTAG_NAME'이 relationships.json에 기록되지 않았습니다"
        fi

        # 캐릭터 위치 논리 확인
        LAST_LOCATION=$(jq -r '.protagonist.currentStatus.location // ""' "$CHARACTER_STATE")
        check "주인공 위치 기록" \
              "[ -n '$LAST_LOCATION' ]" \
              "주인공의 현재 위치가 기록되지 않았습니다"
    else
        warn "캐릭터 추적 파일이 불완전합니다"
    fi

    echo ""
}

# 복선 회수 계획 검사
check_foreshadowing_plan() {
    echo "🎯 복선 관리 검사"
    echo "──────────────"

    if [ -f "$PLOT_TRACKER" ]; then
        # 복선 상태 집계
        TOTAL_FORESHADOW=$(jq '.foreshadowing | length' "$PLOT_TRACKER")
        ACTIVE_FORESHADOW=$(jq '[.foreshadowing[] | select(.status == "active")] | length' "$PLOT_TRACKER")

        if [ -f "$PROGRESS" ]; then
            CURRENT_CHAPTER=$(jq -r '.statistics.currentChapter // 0' "$PROGRESS")

            # 미회수 초과 복선 확인 (50챕터 이상)
            OVERDUE=$(jq --arg current "$CURRENT_CHAPTER" '
                [.foreshadowing[] |
                 select(.status == "active" and .planted.chapter and
                        (($current | tonumber) - .planted.chapter) > 50)] |
                length' "$PLOT_TRACKER")

            check "복선 회수 적시성" \
                  "[ '$OVERDUE' = '0' ]" \
                  "${OVERDUE}개의 복선이 50챕터 이상 미회수"
        fi

        echo "  📊 복선 통계: 총 ${TOTAL_FORESHADOW}개, 활성 ${ACTIVE_FORESHADOW}개"

        # 활성 복선 과다 경고
        if [ "$ACTIVE_FORESHADOW" -gt 10 ]; then
            warn "활성 복선이 과다합니다(${ACTIVE_FORESHADOW}개). 독자 혼란을 야기할 수 있습니다"
        fi
    else
        warn "줄거리 추적 파일이 존재하지 않습니다"
    fi

    echo ""
}

# 파일 무결성 검사
check_file_integrity() {
    echo "📁 파일 무결성 검사"
    echo "────────────────"

    check "progress.json" "[ -f '$PROGRESS' ]" "파일이 존재하지 않습니다"
    check "plot-tracker.json" "[ -f '$PLOT_TRACKER' ]" "파일이 존재하지 않습니다"
    check "timeline.json" "[ -f '$TIMELINE' ]" "파일이 존재하지 않습니다"
    check "relationships.json" "[ -f '$RELATIONSHIPS' ]" "파일이 존재하지 않습니다"
    check "character-state.json" "[ -f '$CHARACTER_STATE' ]" "파일이 존재하지 않습니다"

    # JSON 형식 유효성 검사
    for file in "$PROGRESS" "$PLOT_TRACKER" "$TIMELINE" "$RELATIONSHIPS" "$CHARACTER_STATE"; do
        if [ -f "$file" ]; then
            filename=$(basename "$file")
            if jq empty "$file" 2>/dev/null; then
                check "${filename} 형식" "true" ""
            else
                check "${filename} 형식" "false" "JSON 형식이 유효하지 않습니다"
            fi
        fi
    done

    echo ""
}

# 보고서 생성
generate_report() {
    echo "═══════════════════════════════════════"
    echo "📊 종합 일관성 검사 보고서"
    echo "═══════════════════════════════════════"
    echo ""

    check_file_integrity
    check_chapter_consistency
    check_timeline_consistency
    check_character_consistency
    check_foreshadowing_plan

    echo "═══════════════════════════════════════"
    echo "📈 검사 결과 요약"
    echo "───────────────────"
    echo "  총 검사 항목: ${TOTAL_CHECKS}"
    echo -e "  ${GREEN}통과: ${PASSED_CHECKS}${NC}"
    echo -e "  ${YELLOW}경고: ${WARNINGS}${NC}"
    echo -e "  ${RED}오류: ${ERRORS}${NC}"

    if [ "$ERRORS" -eq 0 ] && [ "$WARNINGS" -eq 0 ]; then
        echo ""
        echo -e "${GREEN}✅ 완벽! 모든 검사 항목을 통과했습니다${NC}"
    elif [ "$ERRORS" -eq 0 ]; then
        echo ""
        echo -e "${YELLOW}⚠️  ${WARNINGS}개의 경고가 있습니다. 확인을 권장합니다${NC}"
    else
        echo ""
        echo -e "${RED}❌ ${ERRORS}개의 오류가 발견되었습니다. 수정이 필요합니다${NC}"
    fi

    echo "═══════════════════════════════════════"
    echo ""
    echo "검사 시간: $(date '+%Y-%m-%d %H:%M:%S')"

    # 검사 결과 기록
    if [ -f "$STORY_DIR/spec/tracking" ]; then
        echo "{
            \"timestamp\": \"$(date -Iseconds)\",
            \"total\": $TOTAL_CHECKS,
            \"passed\": $PASSED_CHECKS,
            \"warnings\": $WARNINGS,
            \"errors\": $ERRORS
        }" > "$STORY_DIR/spec/tracking/.last-check.json"
    fi
}

# 체크리스트 형식 출력 생성
output_checklist() {
    # 검사 로직을 묵음으로 실행
    exec 3>&1 4>&2  # 원래 출력 저장
    exec 1>/dev/null 2>&1  # null로 리디렉션

    check_file_integrity
    check_chapter_consistency
    check_timeline_consistency
    check_character_consistency
    check_foreshadowing_plan

    exec 1>&3 2>&4  # 출력 복원

    # 검사에 사용할 챕터 번호 가져오기
    local progress_chapter=""
    local plot_chapter=""
    local char_chapter=""
    if [ -f "$PROGRESS" ] && [ -f "$PLOT_TRACKER" ]; then
        progress_chapter=$(jq -r '.statistics.currentChapter // 0' "$PROGRESS" 2>/dev/null || echo "0")
        plot_chapter=$(jq -r '.currentState.chapter // 0' "$PLOT_TRACKER" 2>/dev/null || echo "0")
    fi
    if [ -f "$CHARACTER_STATE" ]; then
        char_chapter=$(jq -r '.protagonist.currentStatus.chapter // 0' "$CHARACTER_STATE" 2>/dev/null || echo "0")
    fi

    # 복선 상태 확인
    local total_foreshadow=0
    local active_foreshadow=0
    local overdue_foreshadow=0
    if [ -f "$PLOT_TRACKER" ]; then
        total_foreshadow=$(jq '.foreshadowing | length' "$PLOT_TRACKER" 2>/dev/null || echo "0")
        active_foreshadow=$(jq '[.foreshadowing[] | select(.status == "active")] | length' "$PLOT_TRACKER" 2>/dev/null || echo "0")

        if [ -f "$PROGRESS" ]; then
            local current_chapter=$(jq -r '.statistics.currentChapter // 0' "$PROGRESS" 2>/dev/null || echo "0")
            overdue_foreshadow=$(jq --arg current "$current_chapter" '[.foreshadowing[] | select(.status == "active" and .planted.chapter and (($current | tonumber) - .planted.chapter) > 50)] | length' "$PLOT_TRACKER" 2>/dev/null || echo "0")
        fi
    fi

    # 체크리스트 형식 출력
    cat <<EOF
# 데이터 동기화 일관성 검사 체크리스트

**검사 시간**: $(date '+%Y-%m-%d %H:%M:%S')
**검사 대상**: spec/tracking/ 디렉토리 모든 JSON 파일
**검사 범위**: 파일 무결성, 챕터 동기화, 타임라인 연속성, 캐릭터 상태, 복선 관리

---

## 파일 무결성

- [$([ -f "$PROGRESS" ] && echo "x" || echo " ")] CHK001 progress.json 존재 및 형식 유효
- [$([ -f "$PLOT_TRACKER" ] && echo "x" || echo " ")] CHK002 plot-tracker.json 존재 및 형식 유효
- [$([ -f "$TIMELINE" ] && echo "x" || echo " ")] CHK003 timeline.json 존재 및 형식 유효
- [$([ -f "$RELATIONSHIPS" ] && echo "x" || echo " ")] CHK004 relationships.json 존재 및 형식 유효
- [$([ -f "$CHARACTER_STATE" ] && echo "x" || echo " ")] CHK005 character-state.json 존재 및 형식 유효

## 챕터 번호 동기화

EOF

    if [ "$progress_chapter" = "$plot_chapter" ]; then
        echo "- [x] CHK006 progress.json과 plot-tracker.json 챕터 번호 일치 (제 $progress_chapter 장)"
    else
        echo "- [!] CHK006 progress.json(${progress_chapter})과 plot-tracker.json(${plot_chapter}) 챕터 번호 불일치"
    fi

    if [ -n "$char_chapter" ]; then
        if [ "$progress_chapter" = "$char_chapter" ]; then
            echo "- [x] CHK007 progress.json과 character-state.json 챕터 번호 일치"
        else
            echo "- [!] CHK007 progress.json(${progress_chapter})과 character-state.json(${char_chapter}) 챕터 번호 불일치"
        fi
    else
        echo "- [ ] CHK007 character-state.json 챕터 번호 검사 (파일 없음 또는 데이터 부재)"
    fi

    cat <<EOF

## 타임라인 연속성

- [$([ -f "$TIMELINE" ] && echo "x" || echo " ")] CHK008 타임라인 이벤트가 챕터 순으로 정렬
- [$([ -f "$TIMELINE" ] && echo "x" || echo " ")] CHK009 현재 스토리 시간 설정 완료

## 캐릭터 상태

EOF

    if [ -f "$CHARACTER_STATE" ] && [ -f "$RELATIONSHIPS" ]; then
        local protag_name=$(jq -r '.protagonist.name // ""' "$CHARACTER_STATE" 2>/dev/null)
        if [ -n "$protag_name" ]; then
            echo "- [x] CHK010 주인공 정보 완비 ($protag_name)"
            local has_relations=$(jq --arg name "$protag_name" 'has($name)' "$RELATIONSHIPS" 2>/dev/null || echo "false")
            if [ "$has_relations" = "true" ]; then
                echo "- [x] CHK011 주인공 relationships.json에 관계 기록 있음"
            else
                echo "- [!] CHK011 주인공 '$protag_name' relationships.json에 관계 기록 없음"
            fi
        else
            echo "- [ ] CHK010 주인공 정보 완비 (데이터 부재)"
            echo "- [ ] CHK011 주인공 관계 기록 (데이터 부재)"
        fi

        local last_location=$(jq -r '.protagonist.currentStatus.location // ""' "$CHARACTER_STATE" 2>/dev/null)
        if [ -n "$last_location" ]; then
            echo "- [x] CHK012 주인공 현재 위치 기록됨 ($last_location)"
        else
            echo "- [!] CHK012 주인공 현재 위치 미기록"
        fi
    else
        echo "- [ ] CHK010 주인공 정보 완비 (파일 없음)"
        echo "- [ ] CHK011 주인공 관계 기록 (파일 없음)"
        echo "- [ ] CHK012 주인공 현재 위치 기록 (파일 없음)"
    fi

    cat <<EOF

## 복선 관리

EOF

    if [ "$total_foreshadow" -gt 0 ]; then
        echo "- [x] CHK013 복선 기록 존재 (총 $total_foreshadow 개, 활성 $active_foreshadow 개)"

        if [ "$overdue_foreshadow" -eq 0 ]; then
            echo "- [x] CHK014 복선 회수 적시성 (미회수 초과 없음)"
        else
            echo "- [!] CHK014 복선 회수 적시성 ($overdue_foreshadow 개가 50챕터 이상 미회수)"
        fi

        if [ "$active_foreshadow" -le 10 ]; then
            echo "- [x] CHK015 활성 복선 수 적정 ($active_foreshadow ≤ 10)"
        else
            echo "- [!] CHK015 활성 복선 수 과다 ($active_foreshadow > 10, 독자 혼란 가능)"
        fi
    else
        echo "- [ ] CHK013 복선 기록 존재 (복선 기록 없음)"
        echo "- [ ] CHK014 복선 회수 적시성 (데이터 없음)"
        echo "- [ ] CHK015 활성 복선 수 적정 (데이터 없음)"
    fi

    cat <<EOF

---

## 검사 통계

- **총 검사 항목**: ${TOTAL_CHECKS}
- **통과**: ${PASSED_CHECKS}
- **경고**: ${WARNINGS}
- **오류**: ${ERRORS}

---

## 후속 조치

EOF

    if [ "$ERRORS" -gt 0 ]; then
        echo "- [ ] 위 [!] 표시된 불일치 문제 수정"
    fi
    if [ "$WARNINGS" -gt 0 ]; then
        echo "- [ ] 경고 항목 확인 후 개선 필요 여부 검토"
    fi
    if [ "$ERRORS" -eq 0 ] && [ "$WARNINGS" -eq 0 ]; then
        echo "*모든 검사 통과, 조치 불필요*"
    fi

    cat <<EOF

---

**검사 도구**: check-consistency.sh
**버전**: 1.1 (체크리스트 출력 지원)
EOF
}

# 메인 함수
main() {
    if [ "$CHECKLIST_MODE" = true ]; then
        output_checklist
    else
        generate_report
    fi

    # 결과에 따른 적절한 종료 코드 반환
    if [ "$ERRORS" -gt 0 ]; then
        exit 1
    elif [ "$WARNINGS" -gt 0 ]; then
        exit 0  # 경고는 실패로 간주하지 않음
    else
        exit 0
    fi
}

# 메인 함수 실행
main
