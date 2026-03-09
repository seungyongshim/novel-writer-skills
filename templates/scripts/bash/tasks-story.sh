#!/bin/bash

# 작업 분해 스크립트
# /tasks 명령용

set -e

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# Parse arguments
STORY_NAME=""
if [ $# -gt 0 ]; then
    STORY_NAME="$1"
fi

# Get project root
PROJECT_ROOT=$(get_project_root)
cd "$PROJECT_ROOT"

# 스토리 이름 결정
if [ -z "$STORY_NAME" ]; then
    STORY_NAME=$(get_active_story)
fi

STORY_DIR="stories/$STORY_NAME"
SPEC_FILE="$STORY_DIR/specification.md"
PLAN_FILE="$STORY_DIR/creative-plan.md"
TASKS_FILE="$STORY_DIR/tasks.md"

echo "작업 분해"
echo "========"
echo "스토리: $STORY_NAME"
echo ""

# 선행 문서 확인
missing=()

if [ ! -f ".specify/memory/constitution.md" ]; then
    missing+=("헌법 파일")
fi

if [ ! -f "$SPEC_FILE" ]; then
    missing+=("규격 파일")
fi

if [ ! -f "$PLAN_FILE" ]; then
    missing+=("계획 파일")
fi

if [ ${#missing[@]} -gt 0 ]; then
    echo "⚠️ 다음 선행 문서가 누락됨:"
    for doc in "${missing[@]}"; do
        echo "  - $doc"
    done
    echo ""
    echo "먼저 다음을 완료하세요:"
    if [ ! -f ".specify/memory/constitution.md" ]; then
        echo "  1. /constitution - 창작 헌법 생성"
    fi
    if [ ! -f "$SPEC_FILE" ]; then
        echo "  2. /specify - 스토리 규격 정의"
    fi
    if [ ! -f "$PLAN_FILE" ]; then
        echo "  3. /plan - 창작 계획 수립"
    fi
    exit 1
fi

# 작업 파일 확인
if [ -f "$TASKS_FILE" ]; then
    echo ""
    echo "📋 작업 파일이 이미 존재, 기존 작업 업데이트"

    # 작업 통계 표시
    total_tasks=$(grep -c "^- \[" "$TASKS_FILE" 2>/dev/null || echo "0")
    completed_tasks=$(grep -c "^- \[x\]" "$TASKS_FILE" 2>/dev/null || echo "0")
    echo "  총 작업 수: $total_tasks"
    echo "  완료: $completed_tasks"
else
    echo ""
    echo "📝 새 작업 체크리스트 생성 예정"
fi

echo ""
echo "작업 파일 경로: $TASKS_FILE"
echo ""
echo "준비 완료, 작업을 분해할 수 있습니다"
echo ""
echo "작업 분해에 포함되는 것:"
echo "  - 장 집필 작업 (계획 기반)"
echo "  - 캐릭터 프로필 보완"
echo "  - 세계관 문서 보충"
echo "  - 품질 검사 노드"
echo "  - 검증 및 수정 작업"
