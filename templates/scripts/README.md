# 스크립트 도구 모음

이 디렉토리에는 Novel Writer Skills의 명령줄 스크립트 도구가 포함되어 있으며, Claude Code Slash Commands의 대안으로 사용됩니다.

## 디렉토리 구조

```text
scripts/
├── bash/          # macOS/Linux 스크립트
├── powershell/    # Windows 스크립트
└── README.md      # 본 문서
```

## novel-writer-skills 적응 설명

이 스크립트들은 [novel-writer](https://github.com/wordflowlab/novel-writer)에서 이식되어 novel-writer-skills 프로젝트 구조에 맞게 적응되었습니다:

### 경로 차이

| 파일 | novel-writer | novel-writer-skills |
|------|-------------|-------------------|
| 헌법 파일 | `memory/constitution.md` | `.specify/memory/constitution.md` |
| 스토리 규격 | `stories/*/specification.md` | `stories/*/specification.md` ✅ |
| 추적 데이터 | `spec/tracking/*.json` | `spec/tracking/*.json` ✅ |

**모든 스크립트는 새 경로에 자동 적응되어 있으며**, 수동 수정이 필요 없습니다!

## 사용 시나리오

Novel Writer Skills는 주로 Claude Code용으로 설계되었지만, 이 스크립트들은 다음을 제공합니다:

- ✅ **명령줄 대안** - 터미널에서 직접 작업 실행
- ✅ **자동화 워크플로** - CI/CD 또는 자동화 스크립트에 통합
- ✅ **배치 처리** - 여러 스토리 처리 또는 일괄 검사
- ✅ **독립 도구** - Claude Code에 의존하지 않는 독립 기능

## 빠른 시작

### macOS/Linux 사용자

```bash
# 프로젝트 루트 디렉토리로 이동
cd my-novel

# 스크립트 사용 (예시: 헌법 생성)
bash .specify/templates/scripts/bash/constitution.sh

# 또는 PATH에 추가
export PATH="$PATH:$(pwd)/.specify/templates/scripts/bash"
constitution.sh
```

### Windows 사용자

```powershell
# 프로젝트 루트 디렉토리로 이동
cd my-novel

# 스크립트 사용 (예시: 헌법 생성)
.\.specify\templates\scripts\powershell\constitution.ps1

# 또는 환경 변수에 추가
$env:PATH += ";$(Get-Location)\.specify\templates\scripts\powershell"
constitution.ps1
```

## 핵심 스크립트

### 7단계 방법론

| 스크립트 | 기능 | 대응 명령 |
|---------|------|----------|
| `constitution.sh/ps1` | 창작 헌법 생성 | `/constitution` |
| `specify-story.sh/ps1` | 스토리 규격 정의 | `/specify` |
| `clarify-story.sh/ps1` | 모호한 부분 명확화 | `/clarify` |
| `plan-story.sh/ps1` | 창작 계획 수립 | `/plan` |
| `generate-tasks.sh/ps1` | 작업 체크리스트 생성 | `/tasks` |
| `analyze-story.sh/ps1` | 품질 검증 분석 | `/analyze` |

### 추적 및 검사

| 스크립트 | 기능 | 대응 명령 |
|---------|------|----------|
| `init-tracking.sh/ps1` | 추적 시스템 초기화 | `/track-init` |
| `track-progress.sh/ps1` | 종합 추적 업데이트 | `/track` |
| `check-plot.sh/ps1` | 플롯 일관성 검사 | `/plot-check` |
| `check-timeline.sh/ps1` | 타임라인 관리 | `/timeline` |
| `manage-relations.sh/ps1` | 캐릭터 관계 추적 | `/relations` |
| `check-world.sh/ps1` | 세계관 검증 | `/world-check` |
| `check-consistency.sh/ps1` | 일관성 검사 | - |
| `check-writing-state.sh/ps1` | 집필 상태 검사 | - |

### 유틸리티 스크립트

| 스크립트 | 기능 |
|---------|------|
| `common.sh/ps1` | 공통 함수 라이브러리 (다른 스크립트에서 참조) |
| `text-audit.sh/ps1` | 텍스트 감사 도구 |
| `test-word-count.sh` | 글자 수 통계 (bash 전용) |

## 공통 함수 라이브러리

`common.sh`와 `common.ps1`은 다음과 같은 공용 함수를 제공합니다:

### Bash 함수

```bash
get_project_root()    # 프로젝트 루트 디렉토리 가져오기
get_current_story()   # 현재 스토리 디렉토리 가져오기
get_active_story()    # 활성 스토리 이름 가져오기
create_numbered_dir() # 번호가 붙은 디렉토리 생성
```

### PowerShell 함수

```powershell
Get-ProjectRoot       # 프로젝트 루트 디렉토리 가져오기
Get-CurrentStoryDir   # 현재 스토리 디렉토리 가져오기
Get-ActiveStory       # 활성 스토리 이름 가져오기
```

## 주의사항

1. **프로젝트 루트 디렉토리 인식** - 스크립트는 `.specify/config.json`을 찾아 프로젝트 루트 디렉토리를 결정합니다
2. **실행 권한** - Linux/macOS 사용자는 스크립트에 실행 권한이 있는지 확인해야 합니다:
   ```bash
   chmod +x .specify/templates/scripts/bash/*.sh
   ```
3. **Slash Commands와의 차이점**:
   - Slash Commands는 Claude Code에서 사용하며, AI 상호작용 기능이 있습니다
   - 스크립트는 자동화와 배치 처리에 적합하며, AI 상호작용이 없습니다
   - 최상의 경험을 위해 Slash Commands 우선 사용을 권장합니다

## 스크립트 vs Slash Commands 선택 가이드

| 시나리오 | 권장 방식 |
|---------|----------|
| 일상 창작, AI 보조 필요 | ✅ Slash Commands |
| 배치 처리, 자동화 | ✅ 스크립트 |
| CI/CD 통합 | ✅ 스크립트 |
| 워크플로 학습과 이해 | ✅ 스크립트 (소스 코드 확인 가능) |
| 빠른 검사 및 검증 | ✅ 스크립트 |

## 예시: 완전한 워크플로

```bash
# 1. 헌법 생성
bash constitution.sh

# 2. 스토리 규격 정의
bash specify-story.sh

# 3. 모호한 부분 명확화 (보통 사람의 참여 필요)
bash clarify-story.sh

# 4. 계획 수립
bash plan-story.sh

# 5. 작업 생성
bash generate-tasks.sh

# 6. 추적 초기화
bash init-tracking.sh

# 7. 집필 과정에서 정기적 추적
bash track-progress.sh

# 8. 최종 분석
bash analyze-story.sh
```

## 관련 문서

- [Novel Writer Skills 메인 문서](../../README.md)
- [명령 상세 설명](../../docs/commands.md)
- [시작하기 가이드](../../docs/getting-started.md)

## 팁

이 스크립트들은 [novel-writer](https://github.com/wordflowlab/novel-writer) 프로젝트에서 이식되었으며, Novel Writer Skills의 프로젝트 구조에 맞게 조정되었습니다.

여러 AI 도구 간에 전환하는 경우, 완전 버전의 [novel-writer](https://github.com/wordflowlab/novel-writer) 사용도 고려해 보세요.

---

**Happy Writing!** ✨📚
