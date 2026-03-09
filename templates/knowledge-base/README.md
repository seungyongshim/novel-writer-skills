# 집필 지식 베이스 시스템

## 개요

이것은 Novel Writer Skills의 핵심 경쟁력 - 확장 가능한 범용 집필 지식 베이스 시스템입니다.

**프로젝트 특정 지식과의 차이**:
- `spec/knowledge/` - 프로젝트 특정 지식 저장 (캐릭터 프로필, 장소, 세계관 등)
- `templates/knowledge-base/` (본 디렉토리) - 범용 집필 지식 저장 (장르 관례, 기법, 참고 자료)

**작동 원리**:
1. **자동 활성화**: setting-detector Skill이 키워드 매핑 테이블을 기반으로 자동으로 스토리 설정을 감지
2. **주문형 로드**: 관련 지식 베이스만 로드하여 토큰 절약 (단일 지식 베이스 ~500 tokens)
3. **지속 적용**: 지식 베이스가 전체 창작 과정에서 활성 상태 유지

**토큰 효율**:
- 기존 방안 (50개 Skill): ~2000 tokens
- 현재 방안 (1개 detector + 주문형 지식 베이스): ~600 tokens
- **75% 절감**

---

## 📚 지식 베이스 인덱스

### 1. 장르 지식 베이스 (Genres)

전문 장르 소설의 창작 관례와 모범 사례.

| 파일 | 장르 | 핵심 관례 |
|------|------|---------|
| `genres/romance.md` | 로맨스 소설 | HEA 결말, 감정 리듬 포인트, 관계 아크 |
| `genres/mystery.md` | 미스터리/추리 | 페어 플레이, 단서 관리, 용의자 설계 |
| `genres/historical.md` | 역사 소설 | 고증 균형, 시대 분위기, 역사 묘사 |
| `genres/revenge.md` | 복수 쾌감소설 | 리듬 제어, 역전 설계, 감정 관리 |
| `genres/wuxia.md` | 무협 소설 | 강호 규칙, 무학 체계, 협의 정신 |

### 2. 집필 기법 지식 베이스 (Craft)

장르를 초월하여 적용되는 전문 집필 기술.

| 파일 | 기법 | 핵심 원칙 |
|------|------|---------|
| `craft/dialogue.md` | 대화 기법 | 서브텍스트, 캐릭터 음성, 자연스러움 |
| `craft/scene-structure.md` | 장면 구조 | 목표-갈등-재난, 후속 장면 모델 |
| `craft/character-arc.md` | 캐릭터 아크 | 변화 메커니즘, 내외부 갈등, 성장 논리 |
| `craft/pacing.md` | 리듬 제어 | 완급 조절, 클라이맥스 설계, 전환 관리 |
| `craft/show-not-tell.md` | 보여주기 기법 | 감각 디테일, 행동 암시, 설교 회피 |

### 3. 참고 자료 베이스 (References)

특정 시대, 문화, 배경의 실제 자료.

| 디렉토리 | 내용 | 용도 |
|------|------|------|
| `references/china-1920s/` | 1920년대 중국 | 군벌 혼전, 사회 풍모, 일상생활 |
| └─ `warlords.md` | 군벌 체계 | 파벌 관계, 군대 편제, 권력 구조 |
| └─ `society.md` | 사회 구조 | 계층 분화, 도시-농촌 대비, 교육 상황 |
| └─ `daily-life.md` | 일상생활 | 의식주행, 화폐 물가, 오락 문화 |

**향후 확장**:
- `references/ancient-china/` - 고대 중국 각 왕조
- `references/modern-workplace/` - 현대 직장
- `references/mythology/` - 신화 체계
- ...(무한 확장 가능)

---

## 🔍 키워드 매핑 테이블

**용도**: `setting-detector` Skill이 사용하여 사용자 입력의 키워드에 따라 해당 지식 베이스를 자동 활성화합니다.

### 장르 지식 베이스 키워드

```yaml
romance:
  keywords: [로맨스, 사랑, 연애, 로맨틱, 감정선, 관계 아크, CP, 달달, 허허]
  auto_load: genres/romance.md

mystery:
  keywords: [미스터리, 추리, 탐정, 수사, 수수께끼, 단서, 진실, 범인, 범죄]
  auto_load: genres/mystery.md

historical:
  keywords: [역사, 고대, 왕조, 고증, 시대 배경, 역사 소설]
  auto_load: genres/historical.md

revenge:
  keywords: [복수, 역전, 통쾌, 쾌감소설, 반격]
  auto_load: genres/revenge.md

wuxia:
  keywords: [무협, 강호, 무공, 협객, 문파, 무학, 검객]
  auto_load: genres/wuxia.md
```

### 집필 기법 키워드

```yaml
dialogue:
  triggers: [대화, 캐릭터 말하기, 대사, 대화 장면, 담화]
  auto_load: craft/dialogue.md

scene-structure:
  triggers: [장면, 챕터 구조, 플롯 추진, 장면 설계]
  auto_load: craft/scene-structure.md

character-arc:
  triggers: [캐릭터 성장, 인물 아크, 캐릭터 변화, 성격 전환]
  auto_load: craft/character-arc.md

pacing:
  triggers: [리듬, 완급, 늘어짐, 클라이맥스, 긴장감]
  auto_load: craft/pacing.md

show-not-tell:
  triggers: [보여주기, 구체화, 설교, 감각 디테일, 묘사]
  auto_load: craft/show-not-tell.md
```

