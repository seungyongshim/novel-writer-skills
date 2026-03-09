#!/bin/bash

# 창작 계획 스크립트
# /plan 명령용

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
CLARIFY_FILE="$STORY_DIR/clarification.md"
PLAN_FILE="$STORY_DIR/creative-plan.md"

echo "창작 계획 수립"
echo "============"
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
    exit 1
fi

# 명확화가 필요한 부분이 있는지 확인
if [ -f "$SPEC_FILE" ]; then
    unclear_count=$(grep -o '\[명확화 필요\]' "$SPEC_FILE" | wc -l | tr -d ' ')

    if [ "$unclear_count" -gt 0 ]; then
        echo "⚠️ 규격에 ${unclear_count}곳이 명확화 필요"
        echo "먼저 /clarify를 실행하여 핵심 결정을 명확화하는 것을 권장"
        echo ""
    fi
fi

# 명확화 기록 확인
if [ -f "$CLARIFY_FILE" ]; then
    echo "✅ 명확화 완료, 명확화 결정을 기반으로 계획 수립"
else
    echo "📝 명확화 기록 없음, 원본 규격을 기반으로 계획 수립"
fi

# 계획 파일 확인
if [ -f "$PLAN_FILE" ]; then
    echo ""
    echo "📋 계획 파일이 이미 존재, 기존 계획 업데이트"

    # 현재 버전 표시
    if grep -q "버전:" "$PLAN_FILE"; then
        version=$(grep "버전:" "$PLAN_FILE" | head -1 | sed 's/.*버전://')
        echo "  현재 버전: $version"
    fi
else
    echo ""
    echo "📝 새 창작 계획 생성 예정"
fi

echo ""
echo "계획 파일 경로: $PLAN_FILE"
echo ""
echo "준비 완료, 창작 계획을 수립할 수 있습니다"
