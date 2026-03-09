---
name: pre-write-checklist
description: "챕터 집필 전 자동 활성화되어 9항목 필수 파일 읽기 체크리스트를 강제 적용 - 장편 소설에서 AI 집중력 저하를 방지하기 위해 매 집필 세션 전 모든 컨텍스트를 로드합니다"
allowed-tools: Read, Grep
---

# 집필 전 강제 체크리스트

## 핵심 기능

**AI 장편 집중력 저하 문제 해결** - Novel Writer Skills v1.0의 핵심 혁신입니다.

### 문제 근원

사용자 피드백: novel-writer로 창작 시, 처음 30장은 품질이 좋지만 30장 이후 AI가:
- 앞부분 설정을 잊어버림
- 캐릭터 성격이 일관되지 않음
- 플롯이 반복되거나 모순됨
- 창작 헌법의 원칙을 무시

**근본 원인**: 긴 대화로 AI가 초기 context를 잊어버림, specification.md를 아무리 상세히 써도 잊혀짐.

### 해결 방안

**매 집필 전 모든 핵심 파일을 강제 재읽기** → AI가 완전한 context를 재로드 → 일관성 유지

---

## 9항목 강제 체크리스트

매번 `/write` 명령 실행 시, 먼저 이 체크리스트를 완료해야:

```markdown
📋 집필 전 체크리스트 (필수 완료):

✓ 1. memory/constitution.md - 창작 헌법
✓ 2. memory/style-reference.md - 스타일 참조 (있는 경우)
✓ 3. stories/*/specification.md - 스토리 규격
✓ 4. stories/*/creative-plan.md - 창작 계획
✓ 5. stories/*/tasks.md - 현재 작업
✓ 6. spec/tracking/character-state.json - 캐릭터 상태
✓ 7. spec/tracking/relationships.json - 관계 네트워크
✓ 8. spec/tracking/plot-tracker.json - 플롯 추적 (있는 경우)
✓ 9. spec/tracking/validation-rules.json - 검증 규칙 (있는 경우)

📊 컨텍스트 로드 상태: ✅ 완료
```

---

## 작동 원리

### 자동 트리거 시점

1. **사용자가 `/write` 명령 실행**
2. **본 Skill 자동 활성화**
3. **체크리스트 강제 실행**
4. **확인 보고서 출력**
5. **그 후에야 집필 시작**

### 실행 흐름

```
사용자: /write 10장

         ↓

[pre-write-checklist 자동 활성화]

         ↓

1단계: memory/constitution.md 읽기
2단계: memory/style-reference.md 읽기 (있는 경우)
3단계: stories/*/specification.md 읽기
4단계: stories/*/creative-plan.md 읽기
5단계: stories/*/tasks.md 읽기
6단계: spec/tracking/character-state.json 읽기
7단계: spec/tracking/relationships.json 읽기
8단계: spec/tracking/plot-tracker.json 읽기 (있는 경우)
9단계: spec/tracking/validation-rules.json 읽기 (있는 경우)

         ↓

확인 출력:
📋 집필 전 체크리스트 (완료):
✓ 1-9 모든 파일 읽기 완료
📊 컨텍스트 로드 상태: ✅ 완료

핵심 정보 요약:
- 창작 원칙: [constitution에서 추출]
- 현재 작업: [tasks.md에서 추출]
- 주요 캐릭터: [character-state에서 추출]
- 플롯 진행: [plot-tracker에서 추출]

         ↓

10장 집필 시작...
```

---

## 출력 형식

### 표준 출력 (모든 파일 존재)