### 참고 자료 키워드

```yaml
china-1920s:
  keywords: [1920, 민국, 군벌, 북양, 민국 시대극, 이십년대]
  auto_load:
    - references/china-1920s/warlords.md
    - references/china-1920s/society.md
    - references/china-1920s/daily-life.md
```

---

## 🛠️ 사용 가이드

### 자동 활성화 흐름

1. **사용자가 키워드 언급**:
   ```
   사용자: "1920년대의 로맨스 복수 소설을 쓰고 싶어요"
   ```

2. **setting-detector 감지**:
   - "1920" 감지 → `references/china-1920s/` 활성화
   - "로맨스" 감지 → `genres/romance.md` 활성화
   - "복수" 감지 → `genres/revenge.md` 활성화

3. **주문형 로드**:
   ```
   ✓ genres/romance.md 로드 완료 (520 tokens)
   ✓ genres/revenge.md 로드 완료 (480 tokens)
   ✓ references/china-1920s/*.md 로드 완료 (650 tokens)

   합계: ~1650 tokens (관련 지식만 로드)
   ```

4. **지속 적용**:
   - `/specify` 시: 핵심 요소 제안
   - `/plan` 시: 구조 프레임워크 제공
   - `/write` 시: 실시간 집필 제안
   - `/analyze` 시: 장르 관례 검사

### 수동 지정 로드

자동 감지가 실패한 경우, 사용자가 명확히 지정할 수 있습니다:

```
"romance와 mystery 지식 베이스를 로드해주세요"
"이 스토리에는 1920s 중국 참고 자료가 필요합니다"
```

### 현재 활성화된 지식 베이스 확인

사용자가 언제든 물어볼 수 있습니다:
```
"현재 어떤 지식 베이스가 활성화되어 있나요?"
```

AI가 답변합니다:
```
📚 현재 활성화된 지식 베이스:
✓ genres/romance.md - 로맨스 소설 관례
✓ genres/revenge.md - 복수 쾌감소설 기법
✓ references/china-1920s/ - 1920년대 중국 자료
```

---

## 📦 지식 베이스 확장

### 새 지식 베이스 추가

1. **카테고리 결정**: genres / craft / references

2. **파일 생성**:
   ```bash
   # 장르 지식
   touch templates/knowledge-base/genres/sci-fi.md

   # 집필 기법
   touch templates/knowledge-base/craft/worldbuilding.md

   # 참고 자료
   mkdir -p templates/knowledge-base/references/ancient-rome
   touch templates/knowledge-base/references/ancient-rome/military.md
   ```

3. **매핑 테이블 업데이트**: 본 README의 키워드 매핑 테이블에 해당 항목 추가

4. **내용 작성**: 기존 지식 베이스의 형식 참고 (500-800행)

### 지식 베이스 형식 규범

각 지식 베이스 파일에 포함되어야 할 내용:

```markdown
# [지식 베이스 제목]

## 빠른 참조 (Quick Reference)
[1-3 단락 개요, 핵심 원칙 설명]

## 핵심 원칙 (Core Principles)
[3-5개 핵심 법칙, 상세 설명 포함]

## 실전 적용 (Practical Application)
[각 창작 단계에서 이 지식을 어떻게 적용하는지]

## 흔한 함정 (Common Pitfalls)
[장르 초보자가 자주 범하는 실수와 회피 방법]

## 예시 분석 (Examples)
[클래식 작품 사례 분석]

## Commands와의 통합 (Integration with Commands)
[/specify, /plan, /write, /analyze에서 어떻게 적용하는지]
```

### 클래식 소설에서 지식 베이스 추출

향후 클래식 소설을 해체하여 지식 베이스로 추출할 수 있습니다:

```bash
# 예시: 《삼체》에서 하드 SF 지식 추출
templates/knowledge-base/genres/hard-sci-fi.md

# 《홍루몽》에서 가문 서사 지식 추출
templates/knowledge-base/craft/family-saga.md
```

---

## 📊 지식 베이스 현황

**현재 상태**: 초기 버전

| 카테고리 | 완료 | 계획 중 | 합계 |
|------|--------|--------|------|
| 장르 지식 | 5 | 10+ | 15+ |
| 집필 기법 | 5 | 8+ | 13+ |
| 참고 자료 | 1 | 20+ | 21+ |

**다음 확장 계획**:
- [ ] 판타지 소설 (fantasy)
- [ ] SF 소설 (sci-fi)
- [ ] 호러 소설 (horror)
- [ ] 세계 구축 기법 (worldbuilding)
- [ ] 고대 중국 각 왕조 참고 자료
- [ ] 현대 도시 참고 자료

---

## 🔗 관련 문서

- **Skills 가이드**: `docs/skills-guide.md` - setting-detector Skill이 본 지식 베이스를 어떻게 사용하는지 이해
- **플러그인 개발**: `docs/plugin-development.md` - 지식 베이스 플러그인 개발 방법
- **명령어 상세**: `docs/commands.md` - 지식 베이스가 각 명령어를 어떻게 강화하는지

---

**지식 베이스 시스템 = Novel Writer Skills의 장기적 경쟁력**

전문 지식이 당신의 창작을 지원합니다! ✨📚
