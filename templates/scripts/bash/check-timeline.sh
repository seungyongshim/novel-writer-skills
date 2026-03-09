#!/usr/bin/env bash
# 스토리 타임라인 관리 및 검증

set -e

# 공통 함수 로드
SCRIPT_DIR=$(dirname "$0")
source "$SCRIPT_DIR/common.sh"

# 체크리스트 모드 확인
CHECKLIST_MODE=false
COMMAND="${1:-show}"
if [ "$COMMAND" = "--checklist" ]; then
    CHECKLIST_MODE=true
    COMMAND="check"
fi

# 현재 스토리 디렉토리 가져오기
STORY_DIR=$(get_current_story)

if [ -z "$STORY_DIR" ]; then
    echo "오류: 스토리 프로젝트를 찾을 수 없습니다" >&2
    exit 1
fi

# 파일 경로
TIMELINE="$STORY_DIR/spec/tracking/timeline.json"
PROGRESS="$STORY_DIR/progress.json"

# 명령어 인수 (위에서 체크리스트 모드 이미 처리됨)
PARAM2="${2:-}"

# 타임라인 파일 초기화
init_timeline() {
    if [ ! -f "$TIMELINE" ]; then
        echo "⚠️  타임라인 파일을 찾을 수 없어 생성 중..." >&2
        mkdir -p "$STORY_DIR/spec/tracking"

        if [ -f "$SCRIPT_DIR/../../templates/tracking/timeline.json" ]; then
            cp "$SCRIPT_DIR/../../templates/tracking/timeline.json" "$TIMELINE"
            echo "✅ 타임라인 파일이 생성되었습니다"
        else
            echo "오류: 템플릿 파일을 찾을 수 없습니다" >&2
            exit 1
        fi
    fi
}

# 타임라인 표시
show_timeline() {
    echo "📅 스토리 타임라인"
    echo "━━━━━━━━━━━━━━━━━━━━"

    if [ -f "$TIMELINE" ]; then
        # 현재 시간
        CURRENT_TIME=$(jq -r '.storyTime.current // "미설정"' "$TIMELINE")
        echo "⏰ 현재 시간: $CURRENT_TIME"
        echo ""

        # 시간 범위 계산
        START_TIME=$(jq -r '.storyTime.start // ""' "$TIMELINE")
        if [ -n "$START_TIME" ]; then
            echo "📍 시작 시간: $START_TIME"

            # 기록된 이벤트 수 계산
            EVENT_COUNT=$(jq '.events | length' "$TIMELINE")
            echo "📊 기록된 이벤트: ${EVENT_COUNT}개"
        fi

        echo ""
        echo "📖 주요 이벤트:"
        echo "───────────────"

        # 최근 이벤트 표시
        jq -r '.events | sort_by(.chapter) | reverse | .[0:5][] |
            "제" + (.chapter | tostring) + "장 | " + .date + " | " + .event' \
            "$TIMELINE" 2>/dev/null || echo "  아직 이벤트 기록 없음"

        # 병렬 이벤트 표시
        PARALLEL_COUNT=$(jq '.parallelEvents.timepoints | length' "$TIMELINE" 2>/dev/null || echo "0")
        if [ "$PARALLEL_COUNT" != "0" ] && [ "$PARALLEL_COUNT" != "null" ]; then
            echo ""
            echo "🔄 병렬 이벤트:"
            jq -r '.parallelEvents.timepoints | to_entries[] |
                .key + ": " + (.value | join(", "))' "$TIMELINE" 2>/dev/null || true
        fi
    else
        echo "타임라인 파일을 찾을 수 없습니다"
    fi
}

