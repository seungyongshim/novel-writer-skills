#!/usr/bin/env bash
# 캐릭터 관계 관리 (Bash)

set -e

SCRIPT_DIR=$(dirname "$0")
source "$SCRIPT_DIR/common.sh"

PROJECT_ROOT=$(get_project_root)
STORY_DIR=$(get_current_story)

REL_FILE=""
if [ -n "$STORY_DIR" ] && [ -f "$STORY_DIR/spec/tracking/relationships.json" ]; then
  REL_FILE="$STORY_DIR/spec/tracking/relationships.json"
elif [ -f "$PROJECT_ROOT/spec/tracking/relationships.json" ]; then
  REL_FILE="$PROJECT_ROOT/spec/tracking/relationships.json"
else
  # 템플릿으로 초기화 시도
  mkdir -p "$PROJECT_ROOT/spec/tracking"
  if [ -f "$PROJECT_ROOT/.specify/templates/tracking/relationships.json" ]; then
    cp "$PROJECT_ROOT/.specify/templates/tracking/relationships.json" "$PROJECT_ROOT/spec/tracking/relationships.json"
    REL_FILE="$PROJECT_ROOT/spec/tracking/relationships.json"
  elif [ -f "$SCRIPT_DIR/../../templates/tracking/relationships.json" ]; then
    cp "$SCRIPT_DIR/../../templates/tracking/relationships.json" "$PROJECT_ROOT/spec/tracking/relationships.json"
    REL_FILE="$PROJECT_ROOT/spec/tracking/relationships.json"
  else
    echo "❌ relationships.json을 찾을 수 없으며, 템플릿에서 생성할 수도 없음" >&2
    exit 1
  fi
fi

CMD=${1:-show}
shift || true

print_header() {
  echo "👥 캐릭터 관계 관리"
  echo "━━━━━━━━━━━━━━━━━━━━"
}

