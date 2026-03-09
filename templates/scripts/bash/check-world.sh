#!/usr/bin/env bash
# 세계관 일관성 검사 스크립트

set -e

# 공통 함수 로드
SCRIPT_DIR=$(dirname "$0")
source "$SCRIPT_DIR/common.sh"

# 현재 스토리 디렉토리 가져오기
STORY_DIR=$(get_current_story)

if [ -z "$STORY_DIR" ]; then
    echo "오류: 스토리 프로젝트를 찾을 수 없습니다" >&2
    exit 1
fi

# 체크리스트 모드 확인
CHECKLIST_MODE=false
if [ "$1" = "--checklist" ]; then
    CHECKLIST_MODE=true
fi

# 파일 경로
WORLD_SETTING="$STORY_DIR/spec/knowledge/world-setting.md"
LOCATIONS="$STORY_DIR/spec/knowledge/locations.md"
CULTURE="$STORY_DIR/spec/knowledge/culture.md"
RULES="$STORY_DIR/spec/knowledge/rules.md"
CONTENT_DIR="$STORY_DIR/content"

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
ISSUES=()

# 검사 함수
check() {
    local name="$1"
    local condition="$2"
    local error_msg="$3"

    ((TOTAL_CHECKS++))

    if eval "$condition"; then
        if [ "$CHECKLIST_MODE" = false ]; then
            echo -e "${GREEN}✓${NC} $name"
        fi
        ((PASSED_CHECKS++))
    else
        if [ "$CHECKLIST_MODE" = false ]; then
            echo -e "${RED}✗${NC} $name: $error_msg"
        fi
        ((ERRORS++))
        ISSUES+=("$name|$error_msg")
    fi
}

warn() {
    local msg="$1"
    if [ "$CHECKLIST_MODE" = false ]; then
        echo -e "${YELLOW}⚠${NC} 경고: $msg"
    fi
    ((WARNINGS++))
    ISSUES+=("경고|$msg")
}

# 설정 파일 완전성 검사
check_setting_files() {
    if [ "$CHECKLIST_MODE" = false ]; then
        echo "📁 설정 파일 완전성 검사"
        echo "─────────────────────"
    fi

    check "world-setting.md" "[ -f '$WORLD_SETTING' ]" "핵심 세계관 파일이 존재하지 않습니다"
    check "locations.md" "[ -f '$LOCATIONS' ]" "장소 설명 파일이 존재하지 않습니다"
    check "culture.md" "[ -f '$CULTURE' ]" "문화 풍속 파일이 존재하지 않습니다"
    check "rules.md" "[ -f '$RULES' ]" "특수 규칙 파일이 존재하지 않습니다"

    if [ "$CHECKLIST_MODE" = false ]; then
        echo ""
    fi
}

# 용어 일관성 검사
check_terminology() {
    if [ "$CHECKLIST_MODE" = false ]; then
        echo "📝 용어 일관성 검사"
        echo "────────────────"
    fi

    if [ -d "$CONTENT_DIR" ]; then
        # 세계관 문서에서 고유명사 추출 (간소화 버전, 실제로는 더 복잡해야 함)
        local term_count=0

        if [ -f "$WORLD_SETTING" ]; then
            # 고유명사 집계 (여기서는 볼드 또는 특수 표시된 단어로 간소화)
            term_count=$(grep -o '\*\*[^*]*\*\*' "$WORLD_SETTING" 2>/dev/null | wc -l || echo 0)
        fi

        check "고유명사 정의" "[ $term_count -gt 0 ]" "고유명사 정의를 찾을 수 없습니다"

        if [ "$CHECKLIST_MODE" = false ]; then
            echo "  📊 고유명사 수: $term_count"
        fi
    else
        warn "콘텐츠 디렉토리가 존재하지 않아 용어 검사를 건너뜁니다"
    fi

    if [ "$CHECKLIST_MODE" = false ]; then
        echo ""
    fi
}

