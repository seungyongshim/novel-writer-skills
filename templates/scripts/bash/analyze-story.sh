#!/bin/bash

# 스토리 분석 검증 스크립트
# /analyze 명령용

set -e

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# Parse arguments
STORY_NAME="$1"
ANALYSIS_TYPE="${2:-full}"  # full, compliance, quality, progress

# Get project root
PROJECT_ROOT=$(get_project_root)
cd "$PROJECT_ROOT"

# 스토리 경로 결정
if [ -z "$STORY_NAME" ]; then
    STORY_NAME=$(get_active_story)
fi

STORY_DIR="stories/$STORY_NAME"

# 필수 파일 확인
check_story_files() {
    local missing_files=()

    # 기준 문서 확인
    [ ! -f ".specify/memory/constitution.md" ] && missing_files+=("헌법 파일")
    [ ! -f "$STORY_DIR/specification.md" ] && missing_files+=("규격 파일")
    [ ! -f "$STORY_DIR/creative-plan.md" ] && missing_files+=("계획 파일")

    if [ ${#missing_files[@]} -gt 0 ]; then
        echo "⚠️ 다음 기준 문서가 누락됨:"
        for file in "${missing_files[@]}"; do
            echo "  - $file"
        done
        return 1
    fi

    return 0
}

# 내용 통계
analyze_content() {
    local content_dir="$STORY_DIR/content"
    local total_words=0
    local chapter_count=0

    if [ -d "$content_dir" ]; then
        echo "내용 통계:"
        echo ""
        for file in "$content_dir"/*.md; do
            if [ -f "$file" ]; then
                ((chapter_count++))
                # 정확한 글자 수 통계 사용
                local words=$(count_chinese_words "$file")
                ((total_words += words))
                local filename=$(basename "$file")
                echo "  $filename: ${words}자"
            fi
        done
        echo ""
        echo "  총 글자 수: $total_words"
        echo "  장 수: $chapter_count"
        if [ $chapter_count -gt 0 ]; then
            echo "  평균 장 길이: $((total_words / chapter_count))자"
        fi
    else
        echo "내용 통계:"
        echo "  아직 집필을 시작하지 않음"
    fi
}

# 작업 완료도 확인
check_task_completion() {
    local tasks_file="$STORY_DIR/tasks.md"
    if [ ! -f "$tasks_file" ]; then
        echo "작업 파일이 존재하지 않음"
        return
    fi

    local total_tasks=$(grep -c "^- \[" "$tasks_file" 2>/dev/null || echo 0)
    local completed_tasks=$(grep -c "^- \[x\]" "$tasks_file" 2>/dev/null || echo 0)
    local in_progress=$(grep -c "^- \[~\]" "$tasks_file" 2>/dev/null || echo 0)
    local pending=$((total_tasks - completed_tasks - in_progress))

    echo "작업 진도:"
    echo "  총 작업: $total_tasks"
    echo "  완료: $completed_tasks"
    echo "  진행 중: $in_progress"
    echo "  미시작: $pending"

    if [ $total_tasks -gt 0 ]; then
        local completion_rate=$((completed_tasks * 100 / total_tasks))
        echo "  완료율: $completion_rate%"
    fi
}

# 규격 부합도 확인
check_specification_compliance() {
    local spec_file="$STORY_DIR/specification.md"

    echo "규격 부합도 검사:"

    # P0 요구 확인 (간소화 버전)
    local p0_count=$(grep -c "^### 필수 포함 (P0)" "$spec_file" 2>/dev/null || echo 0)
    if [ $p0_count -gt 0 ]; then
        echo "  P0 요구: 감지됨, 수동 검증 필요"
    fi

    # [명확화 필요] 태그가 남아있는지 확인
    local unclear=$(grep -c "\[명확화 필요\]" "$spec_file" 2>/dev/null || echo 0)
    if [ $unclear -gt 0 ]; then
        echo "  ⚠️ 아직 ${unclear}곳이 명확화 필요"
    else
        echo "  ✅ 모든 결정이 명확화됨"
    fi
}

# 메인 분석 흐름
main() {
    echo "스토리 분석 보고서"
    echo "============"
    echo "스토리: $STORY_NAME"
    echo "분석 시각: $(date '+%Y-%m-%d %H:%M:%S')"
    echo ""

    # 기준 문서 확인
    if ! check_story_files; then
        echo ""
        echo "❌ 전체 분석을 수행할 수 없음, 먼저 기준 문서를 완성하세요"
        exit 1
    fi

    echo "✅ 기준 문서 완전"
    echo ""

    # 분석 유형에 따라 실행
    case "$ANALYSIS_TYPE" in
        full)
            analyze_content
            echo ""
            check_task_completion
            echo ""
            check_specification_compliance
            ;;
        quality)
            analyze_content
            ;;
        progress)
            check_task_completion
            ;;
        compliance)
            check_specification_compliance
            ;;
        *)
            echo "알 수 없는 분석 유형: $ANALYSIS_TYPE"
            exit 1
            ;;
    esac

    echo ""
    echo "분석 완료. 상세 보고서 저장 위치: $STORY_DIR/analysis-report.md"
}

main
