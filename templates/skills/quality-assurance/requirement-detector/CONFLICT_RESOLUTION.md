# 다중 규범 탐지와 충돌 처리

여러 규범 키워드가 탐지되면, 충돌 검사를 수행하고 해결 방안을 제공해야 합니다.

---

## 호환 가능한 조합 예시

### fast-paced + anti-ai-v4

**사용자 발언**:
> "쾌감물을 쓰려는데, 리듬 빠르게, 그리고 AI 느낌도 제거해주세요"

**처리 방식**:
```markdown
🔍 다중 규범 탐지 결과

감지됨:
- fast-paced ("쾌감물, 리듬 빠르게" 때문에)
- anti-ai-v4 ("AI 느낌 제거" 때문에)

이 두 규범은 조합 사용이 가능합니다!

추천 설정:
writing-requirements:
  - fast-paced
  - anti-ai-v4

효과: 빠른 리듬 쾌감물 + 강력한 AI 느낌 제거 = 자연스럽고 유창한 상업적 웹소설

이 조합을 적용하시겠습니까?
```

---

## 충돌 조합 예시

### serious-literature + fast-paced

**사용자 발언**:
> "순수문학을 쓰려는데, 매 장마다 쾌감 포인트도 넣고 싶어요"

**처리 방식**:
```markdown
⚠️ 규범 충돌 감지

감지됨:
- serious-literature (순수문학) - 느린 리듬, 깊이 요구
- fast-paced (빠른 리듬 쾌감물) - 매 장 2개 쾌감 포인트 요구

이 두 규범은 근본적으로 충돌합니다:
- 순수문학: 느린 리듬, 사상성, 열린 결말
- 빠른 리듬 쾌감물: 밀집 갈등, 쾌감 우선, 패턴화

제안:
1. serious-literature 선택, "매 장 쾌감 포인트" 요구를 포기
2. fast-paced 선택, "깊이 있는 쾌감물"로 조정
3. strong-emotion (강한 감정)을 절충안으로 고려

어떤 방향을 선호하시나요?
```

---

### romance-sweet + romance-angst

**사용자 발언**:
> "달달한 글을 쓰려는데, 좀 학대(?) 요소도 넣고 싶어요"

**처리 방식**:
```markdown
⚠️ 달달-학대 충돌 감지

감지됨:
- romance-sweet (달달한 글) - 장기간 학대 금지
- romance-angst (학대 글) - 학대 요소 플롯 필요

제안 처리 방식:

1. **먼저 달달, 후에 학대** (학대 연애)
   - 전반부: romance-sweet
   - 후반부: romance-angst

2. **학대 속에 달달** (미세 학대)
   - 메인: romance-sweet
   - 허용: 짧은 소학대 (1-2장)
   - 달달-학대 비율: 80% 달달 / 20% 학대

3. **BE 달달글** (먼저 달달, 후에 칼)
   - 전기: romance-sweet
   - 결말: romance-angst (BE)

어떤 모드를 원하시나요?
```

---

## 충돌 매트릭스

| 조합 | 호환성 | 설명 |
|------|--------|------|
| anti-ai-v4 + fast-paced | ✅ 호환 | 극도로 자연스러운 쾌감물 |
| anti-ai-v4 + no-poison | ✅ 호환 | 자연스럽고 논리적 |
| anti-ai-v4 + romance-sweet | ✅ 호환 | 자연스러운 달달한 글 |
| fast-paced + no-poison | ✅ 호환 | 합리적인 쾌감물 |
| fast-paced + strong-emotion | ✅ 호환 | 감정 풍부한 쾌감물 |
| serious-literature + fast-paced | ❌ 충돌 | 느린 리듬 vs 빠른 리듬 |
| serious-literature + romance-sweet | ⚠️ 주의 | 시도 가능하나, 균형 필요 |
| romance-sweet + romance-angst | ❌ 충돌 | 달달 vs 학대 |

---

## 처리 원칙

1. **사용자 의도 우선**: 사용자가 명확히 표현한 선호를 존중
2. **옵션 제공**: 충돌 발생 시 해결 방안 제시
3. **이유 설명**: 왜 충돌하는지 설명
4. **조합 지원**: 호환 가능한 조합에 대해, 사용 권장
5. **조정 허용**: 중도 규범 전환 지원
