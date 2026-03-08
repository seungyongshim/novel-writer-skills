---
name: track-init
description: 스토리 대강을 기반으로 추적 시스템 초기화
allowed-tools: Read(//stories/**/specification.md), Read(stories/**/specification.md), Read(//stories/**/outline.md), Read(stories/**/outline.md), Read(//stories/**/creative-plan.md), Read(stories/**/creative-plan.md), Write(//spec/tracking/**), Write(spec/tracking/**), Bash(find:*), Bash(grep:*), Bash(wc:*), Bash(*)
model: claude-sonnet-4-5-20250929
scripts:
  sh: .specify/scripts/bash/init-tracking.sh
  ps: .specify/scripts/powershell/init-tracking.ps1
---

# 추적 시스템 초기화

이미 작성된 스토리 대강과 챕터 계획을 기반으로 모든 추적 데이터 파일을 초기화합니다.

## 사용 시점

`/story`와 `/outline` 완료 후, 집필 시작 전에 이 명령을 실행합니다.

## 초기화 흐름

1. **기초 데이터 읽기**
   - `stories/*/story.md`에서 스토리 설정 읽기
   - `stories/*/outline.md`에서 챕터 계획 읽기
   - `.specify/config.json`에서 집필 방법 읽기

2. **추적 파일 초기화**

   **중요**: `specification.md` 제5장의 단서 관리 사양을 우선 읽어 추적 파일에 반영합니다.

   `spec/tracking/plot-tracker.json` 생성 또는 업데이트:
   - `specification.md 5.1절`에서 모든 단서 정의 읽기
   - `specification.md 5.3절`에서 모든 교차점 읽기
   - `specification.md 5.4절`에서 모든 복선 읽기
   - `creative-plan.md`에서 챕터 단위의 단서 분포 읽기
   - 현재 상태 설정 (아직 집필 시작 전이라고 가정)

   **plot-tracker.json 구조**:
   ```json
   {
     "novel": "[specification.md에서 스토리 이름 읽기]",
     "lastUpdated": "[YYYY-MM-DD]",
     "currentState": {
       "chapter": 0,
       "volume": 1,
       "mainPlotStage": "[초기 단계]"
     },
     "plotlines": {
       "main": {
         "name": "[주선 이름]",
         "status": "active",
         "currentNode": "[시작점]",
         "completedNodes": [],
         "upcomingNodes": "[교차점과 챕터 계획에서 읽기]"
       },
       "subplots": [
         {
           "id": "[5.1에서 읽기, 예: PL-01]",
           "name": "[단서 이름]",
           "type": "[주선/부선/주선지원]",
           "priority": "[P0/P1/P2]",
           "status": "[active/dormant]",
           "plannedStart": "[시작 챕터]",
           "plannedEnd": "[종료 챕터]",
           "currentNode": "[현재 노드]",
           "completedNodes": [],
           "upcomingNodes": "[교차점 표에서 읽기]",
           "intersectionsWith": "[5.3 교차점 표에서 관련 단서 읽기]",
           "activeChapters": "[5.2 리듬 계획에서 읽기]"
         }
       ]
     },
     "foreshadowing": [
       {
         "id": "[5.4에서 읽기, 예: F-001]",
         "content": "[복선 내용]",
         "planted": {"chapter": null, "description": "[배치 설명]"},
         "hints": [],
         "plannedReveal": {"chapter": "[해소 챕터]", "description": "[해소 방식]"},
         "status": "planned",
         "importance": "[high/medium/low]",
         "relatedPlotlines": "[관련 단서 ID 목록]"
       }
     ],
     "intersections": [
       {
         "id": "[5.3에서 읽기, 예: X-001]",
         "chapter": "[교차 챕터]",
         "plotlines": "[관련 단서 ID 목록]",
         "content": "[교차 내용]",
         "status": "upcoming",
         "impact": "[예상 효과]"
       }
     ]
   }
   ```

   `spec/tracking/timeline.json` 생성 또는 업데이트:
   - 챕터 계획에 따른 시간 노드 설정
   - 중요 시간 이벤트 표기

   `spec/tracking/relationships.json` 생성 또는 업데이트:
   - 캐릭터 설정에서 초기 관계 추출
   - 세력 그룹 설정

   `spec/tracking/character-state.json` 생성 또는 업데이트:
   - 캐릭터 상태 초기화
   - 시작 위치 설정

3. **추적 보고서 생성**
   초기화 결과를 표시하고, 추적 시스템이 준비됨을 확인

## 스마트 연관

- 집필 방법에 따라 자동으로 체크포인트 설정
- 영웅의 여정: 12단계 추적 포인트
- 3막 구조: 3막 전환점
- 7포인트 구조: 7개 핵심 노드

추적 시스템 초기화 후, 이후 집필 시 이 데이터가 자동으로 업데이트됩니다.
