#!/bin/bash

# 스토리 규격 정의 스크립트
# /specify 명령용

set -e

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# Parse arguments
JSON_MODE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --json)
            JSON_MODE=true
            shift
            ;;
        *)
            STORY_NAME="$1"
            shift
            ;;
    esac
done

# Get project root
PROJECT_ROOT=$(get_project_root)
cd "$PROJECT_ROOT"

# 스토리 이름과 경로 결정
if [ -z "$STORY_NAME" ]; then
    # 최신 스토리 찾기
    STORIES_DIR="stories"
    if [ -d "$STORIES_DIR" ] && [ "$(ls -A $STORIES_DIR 2>/dev/null)" ]; then
        STORY_DIR=$(find "$STORIES_DIR" -maxdepth 1 -type d ! -name "stories" | sort -r | head -n 1)
        if [ -n "$STORY_DIR" ]; then
            STORY_NAME=$(basename "$STORY_DIR")
        fi
    fi

    # 여전히 없으면 기본 이름 생성
    if [ -z "$STORY_NAME" ]; then
        STORY_NAME="story-$(date +%Y%m%d)"
    fi
fi

# 경로 설정
STORY_DIR="stories/$STORY_NAME"
SPEC_FILE="$STORY_DIR/specification.md"

# 디렉토리 생성
mkdir -p "$STORY_DIR"

# 파일 상태 확인
SPEC_EXISTS=false
STATUS="new"

if [ -f "$SPEC_FILE" ]; then
    SPEC_EXISTS=true
    STATUS="exists"
fi

# JSON 형식으로 출력
if [ "$JSON_MODE" = true ]; then
    cat <<EOF
{
    "STORY_NAME": "$STORY_NAME",
    "STORY_DIR": "$STORY_DIR",
    "SPEC_PATH": "$SPEC_FILE",
    "STATUS": "$STATUS",
    "PROJECT_ROOT": "$PROJECT_ROOT"
}
EOF
else
    echo "스토리 규격 초기화"
    echo "================"
    echo "스토리 이름: $STORY_NAME"
    echo "규격 경로: $SPEC_FILE"

    if [ "$SPEC_EXISTS" = true ]; then
        echo "상태: 규격 파일이 이미 존재, 업데이트 준비"
    else
        echo "상태: 새 규격 생성 준비"
    fi

    # 헌법 확인
    if [ -f ".specify/memory/constitution.md" ]; then
        echo ""
        echo "✅ 창작 헌법 감지됨, 규격이 헌법 원칙을 따름"
    fi
fi