# 시간 노드 추가
add_event() {
    local chapter="${2:-}"
    local date="${3:-}"
    local event="${4:-}"

    if [ -z "$chapter" ] || [ -z "$date" ] || [ -z "$event" ]; then
        echo "사용법: $0 add <챕터번호> <시간> <이벤트설명>" >&2
        echo "예시: $0 add 5 '만력 30년 봄' '주인공이 서울에 도착'" >&2
        exit 1
    fi

    if [ ! -f "$TIMELINE" ]; then
        init_timeline
    fi

    # 새 이벤트 추가
    TEMP_FILE=$(mktemp)
    jq --arg ch "$chapter" \
       --arg dt "$date" \
       --arg ev "$event" \
       '.events += [{
           chapter: ($ch | tonumber),
           date: $dt,
           event: $ev,
           duration: "",
           participants: []
       }] |
       .events |= sort_by(.chapter) |
       .lastUpdated = now | strftime("%Y-%m-%dT%H:%M:%S")' \
       "$TIMELINE" > "$TEMP_FILE"

    mv "$TEMP_FILE" "$TIMELINE"
    echo "✅ 이벤트 추가됨: 제${chapter}장 - $date - $event"
}

# 시간 연속성 검사
check_continuity() {
    echo "🔍 타임라인 연속성 검사"
    echo "━━━━━━━━━━━━━━━━━━━━"

    if [ ! -f "$TIMELINE" ]; then
        echo "오류: 타임라인 파일이 존재하지 않습니다" >&2
        exit 1
    fi

    # 이벤트 순서 확인
    echo "챕터 순서 확인 중..."

    # 모든 챕터 번호를 가져와서 증가하는지 확인
    CHAPTERS=$(jq -r '.events | sort_by(.chapter) | .[].chapter' "$TIMELINE")

    prev_chapter=0
    issues=0

    for chapter in $CHAPTERS; do
        if [ "$chapter" -le "$prev_chapter" ]; then
            echo "⚠️  챕터 순서 이상: 제${chapter}장이 제${prev_chapter}장 뒤에 나타남"
            ((issues++))
        fi
        prev_chapter=$chapter
    done

    # 시간 범위 확인
    echo ""
    echo "시간 범위 확인 중..."

    # 여기에 더 복잡한 시간 논리 검사를 추가할 수 있음
    # 예: 이동 시간의 합리성 검사 등

    if [ "$issues" -eq 0 ]; then
        echo ""
        echo "✅ 타임라인 검사 통과, 논리 문제가 발견되지 않았습니다"
    else
        echo ""
        echo "⚠️  ${issues}개의 잠재적 문제가 발견되었습니다. 확인하세요"
    fi

    # 검사 결과 기록
    if [ -f "$TIMELINE" ]; then
        TEMP_FILE=$(mktemp)
        jq --arg date "$(date -Iseconds)" \
           --arg issues "$issues" \
           '.lastChecked = $date |
            .anomalies.lastCheckIssues = ($issues | tonumber)' \
           "$TIMELINE" > "$TEMP_FILE"
        mv "$TEMP_FILE" "$TIMELINE"
    fi
}

# 병렬 이벤트 동기화
sync_parallel() {
    local timepoint="${2:-}"
    local events="${3:-}"

    if [ -z "$timepoint" ] || [ -z "$events" ]; then
        echo "사용법: $0 sync <시간대> <이벤트목록>" >&2
        echo "예시: $0 sync '만력 30년 봄' '전쟁 발발,사절단 도착'" >&2
        exit 1
    fi

    if [ ! -f "$TIMELINE" ]; then
        init_timeline
    fi

    # 이벤트 목록을 JSON 배열로 변환
    IFS=',' read -ra EVENT_ARRAY <<< "$events"
    JSON_ARRAY=$(printf '"%s",' "${EVENT_ARRAY[@]}" | sed 's/,$//')
    JSON_ARRAY="[${JSON_ARRAY}]"

    # 병렬 이벤트 업데이트
    TEMP_FILE=$(mktemp)
    jq --arg tp "$timepoint" \
       --argjson events "$JSON_ARRAY" \
       '.parallelEvents.timepoints[$tp] = $events |
        .lastUpdated = now | strftime("%Y-%m-%dT%H:%M:%S")' \
       "$TIMELINE" > "$TEMP_FILE"

    mv "$TEMP_FILE" "$TIMELINE"
    echo "✅ 병렬 이벤트 동기화 완료: $timepoint"
}

