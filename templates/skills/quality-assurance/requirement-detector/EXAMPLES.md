# 완전한 대화 예시와 성공 사례

본 문서는 requirement-detector의 실제 사용 시 완전한 대화 흐름을 보여줍니다.

---

## 예시 1: 기본 규범 탐지

**사용자**:
> "현대 로맨스를 쓰려는데, 달달한 글로, AI 느낌은 빼주세요"

**requirement-detector 응답**:
```
📋 규범 탐지기 활성화

감지된 키워드:
- "달달한 글" → romance-sweet
- "AI 느낌 빼주세요" → anti-ai-v4

제안 규범 조합:
1. romance-sweet (달달한 글 규범)
2. anti-ai-v4 (강력 AI 느낌 제거)

✅ 규범 문서 로드 완료
✅ 설정 작성 완료:
   writing-requirements:
     - romance-sweet
     - anti-ai-v4

배합 제안:
💡 "현대 로맨스"를 감지했습니다. style-detector를 활성화하여
   natural-voice 스타일을 선택하는 것도 추천합니다.
```

---

## 예시 2: style-detector와 협동

**사용자**:
> "도시 쾌감물을 쓰려는데, 구어체로, AI 느낌도 빼주세요"

**system (두 detector 협동)**:
```
🎨 style-detector 활성화
감지됨: 구어체 → natural-voice

📋 requirement-detector 활성화
감지됨: 쾌감물 → fast-paced
감지됨: AI 느낌 제거 → anti-ai-v4

✅ 추천 설정 조합:

스타일 레이어: natural-voice
규범 레이어: fast-paced + anti-ai-v4

최종 효과:
자연스러운 구어체의 빠른 리듬 쾌감물, 강력한 AI 느낌 제거

설정 작성 완료:
---
writing-style: natural-voice
writing-requirements:
  - fast-paced
  - anti-ai-v4
---

이 조합이 요구에 특히 적합합니다. 적용을 확인하시겠습니까?
```

---

## 예시 3: 충돌 처리

**사용자**:
> "순수문학을 쓰려는데, 매 장마다 쾌감 포인트도 넣고 싶어요"

**requirement-detector 응답**:
```
⚠️ 규범 충돌 감지

감지됨:
- serious-literature ("순수문학" 때문에)
- fast-paced ("매 장마다 쾌감 포인트" 때문에)

이 두 규범은 근본적으로 충돌합니다:
- 순수문학: 느린 리듬, 사상성
- 빠른 리듬 쾌감물: 밀집 갈등, 쾌감 우선

제안:
1. serious-literature 선택, "쾌감 포인트"를 "감정 클라이맥스"로 조정
   → strong-emotion으로 fast-paced를 대체 가능
2. fast-paced 선택, "깊이 있는 쾌감물"로 조정
   → 쾌감 포인트 밀도를 낮추고, 사상성 추가

어떤 방향을 선호하시나요?
```

---

## 예시 4: 능동적 제안

**사용자가 이미 natural-voice 스타일을 선택한 상태**

**requirement-detector 능동적 제안**:
```
💡 규범 제안

natural-voice (자연스러운 목소리 스타일)를 선택하신 것을 감지했습니다.

배합 추천 규범:
1. **anti-ai-v4** - natural-voice와 완벽 배합, 극도의 자연스러움
2. **no-poison** - 논리적 합리성 보장, 지력저하 방지
3. **fast-paced** (선택) - 상업적 쾌감물을 쓰는 경우

추천 조합:
natural-voice + anti-ai-v4 + no-poison
= 극도로 자연스럽고, 논리 자족한 현대소설

이 규범들을 로드하시겠습니까?
```

---

## 사용 팁

1. **요구를 명확히**: 원하는 효과를 명확히 말하세요 (쾌감물, 학대 글, AI 느낌 제거 등)
2. **탐지를 신뢰**: 탐지기가 경험에 기반하여 추천합니다
3. **조합 사용**: 호환 가능한 여러 규범을 겹쳐 사용 가능
4. **충돌 주의**: 충돌 발생 시, 가장 중요한 요구를 선택
5. **스타일과 배합**: 규범(requirement) + 스타일(style) 조합이 더 효과적

---

## 자주 묻는 질문

**Q: 여러 규범을 동시에 사용할 수 있나요?**
A: 가능하지만, 호환성에 주의하세요. [CONFLICT_RESOLUTION.md](CONFLICT_RESOLUTION.md)를 참조하세요.

**Q: anti-ai-v4와 anti-ai-v3의 차이점은?**
A: v4는 강력 버전으로 제한이 더 엄격; v3는 표준 버전으로 더 균형적입니다.

**Q: 쾌감물 규범이 문학성에 영향을 주나요?**
A: fast-paced는 리듬과 쾌감 포인트를 강조하여, serious-literature와 충돌합니다. 하지만 literary 스타일과는 배합 가능합니다.

**Q: 달달한 글과 학대 글을 혼합할 수 있나요?**
A: 추천하지 않지만, 단계별 사용(먼저 달달, 후에 학대)은 가능합니다. CONFLICT_RESOLUTION.md에서 상세 내용을 참조하세요.