cmd_show() {
  print_header
  if ! jq empty "$REL_FILE" >/dev/null 2>&1; then
    echo "❌ relationships.json 형식이 유효하지 않음" >&2; exit 1
  fi

  echo "파일: $REL_FILE"
  echo ""
  # 주인공 또는 첫 번째 캐릭터 관계 요약 출력
  local main_char=$(jq -r '.characters | keys[0] // ""' "$REL_FILE")
  if [ -z "$main_char" ] || [ "$main_char" = "null" ]; then
    echo "캐릭터 기록 없음"
    exit 0
  fi
  echo "주인공: $main_char"
  # 두 가지 구조 지원: 중첩된 relationships 또는 직접 분류 키
  jq -r --arg name "$main_char" '
    .characters[$name] as $c | 
    ($c.relationships // $c) as $r |
    [
      {k:"romantic", v:($r.romantic // [])},
      {k:"allies", v:($r.allies // [])},
      {k:"mentors", v:($r.mentors // [])},
      {k:"enemies", v:($r.enemies // [])},
      {k:"family", v:($r.family // [])},
      {k:"neutral", v:($r.neutral // [])}
    ] | .[] | select((.v|length)>0) |
    "├─ " + (if .k=="romantic" then "💕 연인" elseif .k=="allies" then "🤝 동맹" elseif .k=="mentors" then "📚 스승" elseif .k=="enemies" then "⚔️ 적대" elseif .k=="family" then "👪 가족" else "・ 관계" end) + ": " + (.v | join(", "))
  ' "$REL_FILE"

  # 최근 변화
  echo ""
  if jq -e '.history' "$REL_FILE" >/dev/null 2>&1; then
    local recent=$(jq -r '.history[-1] // empty' "$REL_FILE")
    if [ -n "$recent" ]; then
      echo "최근 변화:"
      jq -r '.history[-1].changes[]? | "- " + (.characters|join("↔")) + ": " + (.relation // .type // "변화")' "$REL_FILE"
    fi
  elif jq -e '.relationshipChanges' "$REL_FILE" >/dev/null 2>&1; then
    echo "최근 변화:"
    jq -r '.relationshipChanges[-5:][]? | "- " + (.type // "변화") + ": " + (.characters|join("↔"))' "$REL_FILE" 2>/dev/null || true
  fi
}

cmd_update() {
  local a="$1"; local rel="$2"; local b="$3"; shift 3 || true
  local chapter=""; local note=""
  while [ $# -gt 0 ]; do
    case "$1" in
      --chapter) chapter="$2"; shift 2;;
      --note) note="$2"; shift 2;;
      *) shift;;
    esac
  done
  if [ -z "$a" ] || [ -z "$rel" ] || [ -z "$b" ]; then
    echo "사용법: manage-relations.sh update <인물A> <allies|enemies|romantic|neutral|family|mentors> <인물B> [--chapter N] [--note 설명]" >&2
    exit 1
  fi

  # 캐릭터 노드 존재 확인
  for name in "$a" "$b"; do
    if ! jq --arg n "$name" '(.characters[$n] // null) != null' "$REL_FILE" | grep -q true; then
      tmp=$(mktemp)
      jq --arg n "$name" '.characters[$n] = (.characters[$n] // {name:$n, relationships:{allies:[],enemies:[],romantic:[],family:[],mentors:[],neutral:[]}})' "$REL_FILE" > "$tmp"
      mv "$tmp" "$REL_FILE"
    fi
  done

  # 관계 기록
  tmp=$(mktemp)
  jq --arg a "$a" --arg b "$b" --arg rel "$rel" '
    .characters[$a].relationships[$rel] = ((.characters[$a].relationships[$rel] // []) + [$b] | unique) |
    .lastUpdated = now | todate
  ' "$REL_FILE" > "$tmp"
  mv "$tmp" "$REL_FILE"

  # 이력 기록 (history 우선, 아니면 relationshipChanges)
  local now=$(date -Iseconds)
  if jq -e '.history' "$REL_FILE" >/dev/null 2>&1; then
    tmp=$(mktemp)
    jq --arg ch "${chapter:-null}" --arg a "$a" --arg b "$b" --arg rel "$rel" --arg note "$note" --arg t "$now" '
      .history += [{
        chapter: ( ($ch|tonumber) // null ),
        date: $t,
        changes: [{ type: "update", characters: [$a,$b], relation: $rel, note: ($note // "") }]
      }]
    ' "$REL_FILE" > "$tmp" && mv "$tmp" "$REL_FILE"
  else
    tmp=$(mktemp)
    jq --arg a "$a" --arg b "$b" --arg rel "$rel" '.relationshipChanges += [{type:"update", characters:[$a,$b], relation:$rel}]' "$REL_FILE" > "$tmp" && mv "$tmp" "$REL_FILE"
  fi

  echo "✅ 관계 업데이트 완료: $a [$rel] $b"
}

cmd_history() {
  print_header
  if jq -e '.history' "$REL_FILE" >/dev/null 2>&1; then
    jq -r '.history[] | "제" + ((.chapter // 0|tostring)) + "장: " + (.changes | map((.characters|join("↔"))+"→"+(.relation // .type)) | join("; "))' "$REL_FILE"
  elif jq -e '.relationshipChanges' "$REL_FILE" >/dev/null 2>&1; then
    jq -r '.relationshipChanges[] | (.date // "") + " " + (.type // "") + ": " + (.characters|join("↔")) + "→" + (.relation // "")' "$REL_FILE"
  else
    echo "이력 기록 없음"
  fi
}

cmd_check() {
  print_header
  local issues=0
  # 모든 참조된 캐릭터가 characters에 존재하는지 확인
  missing=$(jq -r '
    .characters as $c |
    [
      .characters | to_entries[] | .value.relationships // empty |
      to_entries[] | .value[]
    ] | flatten | unique | map(select(has(.) | not))
  ' "$REL_FILE" 2>/dev/null || true)
  if [ -n "$missing" ]; then
    echo "⚠️  등록되지 않은 캐릭터 참조 발견, 보완 권장:"
    echo "$missing"
    issues=1
  fi
  if [ "$issues" -eq 0 ]; then
    echo "✅ 관계 데이터 검사 통과"
  fi
}

case "$CMD" in
  show) cmd_show ;;
  update) cmd_update "$@" ;;
  history) cmd_history ;;
  check) cmd_check ;;
  *) echo "사용법: $0 [show|update|history|check]" >&2; exit 1;;
esac