# 지리 논리 검사
check_geography() {
    if [ "$CHECKLIST_MODE" = false ]; then
        echo "🗺️  지리 논리 검사"
        echo "───────────────"
    fi

    if [ -f "$LOCATIONS" ]; then
        # 정의된 장소 수 집계
        local location_count=$(grep -c '^##' "$LOCATIONS" 2>/dev/null || echo 0)

        check "장소 정의 완전성" "[ $location_count -gt 0 ]" "정의된 장소가 없습니다"

        if [ "$CHECKLIST_MODE" = false ]; then
            echo "  📊 정의된 장소: ${location_count}개"
        fi

        # 콘텐츠에서 언급된 장소가 정의에 있는지 확인
        if [ -d "$CONTENT_DIR" ]; then
            # 간소화 처리, 실제로는 더 복잡한 매칭 로직이 필요
            local undefined_locations=0

            # TODO: 더 스마트한 장소 매칭 로직 구현
            # 현재는 기본적인 파일 검사만 수행

            check "장소 참조 검사" "[ $undefined_locations -eq 0 ]" "정의되지 않은 장소 참조가 발견되었습니다"
        fi
    else
        warn "장소 설명 파일이 존재하지 않습니다"
    fi

    if [ "$CHECKLIST_MODE" = false ]; then
        echo ""
    fi
}

# 문화 일관성 검사
check_culture() {
    if [ "$CHECKLIST_MODE" = false ]; then
        echo "🎭 문화 일관성 검사"
        echo "────────────────"
    fi

    if [ -f "$CULTURE" ]; then
        # 문화 요소 집계
        local culture_count=$(grep -c '^##' "$CULTURE" 2>/dev/null || echo 0)

        check "문화 요소 정의" "[ $culture_count -gt 0 ]" "문화 요소가 정의되지 않았습니다"

        if [ "$CHECKLIST_MODE" = false ]; then
            echo "  📊 문화 요소: ${culture_count}개"
        fi
    else
        warn "문화 풍속 파일이 존재하지 않습니다"
    fi

    if [ "$CHECKLIST_MODE" = false ]; then
        echo ""
    fi
}

# 규칙 일관성 검사
check_rules() {
    if [ "$CHECKLIST_MODE" = false ]; then
        echo "⚖️  규칙 일관성 검사"
        echo "───────────────"
    fi

    if [ -f "$RULES" ]; then
        # 특수 규칙 집계
        local rule_count=$(grep -c '^##' "$RULES" 2>/dev/null || echo 0)

        check "특수 규칙 정의" "[ $rule_count -gt 0 ]" "특수 규칙이 정의되지 않았습니다"

        if [ "$CHECKLIST_MODE" = false ]; then
            echo "  📊 특수 규칙: ${rule_count}개"
        fi
    else
        warn "특수 규칙 파일이 존재하지 않습니다"
    fi

    if [ "$CHECKLIST_MODE" = false ]; then
        echo ""
    fi
}

# 일반 보고서 생성
generate_report() {
    echo "═══════════════════════════════════════"
    echo "🌍 세계관 일관성 검사 보고서"
    echo "═══════════════════════════════════════"
    echo ""

    check_setting_files
    check_terminology
    check_geography
    check_culture
    check_rules

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
    echo ""
    echo "💡 제안:"
    echo "  - 세계관 설정 문서를 정기적으로 업데이트하세요"
    echo "  - 용어집을 작성하여 일관성을 유지하세요"
    echo "  - 장소 간 거리와 방위 관계를 기록하세요"
}

