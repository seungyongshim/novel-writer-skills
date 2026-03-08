# Novel Writer Skills 제품 요구사항 문서

**버전**: v1.0  
**날짜**: 2025-10-18  
**상태**: Draft

---

## 1. 제품 포지셔닝

### 1.1 프로젝트 개요

**novel-writer-skills**는 **Claude Code** 전용으로 설계된 AI 소설 창작 도구로, Claude의 Slash Commands와 Agent Skills 시스템에 심층 통합됩니다.

- **기술 스택**: Claude Code 전용
- **핵심 역량**: 7단계 방법론 + Agent Skills 스마트 보조
- **대상 사용자**: Claude Code를 사용하여 소설을 창작하는 작가

### 1.2 novel-writer와의 관계

- **novel-writer**: 크로스 플랫폼 (13개 AI 도구), 기본 방법론
- **novel-writer-skills**: Claude Code 전용, 심층 강화

**공유**: 7단계 방법론, 파일 구조, 추적 시스템
**차이**: 크로스 플랫폼 지원 제거, Agent Skills 스마트 시스템 추가

---

## 2. 핵심 아키텍처

### 2.1 기술 구성요소

| 구성요소 | 설명 |
|---------|------|
| **Slash Commands** | Claude Code 슬래시 명령, 사용자 능동 호출 |
| **Agent Skills** | AI 자동 활성화 지식 라이브러리 및 검사 시스템 |
| **CLI 도구** | 프로젝트 초기화 및 관리 (`novel-skills` 명령) |
| **플러그인 시스템** | 확장 가능한 기능 모듈 |

### 2.2 프로젝트 구조

```
novel-writer-skills/
├── .claude/
│   ├── commands/              # Slash Commands
│   │   ├── constitution.md
│   │   ├── specify.md
│   │   ├── clarify.md
│   │   ├── plan.md
│   │   ├── tasks.md
│   │   ├── write.md
│   │   ├── analyze.md
│   │   └── [추적 명령...]
│   │
│   └── skills/                # Agent Skills
│       ├── genre-knowledge/   # 장르 지식 라이브러리
│       ├── writing-techniques/ # 글쓰기 기법
│       └── quality-assurance/ # 스마트 검사
│
├── src/                       # CLI 소스 코드
│   ├── cli.ts
│   ├── init.ts
│   └── utils/
│
├── templates/                 # 프로젝트 템플릿
│   ├── project-template/
│   └── plugin-template/
│
├── plugins/                   # 공식 플러그인
│   ├── authentic-voice/
│   ├── translate/
│   └── [기타 플러그인...]
│
├── docs/                      # 문서
│   ├── getting-started.md
│   ├── commands.md
│   └── skills-guide.md
│
├── package.json
├── tsconfig.json
└── README.md
```

---

## 3. 핵심 기능

### 3.1 Slash Commands (사용자 능동 호출)

#### 7단계 방법론 명령

| 명령 | 기능 | 출력 |
|------|------|------|
| `/constitution` | 창작 헌법 작성 | `.specify/memory/constitution.md` |
| `/specify` | 스토리 규격 정의 | `stories/[name]/specification.md` |
| `/clarify` | 모호한 점 명확화 (5개 질문) | specification.md 업데이트 |
| `/plan` | 창작 계획 수립 | `stories/[name]/creative-plan.md` |
| `/tasks` | 작업 목록 분해 | `stories/[name]/tasks.md` |
| `/write` | 챕터 작성 실행 | `stories/[name]/content/chapter-XX.md` |
| `/analyze` | 품질 검증 분석 | 분석 보고서 (이중 모드: 프레임워크/콘텐츠) |

#### 추적 및 검증 명령

| 명령 | 기능 |
|------|------|
| `/track-init` | 추적 시스템 초기화 |
| `/track` | 종합 추적 업데이트 |
| `/plot-check` | 플롯 일관성 검사 |
| `/timeline` | 타임라인 관리 |
| `/relations` | 캐릭터 관계 추적 |
| `/world-check` | 세계관 검증 |
| `/checklist` | 품질 체크리스트 |

### 3.2 Agent Skills (AI 자동 활성화)

#### Skills 설계 원칙

- **수동 활성화**: AI가 맥락에 따라 자동 판단
- **무인지**: 사용자의 수동 호출 불필요
- **지속 적용**: 전체 대화에서 활성 유지

#### Skills 분류

**1. Genre Knowledge Skills (장르 지식 라이브러리)**

소설 장르에 따라 창작 관례와 기법을 자동 제공:

- `romance.md` - 로맨스 소설 관례
- `mystery.md` - 추리 미스터리 기법
- `fantasy.md` - 판타지 설정 규범
- `sci-fi.md` - SF 세계 구축
- `thriller.md` - 스릴러 리듬 제어

**트리거 예시**: 사용자가 "로맨스 소설을 쓰겠다"고 말하면 → romance skill 자동 활성화

**2. Writing Techniques Skills (글쓰기 기법)**

특정 창작 장면에서 모범 사례를 자동 적용:

