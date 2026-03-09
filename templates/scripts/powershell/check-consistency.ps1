#!/usr/bin/env pwsh
# 종합 일관성 검사 (PowerShell)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. "$PSScriptRoot/common.ps1"

$root = Get-ProjectRoot
$storyDir = Get-CurrentStoryDir
if (-not $storyDir) { throw "스토리 프로젝트를 찾을 수 없습니다 (stories/*)" }

$progress = Join-Path $storyDir "progress.json"
$plot = Join-Path $storyDir "spec/tracking/plot-tracker.json"
if (-not (Test-Path $plot)) { $plot = Join-Path $root "spec/tracking/plot-tracker.json" }
$timeline = Join-Path $storyDir "spec/tracking/timeline.json"
if (-not (Test-Path $timeline)) { $timeline = Join-Path $root "spec/tracking/timeline.json" }
$rels = Join-Path $storyDir "spec/tracking/relationships.json"
if (-not (Test-Path $rels)) { $rels = Join-Path $root "spec/tracking/relationships.json" }
$charState = Join-Path $storyDir "spec/tracking/character-state.json"
if (-not (Test-Path $charState)) { $charState = Join-Path $root "spec/tracking/character-state.json" }

$TOTAL=0; $PASS=0; $WARN=0; $ERR=0
function Check([string]$name, [bool]$ok, [string]$msg) {
  $script:TOTAL++
  if ($ok) { Write-Host "✓ $name" -ForegroundColor Green; $script:PASS++ }
  else { Write-Host "✗ $name: $msg" -ForegroundColor Red; $script:ERR++ }
}
function Warn([string]$msg) { Write-Host "⚠ $msg" -ForegroundColor Yellow; $script:WARN++ }

function Check-FileIntegrity {
  Write-Host "📁 파일 무결성 검사"
  Write-Host "────────────────"
  Check "progress.json" (Test-Path $progress) "파일이 존재하지 않습니다"
  Check "plot-tracker.json" (Test-Path $plot) "파일이 존재하지 않습니다"
  Check "timeline.json" (Test-Path $timeline) "파일이 존재하지 않습니다"
  Check "relationships.json" (Test-Path $rels) "파일이 존재하지 않습니다"
  Check "character-state.json" (Test-Path $charState) "파일이 존재하지 않습니다"
  Write-Host ""
}

function Check-ChapterConsistency {
  Write-Host "📖 챕터 번호 일관성 검사"
  Write-Host "───────────────────"
  if ((Test-Path $progress) -and (Test-Path $plot)) {
    $p = Get-Content -LiteralPath $progress -Raw -Encoding UTF8 | ConvertFrom-Json
    $j = Get-Content -LiteralPath $plot -Raw -Encoding UTF8 | ConvertFrom-Json
    $pCh = [int]($p.statistics.currentChapter ?? 0)
    $plCh = [int]($j.currentState.chapter ?? 0)
    Check "챕터 번호 동기화" ($pCh -eq $plCh) "progress($pCh) != plot-tracker($plCh)"
    if (Test-Path $charState) {
      $cs = Get-Content -LiteralPath $charState -Raw -Encoding UTF8 | ConvertFrom-Json
      $csCh = [int]($cs.protagonist.currentStatus.chapter)
      if (-not $csCh) { $csCh = [int]($cs.characters.'주인공'.lastSeen.chapter) }
      if ($csCh) { Check "캐릭터 상태 챕터 동기화" ($pCh -eq $csCh) "character-state($csCh)와 불일치" }
    }
  } else { Warn "일부 추적 파일이 누락되어 챕터 검사를 완료할 수 없습니다" }
  Write-Host ""
}

