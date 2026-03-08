---
name: timeline
description: 스토리 타임라인 관리 및 검증
argument-hint: [add | check | show | sync]
allowed-tools: Read(//spec/tracking/timeline.json), Read(spec/tracking/timeline.json), Write(//spec/tracking/timeline.json), Write(spec/tracking/timeline.json), Read(//stories/**/content/**), Read(stories/**/content/**), Bash(find:*), Bash(*)
model: claude-sonnet-4-5-20250929
scripts:
  sh: .specify/scripts/bash/check-timeline.sh
  ps: .specify/scripts/powershell/check-timeline.ps1
---

# 타임라인 관리

스토리의 시간축을 유지하고, 시간 논리의 일관성을 보장합니다.

## 기능

1. **시간 기록** - 각 챕터의 시간점 추적
2. **병행 이벤트** - 동시에 발생하는 다중 줄거리 관리
3. **역사 대조** - 실제 역사 사건과 비교 (역사 소설)
4. **논리 검증** - 시간 간격의 합리성 검사

## 사용 방법

스크립트 {SCRIPT}를 실행하며, 다음 작업을 지원합니다:
- `add` - 시간 노드 추가
- `check` - 시간 연속성 검증
- `show` - 타임라인 개요 표시
- `sync` - 병행 이벤트 동기화

## 타임라인 데이터

타임라인 정보는 `spec/tracking/timeline.json`에 저장됩니다:
- 스토리 내 시간 (년/월/일)
- 챕터 대응 관계
- 중요 이벤트 표시
- 시간 간격 계산

## 출력 예시

```
📅 스토리 타임라인
━━━━━━━━━━━━━━━━━━━━
현재 시간: 만력 30년 봄

제1장  | 만력 29년 동짓달 | 전이 사건
제4장  | 만력 30년 정월   | 북상 과거시험
제6장  | 만력 30년 2월    | 회시
제8장  | 만력 30년 3월    | 전시
제61장 | 만력 30년 4월    | [미작성]

⏱️ 시간 간격: 5개월
🔄 병행 이벤트: 일본의 조선 침략
```