- `dialogue-techniques.md` - 대화 자연스러움
- `scene-structure.md` - 장면 구축
- `character-arc.md` - 캐릭터 아크
- `pacing-control.md` - 리듬 조절
- `description-depth.md` - 묘사 깊이

**트리거 예시**: 대화 장면 작성 시 → dialogue-techniques 자동 활성화

**3. Quality Assurance Skills (스마트 검사)**

글쓰기 과정에서 자동 모니터링 및 알림:

- `consistency-checker.md` - 일관성 검사 (캐릭터, 세계관, 타임라인)
- `pov-validator.md` - 시점 검증
- `continuity-tracker.md` - 연속성 추적
- `pacing-monitor.md` - 리듬 모니터링

**트리거 예시**: 글쓰기 중 모순 감지 → 자동 경고 표시

### 3.3 Skills와 Commands 협업

```
사용자: 로맨스 소설을 쓰고 싶어요

[Skills 활성화]
✓ romance-novel-conventions (장르 지식)
✓ workflow-guide (7단계 방법론 안내)

AI 응답:
"좋습니다! 체계적인 방법으로 창작합시다. 먼저 /constitution을
실행하여 창작 원칙을 정의하고, /specify로 스토리 규격을 명확히..."

[후속 창작에서]
✓ /write 실행 → dialogue-techniques 자동 활성화
✓ 글쓰기 과정 → consistency-checker 백그라운드 모니터링
✓ 문제 발견 → 사용자에게 능동적 알림
```

---

## 4. 기술 사양

### 4.1 Slash Command 형식

```markdown
---
description: 명령의 짧은 설명 (한 문장)
---

# 명령 제목

## 목표
[명령이 달성해야 할 것]

## 프로세스
[단계 설명]

## 출력
[어떤 파일을 생성하는지]

## 예시
[사용 예시]
```

### 4.2 Agent Skill 형식

```yaml
---
name: skill-identifier
description: "Use when [트리거 조건] - [기능 설명]"
allowed-tools: Read, Grep, Glob
---

# Skill Title

## Quick Reference
[빠른 참조표]

## Core Concepts
[핵심 개념]

## Best Practices
[모범 사례]

## Common Pitfalls
[흔한 실수]
```

**Description 작성 요점**:

- 명확한 트리거 조건 포함 필수
- 어떤 가치를 제공하는지 설명
- 예시: `"Use when user mentions romance or love story - provides genre conventions and emotional beat planning for romance writing"`

### 4.3 사용자 프로젝트 구조

`novel-skills init [name]`으로 초기화한 후의 프로젝트 구조:

```
my-novel/
├── .claude/
│   ├── commands/       # novel-writer-skills에서 복사
│   └── skills/         # novel-writer-skills에서 복사
│
├── .specify/           # Spec Kit 설정
│   ├── memory/
│   │   └── constitution.md
│   └── scripts/
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
│   └── knowledge/      # 지식 라이브러리
│       ├── characters/
│       ├── worldbuilding/
│       └── references/
│
└── README.md
```

---

## 5. CLI 도구

### 5.1 핵심 명령

```bash
# 설치
npm install -g novel-writer-skills

# 프로젝트 초기화
novelwrite init my-novel

# 플러그인 설치
novelwrite plugin:add authentic-voice

# 플러그인 목록
novelwrite plugin:list

# 프로젝트 업그레이드
novelwrite upgrade

# 상태 확인
novelwrite check
```

### 5.2 초기화 프로세스

```bash
novelwrite init my-novel
```

실행 내용:
1. 프로젝트 디렉토리 구조 생성
2. `.claude/commands/`와 `.claude/skills/` 복사
3. `.specify/` 설정 초기화
4. `spec/tracking/` 템플릿 생성
5. README.md 생성

---

## 6. 개발 로드맵

### 6.1 MVP (4-6주)

**목표**: 핵심 기능 사용성 검증

**산출물**:
- ✅ 7단계 방법론 Commands (7개 명령)
- ✅ 추적 검증 Commands (6개 명령)
- ✅ 2-3개 Genre Knowledge Skills (romance, mystery, fantasy)
- ✅ 2-3개 Writing Techniques Skills (dialogue, scene-structure)
- ✅ 1개 Quality Assurance Skill (consistency-checker)
- ✅ CLI 기본 도구 (init, plugin)
- ✅ 핵심 문서

**성공 기준**:
- Commands가 7단계 프로세스를 올바르게 실행
- Skills가 올바른 상황에서 활성화 (활성화율 > 80%)
- 5-10명 얼리 어답터 테스트 피드백 긍정적

### 6.2 Phase 2 (6-8주)

**목표**: 완전한 기능과 플러그인 생태계

**산출물**:
- ✅ 완전한 Genre Skills (5개 장르)
- ✅ 완전한 Writing Skills (6개 기법)
- ✅ 완전한 QA Skills (4개 검사)
- ✅ 플러그인 시스템 완성
- ✅ 공식 플러그인 (authentic-voice, translate 등)
- ✅ 플러그인 개발 문서

