#!/bin/bash

# 집필 상태 확인 스크립트
# /write 명령어용

set -e

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# 체크리스트 모드 확인
CHECKLIST_MODE=false
if [ "$1" = "--checklist" ]; then
    CHECKLIST_MODE=true
fi

# Get project root
PROJECT_ROOT=$(get_project_root)
cd "$PROJECT_ROOT"

# 현재 스토리 가져오기
STORY_NAME=$(get_active_story)
STORY_DIR="stories/$STORY_NAME"

# 방법론 문서 확인
check_methodology_docs() {
    local missing=()

    [ ! -f ".specify/memory/constitution.md" ] && missing+=("헌법")
    [ ! -f "$STORY_DIR/specification.md" ] && missing+=("사양")
    [ ! -f "$STORY_DIR/creative-plan.md" ] && missing+=("계획")
    [ ! -f "$STORY_DIR/tasks.md" ] && missing+=("작업")

    if [ ${#missing[@]} -gt 0 ]; then
        echo "⚠️ 다음 기준 문서가 누락되었습니다:"
        for doc in "${missing[@]}"; do
            echo "  - $doc"
        done
        echo ""
        echo "7단계 방법론에 따라 선행 단계를 완료하세요:"
        echo "1. /constitution - 창작 헌법 작성"
        echo "2. /specify - 스토리 사양 정의"
        echo "3. /clarify - 핵심 결정 사항 명확화"
        echo "4. /plan - 창작 계획 수립"
        echo "5. /tasks - 작업 목록 생성"
        return 1
    fi

    echo "✅ 방법론 문서 완비"
    return 0
}

# 대기 중인 집필 작업 확인
check_pending_tasks() {
    local tasks_file="$STORY_DIR/tasks.md"

    if [ ! -f "$tasks_file" ]; then
        echo "❌ 작업 파일이 존재하지 않습니다"
        return 1
    fi

    # 작업 상태 집계
    local pending=$(grep -c "^- \[ \]" "$tasks_file" 2>/dev/null || echo 0)
    local in_progress=$(grep -c "^- \[~\]" "$tasks_file" 2>/dev/null || echo 0)
    local completed=$(grep -c "^- \[x\]" "$tasks_file" 2>/dev/null || echo 0)

    echo ""
    echo "작업 상태:"
    echo "  대기 중: $pending"
    echo "  진행 중: $in_progress"
    echo "  완료됨: $completed"

    if [ $pending -eq 0 ] && [ $in_progress -eq 0 ]; then
        echo ""
        echo "🎉 모든 작업이 완료되었습니다!"
        echo "/analyze 를 실행하여 종합 검증을 권장합니다"
        return 0
    fi

    # 다음 집필 작업 표시
    echo ""
    echo "다음 집필 작업:"
    grep "^- \[ \]" "$tasks_file" | head -n 1 || echo "(대기 중인 작업 없음)"
}

# 완료된 콘텐츠 확인
check_completed_content() {
    local content_dir="$STORY_DIR/content"
    local validation_rules="spec/tracking/validation-rules.json"
    local min_words=2000
    local max_words=4000

    # 검증 규칙 읽기 (존재하는 경우)
    if [ -f "$validation_rules" ]; then
        if command -v jq >/dev/null 2>&1; then
            min_words=$(jq -r '.rules.chapterMinWords // 2000' "$validation_rules")
            max_words=$(jq -r '.rules.chapterMaxWords // 4000' "$validation_rules")
        fi
    fi

    if [ -d "$content_dir" ]; then
        local chapter_count=$(ls "$content_dir"/*.md 2>/dev/null | wc -l)
        if [ $chapter_count -gt 0 ]; then
            echo ""
            echo "완료된 챕터: $chapter_count"
            echo "글자 수 기준: ${min_words}-${max_words} 자"
            echo ""
            echo "최근 집필:"
            for file in $(ls -t "$content_dir"/*.md 2>/dev/null | head -n 3); do
                local filename=$(basename "$file")
                local words=$(count_chinese_words "$file")
                local status="✅"

                if [ "$words" -lt "$min_words" ]; then
                    status="⚠️ 글자 수 부족"
                elif [ "$words" -gt "$max_words" ]; then
                    status="⚠️ 글자 수 초과"
                fi

                echo "  - $filename: $words 자 $status"
            done
        fi
    else
        echo ""
        echo "아직 집필을 시작하지 않았습니다"
    fi
}

# 체크리스트 형식 출력 생성
output_checklist() {
    local has_constitution=false
    local has_specification=false
    local has_plan=false
    local has_tasks=false
    local pending=0
    local in_progress=0
    local completed=0
    local chapter_count=0
    local bad_chapters=0
    local min_words=2000
    local max_words=4000

    # 문서 확인
    [ -f ".specify/memory/constitution.md" ] && has_constitution=true
    [ -f "$STORY_DIR/specification.md" ] && has_specification=true
    [ -f "$STORY_DIR/creative-plan.md" ] && has_plan=true
    [ -f "$STORY_DIR/tasks.md" ] && has_tasks=true

    # 작업 집계
    if [ "$has_tasks" = true ]; then
        pending=$(grep -c "^- \[ \]" "$STORY_DIR/tasks.md" 2>/dev/null || echo 0)
        in_progress=$(grep -c "^- \[~\]" "$STORY_DIR/tasks.md" 2>/dev/null || echo 0)
        completed=$(grep -c "^- \[x\]" "$STORY_DIR/tasks.md" 2>/dev/null || echo 0)
    fi

    # 검증 규칙 읽기
    local validation_rules="$STORY_DIR/spec/tracking/validation-rules.json"
    if [ -f "$validation_rules" ] && command -v jq >/dev/null 2>&1; then
        min_words=$(jq -r '.rules.chapterMinWords // 2000' "$validation_rules")
        max_words=$(jq -r '.rules.chapterMaxWords // 4000' "$validation_rules")
    fi

    # 챕터 콘텐츠 확인
    local content_dir="$STORY_DIR/content"
    if [ -d "$content_dir" ]; then
        chapter_count=$(ls "$content_dir"/*.md 2>/dev/null | wc -l | tr -d ' ')

        # 글자 수 기준 미달 챕터 집계
        for file in "$content_dir"/*.md; do
            [ -f "$file" ] || continue
            local words=$(count_chinese_words "$file")
            if [ "$words" -lt "$min_words" ] || [ "$words" -gt "$max_words" ]; then
                bad_chapters=$((bad_chapters + 1))
            fi
        done
    fi

    # 총 작업 수 및 완료율 계산
    local total_tasks=$((pending + in_progress + completed))
    local completion_rate=0
    if [ $total_tasks -gt 0 ]; then
        completion_rate=$((completed * 100 / total_tasks))
    fi

    # 체크리스트 출력
    cat <<EOF
# 집필 상태 확인 체크리스트

**확인 시간**: $(date '+%Y-%m-%d %H:%M:%S')
**현재 스토리**: $STORY_NAME
**글자 수 기준**: ${min_words}-${max_words} 자

---

## 문서 완비성

- [$([ "$has_constitution" = true ] && echo "x" || echo " ")] CHK001 constitution.md 존재
- [$([ "$has_specification" = true ] && echo "x" || echo " ")] CHK002 specification.md 존재
- [$([ "$has_plan" = true ] && echo "x" || echo " ")] CHK003 creative-plan.md 존재
- [$([ "$has_tasks" = true ] && echo "x" || echo " ")] CHK004 tasks.md 존재

## 작업 진행도

EOF

    if [ "$has_tasks" = true ]; then
        echo "- [$([ $in_progress -gt 0 ] && echo "x" || echo " ")] CHK005 진행 중인 작업 있음 ($in_progress 개)"
        echo "- [x] CHK006 대기 중인 작업 수 ($pending 개)"
        echo "- [$([ $completed -gt 0 ] && echo "x" || echo " ")] CHK007 완료된 작업 진행률 ($completed/$total_tasks = $completion_rate%)"
    else
        echo "- [ ] CHK005 진행 중인 작업 있음 (tasks.md 없음)"
        echo "- [ ] CHK006 대기 중인 작업 수 (tasks.md 없음)"
        echo "- [ ] CHK007 완료된 작업 진행률 (tasks.md 없음)"
    fi

    cat <<EOF

## 콘텐츠 품질

- [$([ $chapter_count -gt 0 ] && echo "x" || echo " ")] CHK008 완료된 챕터 수 ($chapter_count 장)
EOF

    if [ $chapter_count -gt 0 ]; then
        echo "- [$([ $bad_chapters -eq 0 ] && echo "x" || echo "!")] CHK009 글자 수 기준 충족 ($([ $bad_chapters -eq 0 ] && echo "전부 충족" || echo "$bad_chapters 장 미충족"))"
    else
        echo "- [ ] CHK009 글자 수 기준 충족 (아직 집필 시작 전)"
    fi

    cat <<EOF

---

## 후속 조치

EOF

    local has_actions=false

    # 누락 문서 확인
    if [ "$has_constitution" = false ] || [ "$has_specification" = false ] || [ "$has_plan" = false ] || [ "$has_tasks" = false ]; then
        echo "- [ ] 방법론 문서 완성 (해당 명령어 실행: /constitution, /specify, /plan, /tasks)"
        has_actions=true
    fi

    # 작업 확인
    if [ $pending -gt 0 ] || [ $in_progress -gt 0 ]; then
        if [ $in_progress -gt 0 ]; then
            echo "- [ ] 진행 중인 작업 계속 ($in_progress 개)"
        else
            echo "- [ ] 다음 대기 작업 시작 (총 $pending 개)"
        fi
        has_actions=true
    fi

    # 챕터 품질 확인
    if [ $bad_chapters -gt 0 ]; then
        echo "- [ ] 글자 수 기준 미달 챕터 수정 ($bad_chapters 장)"
        has_actions=true
    fi

    # 완료 시 제안
    if [ $pending -eq 0 ] && [ $in_progress -eq 0 ] && [ $completed -gt 0 ]; then
        echo "- [ ] /analyze 를 실행하여 종합 검증"
        has_actions=true
    fi

    if [ "$has_actions" = false ]; then
        echo "*집필 상태 양호, 특별한 조치 불필요*"
    fi

    cat <<EOF

---

**확인 도구**: check-writing-state.sh
**버전**: 1.1 (체크리스트 출력 지원)
EOF
}

# 메인 흐름
main() {
    # 체크리스트 모드: 직접 출력 후 종료
    if [ "$CHECKLIST_MODE" = true ]; then
        output_checklist
        exit 0
    fi

    # 기존 상세 출력 모드
    echo "집필 상태 확인"
    echo "============"
    echo "현재 스토리: $STORY_NAME"
    echo ""

    if ! check_methodology_docs; then
        exit 1
    fi

    check_pending_tasks
    check_completed_content

    echo ""
    echo "준비 완료, 집필을 시작할 수 있습니다"
}

main
