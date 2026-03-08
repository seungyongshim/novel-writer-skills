# Novel Writer Skills 입문 가이드

**Novel Writer Skills**에 오신 것을 환영합니다 - Claude Code를 위해 설계된 AI 소설 창작 도구입니다!

## 빠른 시작

### 1. 설치

```bash
npm install -g novel-writer-skills
```

### 2. 첫 번째 프로젝트 만들기

```bash
# 새 프로젝트 생성
novelwrite init my-first-novel

# 프로젝트 디렉토리로 이동
cd my-first-novel
```

### 3. Claude Code에서 열기

Claude Code에서 프로젝트 폴더를 열면 다음을 볼 수 있습니다:

```
my-first-novel/
├── .claude/
│   ├── commands/      # 13개의 Slash 명령
│   └── skills/        # 7개의 Agent Skills
├── .specify/
├── stories/
└── spec/
```

## 7단계 창작 프로세스

### 1단계: 창작 헌법 만들기

Claude Code에서 입력:

```
/constitution
```

다음을 정의하도록 안내합니다:
- ✅ 핵심 창작 원칙
- ✅ 품질 기준
- ✅ 스타일 선호
- ✅ 콘텐츠 규범

**예상 시간**: 15-20분

### 2단계: 스토리 규격 정의

```
/specify
```

스토리를 명확히 합니다:
- 📖 한 줄 요약
- 👥 타겟 독자
- ⚔️ 핵심 갈등
- 👤 주요 캐릭터
- 🎯 성공 기준

**예상 시간**: 30-45분

### 3단계: 모호한 점 명확화

```
/clarify
```

AI가 5가지 핵심 질문으로 도와줍니다:
- ❓ 규격의 모호한 점 식별
- 💡 명확한 결정 내리기
- 📝 규격 문서 자동 업데이트

**예상 시간**: 10-15분

### 4단계: 창작 계획 수립

```
/plan
```

구체적인 실행 방안을 설계합니다:
- 📚 챕터 구성
- 📈 페이스 분배
- 🎭 캐릭터 아크
- 🔮 복선 계획

**예상 시간**: 45-60분

### 5단계: 작업 목록 분해

```
/tasks
```

실행 가능한 작업을 생성합니다:
- ✅ 우선순위별 정렬
- 🔗 의존 관계 표시
- ⏱️ 작업량 추정

**예상 시간**: 20-30분

### 6단계: 글쓰기 시작

```
/write
```

AI 보조 창작:
- 🤖 규격과 계획에 따라 내용 생성
- 🎨 장르 지식 자동 적용
- 🔍 백그라운드 일관성 검사
- ⚡ 실시간 글쓰기 기법 적용

**권장 페이스**: 한 번에 1-2챕터, 3-5챕터마다 멈추고 분석

### 7단계: 품질 검증

```
/analyze
```

전면 품질 검사:
- ✅ 헌법 준수 여부
- ✅ 규격 충족도
- ✅ 콘텐츠 일관성
- ✅ 품질 기준 달성

**권장 주기**: 5챕터마다 실행

## Agent Skills 자동 활성화

### 수동 호출 불필요

창작 시, 관련 Skills가 **자동으로 활성화**됩니다:

**장르 지식**:
- "로맨스" 언급 → Romance Skill 활성화
- "미스터리" 언급 → Mystery Skill 활성화
- "판타지" 언급 → Fantasy Skill 활성화

**글쓰기 기법**:
- 대화 작성 시 → Dialogue Techniques 활성화
- 장면 작성 시 → Scene Structure 활성화

**품질 보증**:
- 글쓰기 과정 중 → Consistency Checker 백그라운드 모니터링
- 전체 프로세스 → Workflow Guide 활성 유지

### 능동적 알림

Skills는 문제를 감지하면 능동적으로 알립니다:

```
⚠️ 일관성 검사 알림

문제: 캐릭터 특성 불일치
위치: 제5장, 제3단락

현재 텍스트: "메리의 초록색 눈..."
확립된 특성: "눈 색상: 파란색"

수정할까요?
```

## 추적 및 검증 명령

### 추적 시스템 초기화

```
/track-init
```

최초 사용 시, 추적 파일을 생성합니다.

### 종합 추적

```
/track
```

챕터 완료 후 실행하여 업데이트합니다:
- 📊 플롯 추적
- ⏰ 타임라인
- 👥 캐릭터 관계
- 🌍 세계관 상태

### 전문 검사

```
/plot-check   # 플롯 일관성
/timeline     # 타임라인 관리
/relations    # 캐릭터 관계
/world-check  # 세계관 검증
```

## 플러그인 시스템

### 설치된 플러그인 확인

```bash
novelwrite plugin:list
```

### 플러그인 설치

```bash
novelwrite plugin:add authentic-voice
```

### 플러그인 제거

```bash
novelwrite plugin:remove authentic-voice
```

### 공식 플러그인

- **authentic-voice**: 진정한 인간 목소리 글쓰기 플러그인, 독창성 향상

## 자주 묻는 질문

### Q: 일부 단계를 건너뛸 수 있나요?

A: 가능합니다. 하지만 일부 명령은 상호 의존합니다:
- `/write`는 `/specify`와 `/plan`이 필요
- 최소 프로세스: `/constitution` → `/specify` → `/write`

### Q: Skills가 창작을 방해하지 않나요?

A: 아닙니다! Skills는 **수동적**입니다:
- 관련 있을 때만 활성화
- 제안하되 강제하지 않음
- 최종 결정권은 항상 당신에게

### Q: 일관성 검사의 엄격도를 어떻게 조정하나요?

A: 대화에서 AI에게 말하세요:
```
"판타지 소설이라 유연 모드로
일관성 검사를 해주세요."
```

### Q: 이미 아웃라인이 있는데 어떻게 하나요?

A: `/specify`를 사용하여 기존 아웃라인을 novelwrite 형식으로 변환한 후,
이후 단계를 계속하세요.

## 다음 단계

### 심화 학습

- 📖 [명령 상세](commands.md) - 모든 명령의 상세 설명
- 🎨 [Skills 가이드](skills-guide.md) - Skills 작동 원리
- 🔌 [플러그인 개발](plugin-development.md) - 직접 플러그인 만들기

### 예제 프로젝트

`examples/` 디렉토리의 예제 프로젝트에서 전체 워크플로우를 확인하세요.

### 커뮤니티 지원

- 💬 GitHub Discussions: https://github.com/wordflowlab/novel-writer-skills/discussions
- 🐛 Bug 보고: https://github.com/wordflowlab/novel-writer-skills/issues
- 📧 이메일 지원: support@wordflowlab.com

---

**준비되셨나요?** 첫 번째 프로젝트를 만들고 소설 창작 여정을 시작하세요!

```bash
novelwrite init my-amazing-novel
cd my-amazing-novel
# Claude Code에서 열고, /constitution을 입력하여 시작
```

즐거운 창작 되세요! ✨📚
