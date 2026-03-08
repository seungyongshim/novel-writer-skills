---
name: relations
description: 캐릭터 관계 관리 및 변화 추적
argument-hint: [update | show | history | check] [캐릭터] [관계] [대상 캐릭터]
allowed-tools: Read(//spec/tracking/relationships.json), Read(spec/tracking/relationships.json), Write(//spec/tracking/relationships.json), Write(spec/tracking/relationships.json), Bash(find:*), Bash(*)
model: claude-sonnet-4-5-20250929
scripts:
  sh: .specify/scripts/bash/manage-relations.sh
  ps: .specify/scripts/powershell/manage-relations.ps1
---

# 캐릭터 관계 관리

캐릭터 간의 관계 동태를 추적하고 관리하여, 관계 발전의 합리성을 보장합니다.

## 기능

1. **관계 네트워크** - 캐릭터 간의 관계 맵 유지
2. **관계 변화** - 관계의 변천 과정 기록
3. **세력 관리** - 각 세력/파벌의 대립과 협력 추적
4. **감정 추적** - 캐릭터 간의 감정 발전 관리

## 사용 방법

스크립트 {SCRIPT} [작업] [매개변수] 실행:
- `update` - 캐릭터 관계 업데이트
- `show` - 관계 네트워크 표시
- `history` - 관계 변화 이력 조회
- `check` - 관계 논리 검증

예시:
```
{SCRIPT} update 이중용 allies 심옥경 --chapter 61 --note 한림원 입문 시 도움
# PowerShell:
{SCRIPT} -Command update -A 이중용 -Relation allies -B 심옥경 -Chapter 61 -Note 한림원 입문 시 도움
```

## 데이터 저장

관계 데이터는 `spec/tracking/relationships.json`에 저장됩니다:
```json
{
  "characters": {
    "주인공": {
      "동맹": ["캐릭터A", "캐릭터B"],
      "적대": ["캐릭터C"],
      "사모": ["캐릭터D"],
      "미상": ["캐릭터E"]
    }
  },
  "factions": {
    "개혁파": ["주인공", "캐릭터A"],
    "보수파": ["캐릭터C", "캐릭터F"]
  }
}
```

## 출력 예시

```
👥 캐릭터 관계 네트워크
━━━━━━━━━━━━━━━━━━━━
주인공: 이중용
├─ 💕 사모: 심옥경
├─ 🤝 동맹: 장거정 (은밀)
├─ 📚 스승: 마테오 리치
├─ ⚔️ 적대: 신시행 파벌
└─ 👁️ 감시: 동창

세력 대립:
개혁파 ←→ 보수파
동림당 ←→ 환관당

최근 변화 (제60장):
- 심옥경: 낯선 사람 → 서로 끌리는 관계
- 장거정: 미상 → 사제 관계
```