```markdown
📋 집필 전 체크리스트 (완료):

✓ 1. memory/constitution.md - 창작 헌법
   → 핵심 원칙: [2-3개 핵심 원칙 나열]

✓ 2. memory/style-reference.md - 스타일 참조
   → 스타일 요점: [핵심 스타일 요구 추출]

✓ 3. stories/xxx/specification.md - 스토리 규격
   → 이야기 장르: [로맨스/미스터리/역사 등]
   → P0 요소: [반드시 포함할 요소]

✓ 4. stories/xxx/creative-plan.md - 창작 계획
   → 현재 단계: [제X권/제X장]
   → 본 장 목표: [플롯/감정 목표]

✓ 5. stories/xxx/tasks.md - 현재 작업
   → 집필 대기 장: [제X장]
   → 작업 상태: [pending/in_progress]

✓ 6. spec/tracking/character-state.json - 캐릭터 상태
   → 주요 캐릭터: [캐릭터명과 현재 상태 나열]

✓ 7. spec/tracking/relationships.json - 관계 네트워크
   → 핵심 관계: [주인공과 누구의 관계 변화]

✓ 8. spec/tracking/plot-tracker.json - 플롯 추적
   → 활성 실마리: [현재 진행 중인 플롯 라인]

✓ 9. spec/tracking/validation-rules.json - 검증 규칙
   → 자동 수정: [활성/비활성]

📊 컨텍스트 로드 상태: ✅ 완료 (9개 파일 로드, 약 XXXX tokens)

🎯 제X장 집필 준비...
```

### 일부 파일 누락 시

```markdown
📋 집필 전 체크리스트 (부분 완료):

✓ 1. memory/constitution.md - 창작 헌법
✓ 2. ⚠️ memory/style-reference.md - 존재하지 않음 (선택 파일, 건너뜀)
✓ 3. stories/xxx/specification.md - 스토리 규격
✓ 4. stories/xxx/creative-plan.md - 창작 계획
✓ 5. stories/xxx/tasks.md - 현재 작업
✓ 6. spec/tracking/character-state.json - 캐릭터 상태
✓ 7. spec/tracking/relationships.json - 관계 네트워크
✓ 8. ⚠️ spec/tracking/plot-tracker.json - 존재하지 않음 (선택 파일, 건너뜀)
✓ 9. ⚠️ spec/tracking/validation-rules.json - 존재하지 않음 (선택 파일, 건너뜀)

📊 컨텍스트 로드 상태: ✅ 완료 (필수 6개 파일 + 선택 0개 파일 로드)

💡 제안: `/track-init`을 실행하여 전체 추적 시스템을 초기화하세요
```

### 핵심 파일 누락 시 (집필 차단)

```markdown
📋 집필 전 체크리스트 (실패):

✓ 1. memory/constitution.md - 창작 헌법
✓ 2. memory/style-reference.md - 스타일 참조
❌ 3. stories/xxx/specification.md - **파일 없음**
❌ 4. stories/xxx/creative-plan.md - **파일 없음**
❌ 5. stories/xxx/tasks.md - **파일 없음**

⛔ 오류: 필수 파일 누락, 집필을 계속할 수 없음

먼저 완료해야:
1. `/constitution` 실행하여 창작 헌법 생성
2. `/specify` 실행하여 스토리 규격 정의
3. `/plan` 실행하여 창작 계획 수립
4. `/tasks` 실행하여 작업 체크리스트 분해

그 후에야 `/write` 실행 가능

이것이 7단계 방법론의 권장 프로세스입니다.
```

---

## Commands와의 통합

### `/write` 명령

**반드시 체크리스트를 먼저 실행해야 집필 가능**:

```yaml
실행 순서:
1. pre-write-checklist (본 Skill) → 모든 파일 읽기
2. 확인 보고서 출력
3. setting-detector 검사 → 지식 베이스 활성화 필요 여부
4. 실제 집필 시작
```

### `/analyze` 명령

분석 시에도 체크리스트 실행 권장:

```yaml
분석 전 컨텍스트 완전성 확보:
1. pre-write-checklist → 모든 파일 재로드
2. 최신 상태 기반으로 분석 실행
```

### `/track` 명령

추적 업데이트 후 체크리스트 트리거:

```yaml
업데이트 흐름:
1. 사용자가 tracking 파일 수정
2. `/track` 실행하여 업데이트
3. pre-write-checklist → 재읽기 검증
```

---

## 파일 중요도 분류

### 필수 파일 (누락 시 집필 차단)

```
1. memory/constitution.md - 창작 원칙
3. stories/*/specification.md - 스토리 규격
4. stories/*/creative-plan.md - 창작 계획
5. stories/*/tasks.md - 현재 작업
6. spec/tracking/character-state.json - 캐릭터 상태
7. spec/tracking/relationships.json - 관계 네트워크
```