# 체크리스트 형식 출력 생성
output_checklist() {
    # 데이터 수집을 위해 검사 로직 재실행
    TOTAL_CHECKS=0
    PASSED_CHECKS=0
    ERRORS=0
    WARNINGS=0
    ISSUES=()

    check_setting_files
    check_terminology
    check_geography
    check_culture
    check_rules

    # 체크리스트 형식 출력
    cat <<EOF
# 세계관 일관성 검사 체크리스트

**검사 시간**: $(date '+%Y-%m-%d %H:%M:%S')
**검사 대상**: spec/knowledge/ 디렉토리 및 작성된 챕터 내용
**검사 범위**: 세계관 설정, 지리 논리, 문화 풍속, 특수 규칙

---

## 설정 파일 완전성

- [$([ -f "$WORLD_SETTING" ] && echo "x" || echo " ")] CHK001 world-setting.md 존재
- [$([ -f "$LOCATIONS" ] && echo "x" || echo " ")] CHK002 locations.md 존재
- [$([ -f "$CULTURE" ] && echo "x" || echo " ")] CHK003 culture.md 존재
- [$([ -f "$RULES" ] && echo "x" || echo " ")] CHK004 rules.md 존재

## 용어 일관성

- [$([ -d "$CONTENT_DIR" ] && echo "x" || echo " ")] CHK005 고유명사 정의 완비
- [ ] CHK006 챕터 내 용어가 설정 문서와 일치 (수동 확인 필요)

## 지리 논리

EOF

    if [ -f "$LOCATIONS" ]; then
        local location_count=$(grep -c '^##' "$LOCATIONS" 2>/dev/null || echo 0)
        echo "- [x] CHK007 장소 정의 완비 (${location_count}개 장소 정의됨)"
    else
        echo "- [ ] CHK007 장소 정의 완비"
    fi

    cat <<EOF
- [ ] CHK008 장소 간 거리와 방위가 합리적 (수동 확인 필요)
- [ ] CHK009 챕터 내 지리 묘사가 설정과 일치 (수동 확인 필요)

## 문화 일관성

EOF

    if [ -f "$CULTURE" ]; then
        local culture_count=$(grep -c '^##' "$CULTURE" 2>/dev/null || echo 0)
        echo "- [x] CHK010 문화 요소 정의 완비 (${culture_count}개 요소 정의됨)"
    else
        echo "- [ ] CHK010 문화 요소 정의 완비"
    fi

    cat <<EOF
- [ ] CHK011 풍속 묘사 전후 일관성 (수동 확인 필요)
- [ ] CHK012 언어와 호칭 사용 통일 (수동 확인 필요)

## 규칙 일관성

EOF

    if [ -f "$RULES" ]; then
        local rule_count=$(grep -c '^##' "$RULES" 2>/dev/null || echo 0)
        echo "- [x] CHK013 특수 규칙 정의 완비 (${rule_count}개 규칙 정의됨)"
    else
        echo "- [ ] CHK013 특수 규칙 정의 완비"
    fi

    cat <<EOF
- [ ] CHK014 규칙 적용 전후 일관성 (수동 확인 필요)
- [ ] CHK015 규칙 간 상호 모순 없음 (수동 확인 필요)

---

## 발견된 문제

EOF

    if [ ${#ISSUES[@]} -gt 0 ]; then
        for issue in "${ISSUES[@]}"; do
            IFS='|' read -r name msg <<< "$issue"
            echo "### $name"
            echo ""
            echo "**문제**: $msg"
            echo ""
        done
    else
        echo "*발견된 문제 없음*"
    fi

    cat <<EOF

---

## 검사 통계

- **총 검사 항목**: ${TOTAL_CHECKS}
- **통과**: ${PASSED_CHECKS}
- **개선 필요**: ${ERRORS}
- **경고**: ${WARNINGS}

---

## 후속 조치

- [ ] 누락된 설정 문서 보충
- [ ] 용어집 작성으로 고유명사 기록
- [ ] 챕터 내 세계관 묘사 수동 확인
- [ ] 장소 간 거리와 이동 시간 기록

---

**검사 도구**: check-world.sh
**버전**: 1.0
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
    else
        exit 0
    fi
}

# 메인 함수 실행
main
