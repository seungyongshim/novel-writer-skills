#!/bin/bash

# track-progress.sh - 소설 창작 진행도 종합 추적
# --check 심층 검증 및 --fix 자동 수정 지원

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# 색상 출력
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 인수 파싱
MODE="report"  # 기본 모드
if [[ "$1" == "--check" ]]; then
    MODE="check"
elif [[ "$1" == "--fix" ]]; then
    MODE="fix"
elif [[ "$1" == "--brief" ]]; then
    MODE="brief"
elif [[ "$1" == "--plot" ]]; then
    MODE="plot"
elif [[ "$1" == "--stats" ]]; then
    MODE="stats"
fi

echo -e "${BLUE}📊 추적 분석 실행 중...${NC}"
echo ""

# 기본 파일 존재 여부 확인
check_files() {
    local has_files=false

    if [[ -f "stories/current/progress.json" ]]; then
        has_files=true
    fi

    if [[ -f "spec/tracking/plot-tracker.json" ]]; then
        has_files=true
    fi

    if [[ "$has_files" == false ]]; then
        echo -e "${YELLOW}⚠️ 추적 파일을 찾을 수 없습니다. 먼저 프로젝트를 초기화하세요${NC}"
        exit 1
    fi
}

# 기본 보고서 기능
show_basic_report() {
    echo -e "${GREEN}📖 소설 창작 종합 보고서${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    # 진행 정보 읽기
    if [[ -f "stories/current/progress.json" ]]; then
        echo -e "${BLUE}✍️ 집필 진행도${NC}"
        # AI가 진행 정보를 읽고 표시함
        echo "  챕터 완료 상황 분석 대기 중..."
    fi

    # 줄거리 추적 읽기
    if [[ -f "spec/tracking/plot-tracker.json" ]]; then
        echo -e "${BLUE}📍 줄거리 상태${NC}"
        echo "  메인 스토리 진행도 분석 대기 중..."
    fi

    echo ""
}

# 심층 검증 모드
run_deep_check() {
    echo -e "${GREEN}🔍 심층 검증 실행 중...${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    # Phase 1: 기본 검증
    echo -e "${BLUE}Phase 1: 기본 검증${NC}"
    echo "  [P] 줄거리 일관성 검사 실행..."
    echo "  [P] 타임라인 검증 실행..."
    echo "  [P] 관계 검증 실행..."
    echo "  [P] 세계관 검증 실행..."

    # Phase 2: 캐릭터 심층 검증
    echo -e "${BLUE}Phase 2: 캐릭터 심층 검증${NC}"

    # 검증 규칙 파일 확인
    if [[ -f "spec/tracking/validation-rules.json" ]]; then
        echo "  ✅ 검증 규칙 로드 완료"
        echo "  챕터 내 캐릭터 이름 스캔 중..."
        echo "  character-state.json과 대조 중..."
        echo "  호칭 정확성 확인 중..."

        # 검증 작업 생성 (내부 사용)
        cat << EOF > /tmp/validation-tasks.md
# 검증 작업 (자동 생성)

## Phase 1: 기본 검증 [병렬]
- [ ] T001 [P] plot-check 로직 실행
- [ ] T002 [P] timeline 로직 실행
- [ ] T003 [P] relations 로직 실행
- [ ] T004 [P] world-check 로직 실행

## Phase 2: 캐릭터 검증
- [ ] T005 validation-rules.json 로드
- [ ] T006 챕터 내 캐릭터 이름 스캔
- [ ] T007 이름 일관성 검증
- [ ] T008 호칭 정확성 확인
- [ ] T009 행동 일관성 검증

## Phase 3: 보고서 생성
- [ ] T010 결과 취합
- [ ] T011 문제 표시
- [ ] T012 개선 제안 생성
EOF

        echo -e "${GREEN}  ✅ 검증 작업 생성 완료${NC}"
    else
        echo -e "${YELLOW}  ⚠️ 검증 규칙 파일을 찾을 수 없습니다${NC}"
        echo "  spec/tracking/validation-rules.json 생성을 권장합니다"
    fi

    # Phase 3: 보고서 생성
    echo -e "${BLUE}Phase 3: 검증 보고서 생성${NC}"
    echo ""
    echo "📊 심층 검증 보고서"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "AI가 모든 챕터를 분석하여 상세 보고서를 생성합니다..."
    echo ""
    echo -e "${YELLOW}💡 팁: 문제 발견 시 $0 --fix 를 실행하여 자동 수정할 수 있습니다${NC}"
}

# 자동 수정 모드
run_auto_fix() {
    echo -e "${GREEN}🔧 자동 수정 실행 중...${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    if [[ ! -f "spec/tracking/validation-rules.json" ]]; then
        echo -e "${RED}❌ 먼저 --check 를 실행하여 검증 보고서를 생성해야 합니다${NC}"
        exit 1
    fi

    # 수정 작업 생성
    cat << EOF > /tmp/fix-tasks.md
# 수정 작업 (자동 생성)

## Phase 1: 간단한 수정 [자동 가능]
- [ ] F001 검증 보고서 읽기
- [ ] F002 [P] 캐릭터 이름 오류 수정
- [ ] F003 [P] 호칭 오류 수정
- [ ] F004 [P] 간단한 오탈자 수정

## Phase 2: 보고서 생성
- [ ] F005 수정 결과 취합
- [ ] F006 추적 파일 업데이트
EOF

    echo "  수정 작업 생성 중..."
    echo "  자동 수정 실행 중..."
    echo ""
    echo "🔧 자동 수정 보고서"
    echo "━━━━━━━━━━━━━━━━━━━"
    echo "AI가 간단한 문제를 자동으로 수정합니다..."
    echo ""
    echo -e "${GREEN}수정 완료 후 $0 --check 를 다시 실행하여 검증하는 것을 권장합니다${NC}"
}

# 메인 실행 로직
check_files

case $MODE in
    "check")
        run_deep_check
        ;;
    "fix")
        run_auto_fix
        ;;
    "brief"|"plot"|"stats")
        echo "${MODE} 모드 보고서 표시 중..."
        show_basic_report
        ;;
    *)
        show_basic_report
        echo -e "${BLUE}💡 사용 가능한 옵션：${NC}"
        echo "  --check : 모든 내용 심층 검증"
        echo "  --fix   : 간단한 문제 자동 수정"
        echo "  --brief : 요약 정보 표시"
        echo "  --plot  : 줄거리 추적만 표시"
        echo "  --stats : 통계 데이터만 표시"
        ;;
esac

echo ""
echo -e "${GREEN}✅ 추적 분석 완료${NC}"
