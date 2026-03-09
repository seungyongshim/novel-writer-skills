#!/usr/bin/env bash
# 공용 함수 라이브러리

# 프로젝트 루트 디렉토리 가져오기
get_project_root() {
    if [ -f ".specify/config.json" ]; then
        pwd
    else
        # 상위로 올라가며 .specify 폴더를 찾기
        current=$(pwd)
        while [ "$current" != "/" ]; do
            if [ -f "$current/.specify/config.json" ]; then
                echo "$current"
                return 0
            fi
            current=$(dirname "$current")
        done
        echo "오류: 소설 프로젝트 루트 디렉토리를 찾을 수 없음" >&2
        exit 1
    fi
}

# 현재 스토리 디렉토리 가져오기
get_current_story() {
    PROJECT_ROOT=$(get_project_root)
    STORIES_DIR="$PROJECT_ROOT/stories"

    # 최신 스토리 디렉토리 찾기
    if [ -d "$STORIES_DIR" ]; then
        latest=$(ls -t "$STORIES_DIR" 2>/dev/null | head -1)
        if [ -n "$latest" ]; then
            echo "$STORIES_DIR/$latest"
        fi
    fi
}

# 활성 스토리 이름 가져오기 (이름만 반환, 경로 아님)
get_active_story() {
    story_dir=$(get_current_story)
    if [ -n "$story_dir" ]; then
        basename "$story_dir"
    else
        # 스토리가 없으면 기본 이름 반환
        echo "story-$(date +%Y%m%d)"
    fi
}

# 번호가 붙은 디렉토리 생성
create_numbered_dir() {
    base_dir="$1"
    prefix="$2"

    mkdir -p "$base_dir"

    # 최고 번호 찾기
    highest=0
    for dir in "$base_dir"/*; do
        [ -d "$dir" ] || continue
        dirname=$(basename "$dir")
        number=$(echo "$dirname" | grep -o '^[0-9]\+' || echo "0")
        number=$((10#$number))
        if [ "$number" -gt "$highest" ]; then
            highest=$number
        fi
    done

    # 다음 번호 반환
    next=$((highest + 1))
    printf "%03d" "$next"
}

# JSON 출력 (AI 어시스턴트와 통신용)
output_json() {
    echo "$1"
}

# 파일 존재 확인
ensure_file() {
    file="$1"
    template="$2"

    if [ ! -f "$file" ]; then
        if [ -f "$template" ]; then
            cp "$template" "$file"
        else
            touch "$file"
        fi
    fi
}

# 정확한 글자 수 통계
# Markdown 마크업, 공백, 줄바꿈을 제외하고 실제 내용만 카운트
count_chinese_words() {
    local file="$1"

    if [ ! -f "$file" ]; then
        echo "0"
        return
    fi

    # Markdown 마크업과 서식 기호 제거 후 문자 카운트
    # 1. 코드 블록 제거
    # 2. 제목 마크업 (#) 제거
    # 3. 강조 마크업 (* 및 _) 제거
    # 4. 링크 마크업 ([ ] ( )) 제거
    # 5. 인용 마크업 (>) 제거
    # 6. 목록 마크업 (- *) 제거
    # 7. 공백, 줄바꿈, 탭 제거
    # 8. 남은 문자 수 카운트
    local word_count=$(cat "$file" | \
        sed '/^```/,/^```/d' | \
        sed 's/^#\+[[:space:]]*//' | \
        sed 's/\*\*//g' | \
        sed 's/__//g' | \
        sed 's/\*//g' | \
        sed 's/_//g' | \
        sed 's/\[//g' | \
        sed 's/\]//g' | \
        sed 's/(http[^)]*)//g' | \
        sed 's/^>[[:space:]]*//' | \
        sed 's/^[[:space:]]*[-*][[:space:]]*//' | \
        sed 's/^[[:space:]]*[0-9]\+\.[[:space:]]*//' | \
        tr -d '[:space:]' | \
        tr -d '[:punct:]' | \
        grep -o . | \
        wc -l | \
        tr -d ' ')

    echo "$word_count"
}

# 글자 수 정보 표시
# 매개변수: 파일 경로, 최소 글자 수(선택), 최대 글자 수(선택)
show_word_count_info() {
    local file="$1"
    local min_words="${2:-0}"
    local max_words="${3:-999999}"
    local actual_words=$(count_chinese_words "$file")

    echo "글자 수: $actual_words"

    if [ "$min_words" -gt 0 ]; then
        if [ "$actual_words" -lt "$min_words" ]; then
            echo "⚠️ 최소 글자 수 미달 (최소: ${min_words})"
        elif [ "$actual_words" -gt "$max_words" ]; then
            echo "⚠️ 최대 글자 수 초과 (최대: ${max_words})"
        else
            echo "✅ 글자 수 요건 충족 (${min_words}-${max_words})"
        fi
    fi
}