**논리**: 이 파일들이 없으면, AI가 알 수 없음:
- 어떤 원칙을 따라야 하는지
- 이야기가 무엇에 대한 것인지
- 현재 어디까지 썼는지
- 캐릭터가 누구이고 어떤 상태인지

### 선택 파일 (누락 시 경고하되 계속 허용)

```
2. memory/style-reference.md - 스타일 참조
8. spec/tracking/plot-tracker.json - 플롯 추적
9. spec/tracking/validation-rules.json - 검증 규칙
```

**논리**: 이 파일들은 품질을 향상시키지만, 최소 요건은 아님:
- style-reference: 일부 사용자는 /book-internalize를 사용하지 않음
- plot-tracker: 간단한 이야기에는 불필요할 수 있음
- validation-rules: 비필수 자동화

---

## 집중력 저하 방지 메커니즘

### 문제 시나리오

```
1장 집필:
- AI가 모든 설정을 기억
- 품질 좋음

10장 집필:
- 대화가 이미 매우 긺
- AI가 1장의 설정을 잊기 시작

30장 집필:
- 초기 설정을 완전히 잊음
- 캐릭터 성격 왜곡
- 플롯이 자기 모순
```

### 해결 메커니즘

```
매 집필 전:
- 모든 핵심 파일 강제 재읽기
- 완전한 컨텍스트 재로드
- 30장을 1장처럼 대우

결과:
- 30장 품질 ≈ 1장 품질
- 일관성 유지
- 더 이상 집중력 저하 없음
```

### 효과 비교

| 비교 차원 | 체크리스트 없음 | 체크리스트 있음 |
|---------|-------------|-------------|
| 1-10장 | ✓ 품질 좋음 | ✓ 품질 좋음 |
| 11-30장 | ⚠️ 불안정 시작 | ✓ 안정 유지 |
| 31-50장 | ❌ 뚜렷한 집중력 저하 | ✓ 여전히 안정 |
| 51+장 | ❌ 심각한 집중력 저하 | ✓ 장기 안정 |

---

## 설정 옵션

### 엄격도 조정

**기본: 엄격 모드** (권장)
```
"엄격 체크리스트 모드 사용"
→ 필수 파일 누락 시 집필 차단
```

**느슨한 모드** (비권장)
```
"느슨한 체크리스트 모드 사용"
→ 일부 파일 건너뛰기 허용 (비권장, 집중력 저하 가능)
```

### 사용자 정의 체크 항목

추가 중요 파일이 있는 경우:

```
"체크리스트에 다음을 추가로 포함해 주세요:
- spec/knowledge/worldbuilding/magic-system.md
- spec/knowledge/characters/protagonist-profile.md"
```

---

## 성능 최적화

### Token 소비

```
매 집필의 추가 token 비용:

9개 파일 읽기:
- constitution.md: ~200 tokens
- specification.md: ~500 tokens
- creative-plan.md: ~300 tokens
- tasks.md: ~150 tokens
- character-state.json: ~200 tokens
- relationships.json: ~150 tokens
- 기타: ~200 tokens

총계: 약 1700 tokens/집필 당

수익:
- 집중력 저하로 인한 재작성 방지 (수만 tokens 절약)
- 품질 일관성 유지 (사용자 만족도)
- 장편 프로젝트의 지속 가능성
```

**ROI 매우 높음**: 1700 tokens으로 장기 안정 품질 확보.

### 캐시 전략

```
같은 집필 세션 내:
첫 집필: 모든 파일 읽기 (1700 tokens)
두 번째 집필 (1시간 내): 파일 수정 여부 검사
- 수정 없음: 캐시 사용 (0 tokens)
- 수정됨: 재읽기 (일부 tokens)
```

---

## 자주 묻는 질문

### Q: 매번 이렇게 많은 파일을 읽으면 느리지 않나요?

**A**: 아닙니다.
- 파일 읽기는 빠름 (밀리초 단위)
- token 소비가 합리적 (~1700 tokens)
- 대가는 장기 품질 보증

**비교**:
- 체크리스트 없이: 30장 품질 저하 → 사용자가 10장 재작성 요청 → 수만 tokens 낭비
- 체크리스트 사용: 매장 +1700 tokens → 50장에도 +85000 tokens → 하지만 품질 안정

### Q: 체크리스트를 건너뛸 수 있나요?

**A**: 기술적으로 가능하지만, **강력히 비권장**.