**성공 기준**:
- Skills가 주요 창작 시나리오 커버
- 일관성 검사 정확도 > 85%
- 커뮤니티에서 플러그인 기여 시작

### 6.3 Phase 3 (8-10주)

**목표**: 최적화 및 홍보

**산출물**:
- ✅ 성능 최적화 (Skills 로딩 < 2초)
- ✅ 고급 Commands (polish-prose, theme-analysis 등)
- ✅ 완전한 예제 프로젝트
- ✅ 비디오 튜토리얼
- ✅ 커뮤니티 구축

**성공 기준**:
- 100+ 활성 사용자
- 오탐률 < 10%
- GitHub Stars > 200

---

## 7. 성공 지표

### 7.1 기술 지표

| 지표 | 목표 | 측정 방법 |
|------|------|---------|
| Skills 활성화 정확도 | > 85% | 테스트 케이스 통과율 |
| 일관성 검사 리콜률 | > 90% | 알려진 오류 포착률 |
| Commands 실행 성공률 | > 95% | 오류 없는 완료율 |
| 로딩 성능 | < 2초 | Skills 로딩 시간 |
| 오탐률 | < 10% | 잘못된 알림 비율 |

### 7.2 사용자 지표

| 지표 | 목표 | 측정 방법 |
|------|------|---------|
| 월간 활성 사용자 | 100+ | GitHub insights |
| 유지율 (7일) | > 40% | 지속 사용 통계 |
| 전체 프로세스 완료율 | > 60% | 7단계 방법론 완료 비율 |
| 사용자 만족도 | > 4.0/5.0 | 설문 조사 |
| 커뮤니티 기여 | 5+ PRs/월 | GitHub contributions |

---

## 8. 리스크 및 대책

### 8.1 기술 리스크

| 리스크 | 영향 | 대책 |
|--------|------|------|
| Skills 활성화 부정확 | 사용자 경험 저하 | description 정밀 작성, 충분한 테스트 |
| 높은 오탐률 | 사용자 신뢰도 하락 | 등급별 경고 (Critical/Warning/Note) |
| 성능 문제 | 로딩 지연, 사용에 영향 | 지연 로딩, Skill 크기 최적화 |

### 8.2 제품 리스크

| 리스크 | 영향 | 대책 |
|--------|------|------|
| Claude만 지원, 사용자 기반 소규모 | 성장 제한 | 넓이보다 깊이에 집중, 최고의 경험 구축 |
| 학습 곡선 가파름 | 신규 사용자 이탈 | 문서 완선, 예제 제공, 가이드 튜토리얼 |
| 커뮤니티 참여도 낮음 | 생태계 발전 느림 | 인센티브 메커니즘, 기여 문턱 낮추기 |

---

## 9. 다음 행동 항목

### 9.1 즉시 실행 (이번 주)

1. **프로젝트 프레임워크 구축**
   - `novel-writer-skills` 저장소 생성
   - 프로젝트 구조 설정
   - TypeScript 및 빌드 도구 설정

2. **CLI 기본 구현**
   - `novel-skills init` 명령
   - 프로젝트 템플릿 파일

3. **첫 번째 Command 작성**
   - `/constitution` 명령
   - Claude Code에서 실행 테스트

### 9.2 단기 목표 (2주 내)

1. **7단계 방법론 Commands 완성**
   - 7개 핵심 명령 전부 구현
   - 사용 문서 작성

2. **2-3개 기본 Skills 구현**
   - romance-novel-conventions
   - dialogue-techniques
   - consistency-checker

3. **테스트 및 반복**
   - 5-10명 얼리 어답터 초대
   - 피드백 수집, 빠른 반복

### 9.3 중기 목표 (4-6주)

1. **MVP 완성**
   - 모든 핵심 기능 구현
   - 문서 완성
   - 예제 프로젝트

2. **출시 준비**
   - npm 패키지 발행
   - GitHub 저장소 공개
   - 릴리스 노트 작성

---

## 부록

### A. 참고 자료

- [Anthropic Agent Skills 문서](https://docs.anthropic.com/en/docs/build-with-claude/agent-skills)
- [Claude Code Slash Commands 사양](https://docs.anthropic.com/en/docs/build-with-claude/slash-commands)
- [novel-writer 프로젝트](https://github.com/wordflowlab/novel-writer) (방법론 참고)

### B. 용어집

| 용어 | 설명 |
|------|------|
| **Slash Commands** | Claude Code에서 `/`로 시작하는 사용자 입력 명령 |
| **Agent Skills** | AI가 자동 활성화하는 지식 라이브러리 및 역량 모듈 |
| **7단계 방법론** | constitution → specify → clarify → plan → tasks → write → analyze |
| **규격 주도 개발 (SDD)** | 먼저 규격을 정의하고 이후 창작을 실행하는 방법론 |

---

**버전 이력**

- v1.0 (2025-10-18): 초기 버전, 제품 포지셔닝 및 핵심 기능 명확화
