# Novel Writer Skills - Claude Code 전용 소설 창작 도구

[![npm version](https://badge.fury.io/js/novel-writer-skills.svg)](https://www.npmjs.com/package/novel-writer-skills)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

> 🚀 Claude Code를 위해 설계된 AI 스마트 소설 창작 어시스턴트
>
> Slash Commands와 Agent Skills의 깊은 통합으로 최상의 창작 경험을 제공합니다

## ✨ 핵심 기능

- 📚 **Slash Commands** - Claude Code 슬래시 명령어, 7단계 방법론 완벽 지원
- 🤖 **Agent Skills** - AI 자동 활성화 지식 베이스 및 스마트 검사 시스템
- 🎯 **장르 지식 베이스** - 로맨스, 미스터리, 판타지 등 장르별 창작 관례 자동 제공
- 🔍 **스마트 품질 검사** - 일관성, 리듬, 시점 등 문제 자동 모니터링
- 📝 **글쓰기 기법 강화** - 대화, 장면, 캐릭터 등 전문 기법 자동 적용
- 🔌 **플러그인 시스템** - 진정성 있는 목소리, 번역 등 확장 가능한 기능

## 🚀 빠른 시작

### 1. 설치

```bash
npm install -g novel-writer-skills
```

### 2. 프로젝트 초기화

```bash
# 기본 사용법
novelwrite init my-novel

# 현재 디렉토리에서 초기화
novelwrite init --here

# 플러그인 사전 설치
novelwrite init my-novel --plugins authentic-voice
```

### 3. Claude Code에서 창작 시작

Claude Code에서 프로젝트를 열고 슬래시 명령어를 사용하세요:

```text
/constitution    # 1. 창작 헌법 생성
/specify         # 2. 스토리 스펙 정의
/clarify         # 3. 핵심 결정 명확화
/plan            # 4. 창작 계획 수립
/tasks           # 5. 태스크 목록 분해
/write           # 6. AI 보조 집필
/analyze         # 7. 품질 검증 분석
```

## 🎨 Agent Skills 자동 활성화

### 장르 지식 베이스 (Genre Knowledge)

특정 장르를 언급하면 해당 지식 베이스가 자동으로 활성화됩니다:

- 💕 **Romance** - 로맨스 소설 관례와 감정 리듬
- 🔍 **Mystery** - 추리/미스터리 기법과 단서 관리
- 🐉 **Fantasy** - 판타지 설정 규범과 세계관 구축

### 글쓰기 기법 (Writing Techniques)

글쓰기 과정에서 모범 사례를 자동 적용합니다:

- 💬 **Dialogue** - 대화 자연스러움과 캐릭터 목소리
- 🎬 **Scene Structure** - 장면 구성과 리듬 제어
- 👤 **Character Arc** - 캐릭터 아크와 성장 논리

### 스마트 검사 (Quality Assurance)

백그라운드에서 자동 모니터링하며 문제를 능동적으로 알립니다:

- ✅ **Consistency Checker** - 일관성 검사 (캐릭터, 세계관, 타임라인)
- 🧭 **Workflow Guide** - 7단계 방법론 사용 안내

## 📚 Slash Commands

### 7단계 방법론

| 명령어 | 기능 | 출력 |
|------|------|------|
| `/constitution` | 창작 헌법 생성 | `.specify/memory/constitution.md` |
| `/specify` | 스토리 스펙 정의 | `stories/[name]/specification.md` |
| `/clarify` | 모호한 점 명확화 (5개 질문) | specification.md 업데이트 |
| `/plan` | 창작 계획 수립 | `stories/[name]/creative-plan.md` |
| `/tasks` | 태스크 목록 분해 | `stories/[name]/tasks.md` |
| `/write` | 챕터 집필 실행 | `stories/[name]/content/chapter-XX.md` |
| `/analyze` | 품질 검증 분석 | 분석 보고서 (이중 모드: 프레임워크/콘텐츠) |

### 추적 및 검증

| 명령어 | 기능 |
|------|------|
| `/track-init` | 추적 시스템 초기화 |
| `/track` | 종합 추적 업데이트 |
| `/plot-check` | 플롯 일관성 검사 |
| `/timeline` | 타임라인 관리 |
| `/relations` | 캐릭터 관계 추적 |
| `/world-check` | 세계관 검증 |

## 🔌 플러그인 시스템

### 플러그인 설치

```bash
# 사용 가능한 플러그인 목록
novelwrite plugin:list

# 플러그인 설치
novelwrite plugin:add authentic-voice

# 플러그인 제거
novelwrite plugin:remove authentic-voice
```

### 공식 플러그인

- **authentic-voice** - 진정성 있는 목소리 글쓰기 플러그인, 독창성과 생활 질감 향상
- 더 많은 플러그인 개발 중...

## 📖 프로젝트 구조

```text
my-novel/
├── .claude/
│   ├── commands/       # Slash Commands
│   └── skills/         # Agent Skills
│
├── .specify/           # Spec Kit 설정
│   ├── memory/
│   │   └── constitution.md
│   └── templates/
│       ├── scripts/    # 명령줄 스크립트 도구
│       │   ├── bash/
│       │   └── powershell/
│       ├── commands/
│       ├── knowledge/
│       └── ...
│
├── stories/
│   └── 001-my-story/
│       ├── specification.md
│       ├── creative-plan.md
│       ├── tasks.md
│       └── content/
│           ├── chapter-01.md
│           └── ...
│
├── spec/
│   ├── tracking/       # 추적 데이터
│   │   ├── plot-tracker.json
│   │   ├── timeline.json
│   │   ├── character-state.json
│   │   └── relationships.json
│   │
│   └── knowledge/      # 지식 베이스
│       ├── characters/
│       ├── worldbuilding/
│       └── references/
│
└── README.md
```

## 🆚 novel-writer와의 관계

| 기능 | novel-writer | novel-writer-skills |
|------|-------------|-------------------|
| **지원 플랫폼** | 13개 AI 도구 (Claude, Cursor, Gemini 등) | Claude Code 전용 |
| **핵심 방법론** | ✅ 7단계 방법론 | ✅ 7단계 방법론 |
| **Slash Commands** | ✅ 크로스 플랫폼 명령어 | ✅ Claude 최적화 명령어 |
| **Agent Skills** | ❌ 미지원 | ✅ 깊은 통합 |
| **스마트 검사** | ⚠️ 수동 실행 | ✅ 자동 모니터링 |
| **장르 지식 베이스** | ⚠️ 수동 참조 필요 | ✅ 자동 활성화 |
| **적합한 시나리오** | 크로스 플랫폼 지원 필요 시 | 최상의 경험 추구 (Claude Code) |

**선택 가이드**:

- 여러 AI 도구를 사용한다면 → **novel-writer** 선택
- Claude Code에 집중한다면 → **novel-writer-skills** 선택

## 🛠️ CLI 명령어

### 프로젝트 관리

```bash
# 프로젝트 초기화
novelwrite init <project-name>

# 환경 확인
novelwrite check

# 프로젝트 업그레이드
novelwrite upgrade
```

### 플러그인 관리

```bash
# 설치된 플러그인 목록
novelwrite plugin:list

# 플러그인 설치
novelwrite plugin:add <plugin-name>

# 플러그인 제거
novelwrite plugin:remove <plugin-name>
```

## 🔧 명령줄 스크립트 (선택)

Claude Code의 Slash Commands 외에도 명령줄 스크립트 도구를 포함하고 있습니다:

### 스크립트 위치

프로젝트 초기화 후 스크립트는 `.specify/templates/scripts/`에 위치합니다

```text
.specify/templates/scripts/
├── bash/          # macOS/Linux 스크립트
└── powershell/    # Windows 스크립트
```

### 사용 시나리오

- ✅ **명령줄 대안** - 터미널에서 직접 7단계 방법론 실행
- ✅ **자동화 워크플로** - CI/CD 또는 배치 스크립트에 통합
- ✅ **일괄 처리** - 여러 스토리 처리 또는 일괄 검사
- ✅ **독립 사용** - Claude Code에 의존하지 않는 시나리오

### 빠른 예시

**macOS/Linux:**

```bash
# 헌법 생성
bash .specify/templates/scripts/bash/constitution.sh

# 스펙 정의
bash .specify/templates/scripts/bash/specify-story.sh

# 진행 추적
bash .specify/templates/scripts/bash/track-progress.sh
```

**Windows:**

```powershell
# 헌법 생성
.\.specify\templates\scripts\powershell\constitution.ps1

# 스펙 정의
.\.specify\templates\scripts\powershell\specify-story.ps1

# 진행 추적
.\.specify\templates\scripts\powershell\track-progress.ps1
```

### 사용 가능한 스크립트

모든 Slash Commands에 대응하는 스크립트 버전이 있습니다:

| 스크립트 | 기능 | 대응 명령어 |
|-----|------|---------|
| `constitution` | 창작 헌법 생성 | `/constitution` |
| `specify-story` | 스토리 스펙 정의 | `/specify` |
| `plan-story` | 창작 계획 수립 | `/plan` |
| `track-progress` | 진행 추적 | `/track` |
| `check-consistency` | 일관성 검사 | - |
| 그 외... | `.specify/templates/scripts/README.md` 참조 | - |

📖 **상세 문서**: [scripts/README.md](templates/scripts/README.md)

### 스크립트 vs Slash Commands 사용 시기

| 시나리오 | 추천 방식 |
|-----|---------|
| 일상 창작, AI 보조 필요 | ✅ Slash Commands (우선) |
| 일괄 처리, 자동화 | ✅ 명령줄 스크립트 |
| CI/CD 통합 | ✅ 명령줄 스크립트 |
| 빠른 검사/검증 | ✅ 명령줄 스크립트 |

## 📚 문서

- [시작 가이드](docs/getting-started.md) - 상세 설치 및 사용 튜토리얼
- [명령어 상세 설명](docs/commands.md) - 모든 명령어의 완전한 설명
- [Skills 가이드](docs/skills-guide.md) - Agent Skills 작동 원리
- [스크립트 도구 모음](templates/scripts/README.md) - 명령줄 스크립트 사용 가이드
- [플러그인 개발](docs/plugin-development.md) - 자체 플러그인 개발 방법

## 🤝 기여

Issue와 Pull Request를 환영합니다!

프로젝트 주소: [https://github.com/wordflowlab/novel-writer-skills](https://github.com/wordflowlab/novel-writer-skills)

## 📄 라이선스

MIT License

## 🙏 감사의 말

이 프로젝트는 [novel-writer](https://github.com/wordflowlab/novel-writer)의 방법론을 기반으로 Claude Code에 맞게 최적화되었습니다.

---

**Novel Writer Skills** - Claude Code를 당신의 최고의 창작 파트너로 만들어 드립니다! ✨📚