```
"체크리스트 건너뛰고 바로 집필"
→ AI가 경고: "비권장, 집중력 저하 가능"
→ 하지만 선택을 존중
```

**결과는 본인 책임**: 30장 후 집중력 저하되면 제가 경고했음을 기억하세요

### Q: 일부 파일이 정말 없으면 어떻게?

**A**: 두 가지 경우:

**필수 파일 누락** (constitution, specification 등):
→ 집필 차단, 먼저 해당 명령을 실행하여 생성하라고 안내

**선택 파일 누락** (style-reference, plot-tracker):
→ 경고하되 계속 허용, 나중에 생성 권장

### Q: 체크리스트와 setting-detector의 관계는?

**A**: 상호 보완적:

```
pre-write-checklist:
- 프로젝트별 파일 로드 (당신의 이야기 데이터)

setting-detector:
- 범용 지식 베이스 로드 (장르 관습, 집필 기법)

둘의 결합 = 완전한 컨텍스트:
당신의 이야기 설정 + 장르 전문 지식
```

### Q: 100장 장편소설도 매번 다 읽어야 하나요?

**A**: 네, 그리고 **더욱 필요합니다**.

```
장편소설의 도전:
- 설정이 더 복잡
- 캐릭터가 더 많음
- 플롯 라인이 더 많음
- AI가 더 쉽게 잊음

체크리스트의 역할:
- 100장이 1장과 같은 품질 보장
- 캐릭터 성격 돌변 방지
- 플롯 자기 모순 방지

장편소설 품질 보증의 초석입니다.
```

---

## 모범 사례

### 1. 파일을 최신 상태로 유지

체크리스트는 AI가 파일을 읽게 할 뿐, 파일 내용이 정확해야:

```
✓ 캐릭터 상태 변화 → character-state.json 업데이트
✓ 관계 변화 → relationships.json 업데이트
✓ 새 플롯 라인 → plot-tracker.json 업데이트
```

### 2. 정기적으로 `/track` 실행

```
권장 빈도: 매 5-10장마다 `/track` 실행
효과:
- tracking 파일 업데이트
- 일관성 검증
- 잠재적 문제 발견
```

### 3. 중요 변경 후 수동 트리거

```
핵심 파일을 수동 수정한 경우:
"체크리스트를 재실행하여, 모든 파일을 재로드해 주세요"

AI가 최신 상태를 보도록 합니다.
```

### 4. consistency-checker와 배합

```
pre-write-checklist (집필 전):
- 모든 컨텍스트 로드
- 집필 준비

consistency-checker (집필 중/후):
- 일관성 모니터링
- 모순 발견
```

이중 보장 = 최고 품질.

---

## 기술 구현

### 파일 읽기 순서

```
우선순위 (중요한 것 먼저):
1. constitution (최고 원칙)
2. specification (이야기 핵심)
3. creative-plan (기술적 방안)
4. tasks (현재 작업)
5. character-state (캐릭터 데이터)
6. relationships (관계 데이터)
7. plot-tracker (플롯 추적)
8. validation-rules (검증 규칙)
9. style-reference (스타일 참조)
```

### 오류 처리

```
파일 없음:
→ 필수 파일: 집필 차단, 생성 안내
→ 선택 파일: 경고, 계속 허용

파일 형식 오류:
→ JSON 파싱 실패: 오류 표시, 수정 제안
→ Markdown 형식 문제: 최선을 다해 읽기, 문제 표시

파일 너무 큼:
→ 10000행 초과: 경고 (성능에 영향 가능)
→ 파일 분할 제안
```

---

## 요약

pre-write-checklist는 Novel Writer Skills v1.0의 **핵심 혁신**입니다:

✓ AI 장편 집중력 저하 문제 해결
✓ 핵심 파일 강제 재읽기
✓ 컨텍스트 완전성 확보
✓ 품질 장기 안정 유지
✓ 전문 작가의 장편 창작에 적합

**30장 이후에도 집중력 저하 없음 = 장기 경쟁력** 🎯

---

**본 Skill 버전**: v1.0
**최종 업데이트**: 2025-10-18
**핵심 문제**: 30장 후 AI 집중력 저하 해결
**배합**: write.md, setting-detector, consistency-checker
