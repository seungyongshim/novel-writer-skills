#!/usr/bin/env pwsh
# 소설 창작 진행도 종합 추적 (PowerShell)

param(
  [switch]$check,
  [switch]$fix,
  [switch]$brief,
  [switch]$plot,
  [switch]$stats
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. "$PSScriptRoot/common.ps1"

$root = Get-ProjectRoot
$storyDir = Get-CurrentStoryDir
$progress = Join-Path $root "stories/current/progress.json"
$plotPath = Join-Path $root "spec/tracking/plot-tracker.json"

function Show-BasicReport {
  Write-Host "📊 소설 창작 종합 보고서"
  Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  if (Test-Path $progress) {
    Write-Host "✍️ 집필 진행도"
    Write-Host "  완료 상황 분석 대기 중..."
  }
  if (Test-Path $plotPath) {
    Write-Host "📍 줄거리 상태"
    Write-Host "  메인 스토리 진행도 분석 대기 중..."
  }
}

function Run-DeepCheck {
  Write-Host "🔍 심층 검증 실행 중..."
  Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  Write-Host "Phase 1: 기본 검증"
  Write-Host "  [P] 줄거리 일관성 검사 실행..."
  Write-Host "  [P] 타임라인 검증 실행..."
  Write-Host "  [P] 관계 검증 실행..."
  Write-Host "  [P] 세계관 검증 실행..."
  Write-Host "Phase 2: 캐릭터 심층 검증"
  $rules = Join-Path $root "spec/tracking/validation-rules.json"
  if (Test-Path $rules) {
    Write-Host "  ✅ 검증 규칙 로드 완료"
    Set-Content -LiteralPath "$env:TEMP/validation-tasks.md" -Encoding UTF8 -Value @"
# 검증 작업 (자동 생성)

## Phase 1: 기본 검증 [병렬]
- [ ] T001 [P] 줄거리 일관성 검사 실행
- [ ] T002 [P] 타임라인 검증 실행
- [ ] T003 [P] 관계 검증 실행
- [ ] T004 [P] 세계관 검증 실행

## Phase 2: 캐릭터 검증
- [ ] T005 validation-rules.json 로드
- [ ] T006 챕터 내 캐릭터 이름 스캔
- [ ] T007 이름 일관성 검증
- [ ] T008 호칭 정확성 확인
- [ ] T009 행동 일관성 검증

## Phase 3: 보고서 생성
- [ ] T010 결과 취합
- [ ] T011 문제 표시
- [ ] T012 개선 제안 생성
"@
    Write-Host "  ✅ 검증 작업 생성 완료"
  } else {
    Write-Host "  ⚠️ 검증 규칙 파일을 찾을 수 없습니다"
  }
  Write-Host "📊 심층 검증 보고서"
  Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━"
  Write-Host "AI가 모든 챕터를 분석하여 상세 보고서를 생성합니다..."
  Write-Host "💡 팁: 문제 발견 시 --fix 를 실행하여 자동 수정할 수 있습니다"
}

function Run-AutoFix {
  Write-Host "🔧 자동 수정 실행 중..."
  Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  Set-Content -LiteralPath "$env:TEMP/fix-tasks.md" -Encoding UTF8 -Value @"
# 수정 작업 (자동 생성)

## Phase 1: 간단한 수정 [자동 가능]
- [ ] F001 검증 보고서 읽기
- [ ] F002 [P] 캐릭터 이름 오류 수정
- [ ] F003 [P] 호칭 오류 수정
- [ ] F004 [P] 간단한 오탈자 수정

## Phase 2: 보고서 생성
- [ ] F005 수정 결과 취합
- [ ] F006 추적 파일 업데이트
"@
  Write-Host "🔧 자동 수정 보고서"
  Write-Host "━━━━━━━━━━━━━━━━━━━"
  Write-Host "AI가 간단한 문제를 자동으로 수정합니다..."
}

if ($check) { Run-DeepCheck }
elseif ($fix) { Run-AutoFix }
else { Show-BasicReport }

Write-Host ""
Write-Host "✅ 추적 분석 완료"
