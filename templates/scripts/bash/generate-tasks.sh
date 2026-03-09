#!/usr/bin/env bash
# 집필 작업 생성

set -e

# 공용 함수 로드
SCRIPT_DIR=$(dirname "$0")
source "$SCRIPT_DIR/common.sh"

# 현재 스토리 디렉토리 가져오기
STORY_DIR=$(get_current_story)

if [ -z "$STORY_DIR" ]; then
    echo "오류: 스토리 프로젝트를 찾을 수 없음" >&2
    exit 1
fi

# 선행 조건 확인
if [ ! -f "$STORY_DIR/specification.md" ]; then
    echo "오류: 스토리 규격을 찾을 수 없음, 먼저 /specify 명령을 사용하세요" >&2
    exit 1
fi

if [ ! -f "$STORY_DIR/outline.md" ]; then
    echo "오류: 장 계획을 찾을 수 없음, 먼저 /outline 명령을 사용하세요" >&2
    exit 1
fi

# 현재 날짜 가져오기
CURRENT_DATE=$(date '+%Y-%m-%d')
CURRENT_DATETIME=$(date '+%Y-%m-%d %H:%M:%S')

# 작업 파일 생성, 기본 정보 미리 채우기
TASKS_FILE="$STORY_DIR/tasks.md"
cat > "$TASKS_FILE" << EOF
# 집필 작업 체크리스트

## 작업 개요
- **생성 날짜**: ${CURRENT_DATE}
- **최종 업데이트**: ${CURRENT_DATE}
- **작업 상태**: 생성 대기

---
EOF

# 진도 추적 파일 생성
PROGRESS_FILE="$STORY_DIR/progress.json"
if [ ! -f "$PROGRESS_FILE" ]; then
    cat > "$PROGRESS_FILE" << EOF
{
  "created_at": "${CURRENT_DATETIME}",
  "updated_at": "${CURRENT_DATETIME}",
  "total_chapters": 0,
  "completed": 0,
  "in_progress": 0,
  "word_count": 0
}
EOF
fi

# 결과 출력
echo "TASKS_FILE: $TASKS_FILE"
echo "PROGRESS_FILE: $PROGRESS_FILE"
echo "CURRENT_DATE: $CURRENT_DATE"
echo "STATUS: ready"
