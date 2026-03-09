#!/bin/bash

# 소설 창작 헌법 관리 스크립트
# /constitution 명령용

set -e

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# 명령 매개변수 가져오기
COMMAND="${1:-check}"

# Get project root
PROJECT_ROOT=$(get_project_root)
cd "$PROJECT_ROOT"

# 파일 경로 정의
CONSTITUTION_FILE=".specify/memory/constitution.md"

case "$COMMAND" in
    check)
        # 헌법 파일 존재 여부 확인
        if [ -f "$CONSTITUTION_FILE" ]; then
            echo "✅ 헌법 파일이 이미 존재: $CONSTITUTION_FILE"
            # 버전 정보 추출
            VERSION=$(grep -E "^- 버전:" "$CONSTITUTION_FILE" 2>/dev/null | cut -d':' -f2 | tr -d ' ' || echo "알 수 없음")
            UPDATED=$(grep -E "^- 최종 수정:" "$CONSTITUTION_FILE" 2>/dev/null | cut -d':' -f2 | tr -d ' ' || echo "알 수 없음")
            echo "  버전: $VERSION"
            echo "  최종 수정: $UPDATED"
            exit 0
        else
            echo "❌ 헌법 파일이 아직 생성되지 않음"
            echo "  제안: /constitution을 실행하여 창작 헌법을 생성하세요"
            exit 1
        fi
        ;;

    init)
        # 헌법 파일 초기화
        mkdir -p "$(dirname "$CONSTITUTION_FILE")"

        if [ -f "$CONSTITUTION_FILE" ]; then
            echo "헌법 파일이 이미 존재, 업데이트 준비"
        else
            echo "새 헌법 파일 생성 준비"
        fi
        ;;

    validate)
        # 헌법 파일 형식 검증
        if [ ! -f "$CONSTITUTION_FILE" ]; then
            echo "오류: 헌법 파일이 존재하지 않음"
            exit 1
        fi

        echo "헌법 파일 검증 중..."

        # 필수 섹션 확인
        REQUIRED_SECTIONS=("핵심 가치관" "품질 기준" "창작 스타일" "내용 규범" "독자 약속")
        MISSING_SECTIONS=()

        for section in "${REQUIRED_SECTIONS[@]}"; do
            if ! grep -q "## .* $section" "$CONSTITUTION_FILE"; then
                MISSING_SECTIONS+=("$section")
            fi
        done

        if [ ${#MISSING_SECTIONS[@]} -gt 0 ]; then
            echo "⚠️ 다음 섹션이 누락됨:"
            for section in "${MISSING_SECTIONS[@]}"; do
                echo "  - $section"
            done
        else
            echo "✅ 모든 필수 섹션이 존재"
        fi

        # 버전 정보 확인
        if grep -q "^- 버전:" "$CONSTITUTION_FILE"; then
            echo "✅ 버전 정보 완전"
        else
            echo "⚠️ 버전 정보 누락"
        fi
        ;;

    export)
        # 헌법 요약 내보내기
        if [ ! -f "$CONSTITUTION_FILE" ]; then
            echo "오류: 헌법 파일이 존재하지 않음"
            exit 1
        fi

        echo "# 창작 헌법 요약"
        echo ""

        # 핵심 원칙 추출
        echo "## 핵심 원칙"
        grep -A 1 "^### 원칙" "$CONSTITUTION_FILE" | grep "^**선언**" | cut -d':' -f2- || echo "(원칙 선언을 찾을 수 없음)"

        echo ""
        echo "## 품질 최저선"
        grep -A 1 "^### 기준" "$CONSTITUTION_FILE" | grep "^**요구**" | cut -d':' -f2- || echo "(품질 기준을 찾을 수 없음)"

        echo ""
        echo "자세한 내용은 다음을 참조: $CONSTITUTION_FILE"
        ;;

    *)
        echo "알 수 없는 명령: $COMMAND"
        echo "지원되는 명령: check, init, validate, export"
        exit 1
        ;;
esac