function Check-TimelineConsistency {
  Write-Host "⏰ 타임라인 연속성 검사"
  Write-Host "───────────────────"
  if (Test-Path $timeline) {
    $j = Get-Content -LiteralPath $timeline -Raw -Encoding UTF8 | ConvertFrom-Json
    $events = @($j.events | Sort-Object chapter)
    $issues=0; $prev=-1
    foreach ($e in $events) { if ($prev -ge 0 -and $e.chapter -le $prev) { $issues++ }; $prev=$e.chapter }
    Check "시간 이벤트 순서" ($issues -eq 0) "${issues}개의 순서 이상 이벤트 발견"
    $curTime = $j.storyTime.current
    Check "현재 시간 설정" ([bool]$curTime) "현재 스토리 시간이 설정되지 않았습니다"
  } else { Warn "타임라인 파일이 존재하지 않습니다" }
  Write-Host ""
}

function Check-CharacterConsistency {
  Write-Host "👥 캐릭터 상태 합리성 검사"
  Write-Host "─────────────────────"
  if ((Test-Path $charState) -and (Test-Path $rels)) {
    $cs = Get-Content -LiteralPath $charState -Raw -Encoding UTF8 | ConvertFrom-Json
    $rel = Get-Content -LiteralPath $rels -Raw -Encoding UTF8 | ConvertFrom-Json
    $name = $cs.protagonist.name
    if (-not $name) { $name = $cs.characters.'주인공'.name }
    if ($name) {
      $has = $false
      if ($rel.characters) { $has = $rel.characters.PSObject.Properties.Name -contains $name }
      Check "주인공 관계 기록" $has "주인공 '$name'이 relationships에 기록되지 않았습니다"
    }
    $loc = $cs.protagonist.currentStatus.location
    if (-not $loc) { $loc = $cs.characters.'주인공'.location }
    Check "주인공 위치 기록" ([bool]$loc) "주인공의 현재 위치가 기록되지 않았습니다"
  } else { Warn "캐릭터 추적 파일이 불완전합니다" }
  Write-Host ""
}

function Check-ForeshadowingPlan {
  Write-Host "🎯 복선 관리 검사"
  Write-Host "──────────────"
  if (Test-Path $plot) {
    $j = Get-Content -LiteralPath $plot -Raw -Encoding UTF8 | ConvertFrom-Json
    $fs = @($j.foreshadowing)
    $total = $fs.Count
    $active = @($fs | Where-Object { $_.status -eq 'active' }).Count
    Write-Host "  📊 복선 통계: 총 ${total}개, 활성 ${active}개"
    if ($active -gt 10) { Warn "활성 복선이 과다합니다(${active}개). 독자 혼란을 야기할 수 있습니다" }
  } else { Warn "줄거리 추적 파일이 존재하지 않습니다" }
  Write-Host ""
}

Write-Host "═══════════════════════════════════════"
Write-Host "📊 종합 일관성 검사 보고서"
Write-Host "═══════════════════════════════════════"
Write-Host ""

Check-FileIntegrity
Check-ChapterConsistency
Check-TimelineConsistency
Check-CharacterConsistency
Check-ForeshadowingPlan

Write-Host "═══════════════════════════════════════"
Write-Host "📈 검사 결과 요약"
Write-Host "───────────────────"
Write-Host "  총 검사 항목: $TOTAL"
Write-Host "  통과: $PASS"
Write-Host "  경고: $WARN"
Write-Host "  오류: $ERR"

if ($ERR -eq 0 -and $WARN -eq 0) { Write-Host "`n✅ 완벽! 모든 검사 항목을 통과했습니다" -ForegroundColor Green }
elseif ($ERR -eq 0) { Write-Host "`n⚠️  ${WARN}개의 경고가 있습니다. 확인을 권장합니다" -ForegroundColor Yellow }
else { Write-Host "`n❌ ${ERR}개의 오류가 발견되었습니다. 수정이 필요합니다" -ForegroundColor Red }

Write-Host "═══════════════════════════════════════"
Write-Host "검사 시간: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"

if ($ERR -gt 0) { exit 1 } else { exit 0 }