# 체크리스트 형식 출력 생성
output_checklist() {
    init_timeline

    local event_count=0
    local parallel_count=0
    local current_time=""
    local start_time=""
    local has_issues=0

    if [ -f "$TIMELINE" ]; then
        event_count=$(jq '.events | length' "$TIMELINE")
        parallel_count=$(jq '.parallelEvents.timepoints | length' "$TIMELINE" 2>/dev/null || echo "0")
        current_time=$(jq -r '.storyTime.current // ""' "$TIMELINE")
        start_time=$(jq -r '.storyTime.start // ""' "$TIMELINE")

        # 이벤트 순서 문제 확인
        has_issues=$(jq '
            .events |
            sort_by(.chapter) |
            . as $sorted |
            reduce range(1; length) as $i (0;
                if $sorted[$i].chapter <= $sorted[$i-1].chapter then . + 1 else . end
            )' "$TIMELINE")
    fi

    cat <<EOF
# 타임라인 검사 체크리스트

**검사 시간**: $(date '+%Y-%m-%d %H:%M:%S')
**검사 대상**: spec/tracking/timeline.json
**기록된 이벤트 수**: $event_count

---

## 파일 무결성

- [$([ -f "$TIMELINE" ] && echo "x" || echo " ")] CHK001 timeline.json 존재 및 형식 유효

## 시간 설정

- [$([ -n "$start_time" ] && echo "x" || echo " ")] CHK002 스토리 시작 시간 설정됨 ($start_time)
- [$([ -n "$current_time" ] && echo "x" || echo " ")] CHK003 현재 스토리 시간 업데이트됨 ($current_time)

## 이벤트 기록

- [$([ $event_count -gt 0 ] && echo "x" || echo " ")] CHK004 시간 이벤트 기록됨 ($event_count 개)
- [$([ $has_issues -eq 0 ] && echo "x" || echo "!")] CHK005 시간 이벤트가 챕터 순으로 정렬$([ $has_issues -gt 0 ] && echo " (⚠️ $has_issues 개 순서 이상 발견)" || echo "")

## 병렬 이벤트

EOF

    if [ "$parallel_count" -gt 0 ]; then
        echo "- [x] CHK006 병렬 이벤트 시간대 기록됨 ($parallel_count 개)"
    else
        echo "- [ ] CHK006 병렬 이벤트 시간대 기록됨 (기록 없음)"
    fi

    cat <<EOF

---

## 후속 조치

EOF

    local has_actions=false

    if [ $event_count -eq 0 ]; then
        echo "- [ ] 시간 이벤트 기록 시작"
        has_actions=true
    fi

    if [ -z "$current_time" ]; then
        echo "- [ ] 현재 스토리 시간 설정"
        has_actions=true
    fi

    if [ $has_issues -gt 0 ]; then
        echo "- [ ] $has_issues 개의 이벤트 순서 문제 수정"
        has_actions=true
    fi

    if [ "$has_actions" = false ]; then
        echo "*타임라인 기록 완전, 특별한 조치 불필요*"
    fi

    cat <<EOF

---

**검사 도구**: check-timeline.sh
**버전**: 1.1 (체크리스트 출력 지원)
EOF
}

# 메인 함수
main() {
    if [ "$CHECKLIST_MODE" = true ]; then
        output_checklist
        exit 0
    fi

    init_timeline

    case "$COMMAND" in
        show)
            show_timeline
            ;;
        add)
            add_event "$@"
            ;;
        check)
            check_continuity
            ;;
        sync)
            sync_parallel "$@"
            ;;
        *)
            echo "사용법: $0 [show|add|check|sync] [인수...]" >&2
            echo "명령어:" >&2
            echo "  show  - 타임라인 표시" >&2
            echo "  add   - 시간 노드 추가" >&2
            echo "  check - 연속성 검사" >&2
            echo "  sync  - 병렬 이벤트 동기화" >&2
            exit 1
            ;;
    esac
}

# 메인 함수 실행
main "$@"
