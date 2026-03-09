#!/usr/bin/env pwsh
# 줄거리 전개의 일관성과 연속성 검사 (PowerShell)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. "$PSScriptRoot/common.ps1"

$root = Get-ProjectRoot
$storyDir = Get-CurrentStoryDir
if (-not $storyDir) { throw "스토리 프로젝트를 찾을 수 없습니다 (stories/*)" }

$plotPath = Join-Path $storyDir "spec/tracking/plot-tracker.json"
if (-not (Test-Path $plotPath)) { $plotPath = Join-Path $root "spec/tracking/plot-tracker.json" }
$outlinePath = Join-Path $storyDir "outline.md"
$progressPath = Join-Path $storyDir "progress.json"

function Ensure-PlotTracker {
  if (-not (Test-Path $plotPath)) {
    Write-Host "⚠️  줄거리 추적 파일을 찾을 수 없어 생성 중..."
    $tpl = Join-Path $root "templates/tracking/plot-tracker.json"
    if (-not (Test-Path $tpl)) { throw "템플릿 파일을 찾을 수 없습니다" }
    New-Item -ItemType Directory -Path (Split-Path $plotPath -Parent) -Force | Out-Null
    Copy-Item $tpl $plotPath -Force
  }
  if (-not (Test-Path $outlinePath)) { throw "챕터 개요 outline.md 를 찾을 수 없습니다. 먼저 /outline 을 사용하세요" }
}

function Get-CurrentProgress {
  if (Test-Path $progressPath) {
    $p = Get-Content -LiteralPath $progressPath -Raw -Encoding UTF8 | ConvertFrom-Json
    return @{ chapter = ($p.statistics.currentChapter ?? 1); volume = ($p.statistics.currentVolume ?? 1) }
  }
  if (Test-Path $plotPath) {
    $j = Get-Content -LiteralPath $plotPath -Raw -Encoding UTF8 | ConvertFrom-Json
    return @{ chapter = ($j.currentState.chapter ?? 1); volume = ($j.currentState.volume ?? 1) }
  }
  return @{ chapter = 1; volume = 1 }
}

function Analyze-PlotAlignment {
  Write-Host "📊 줄거리 전개 검사 보고서"
  Write-Host "━━━━━━━━━━━━━━━━━━━━"
  $cur = Get-CurrentProgress
  Write-Host "📍 현재 진행: 제$($cur.chapter)장 (제$($cur.volume)권)"

  if (Test-Path $plotPath) {
    $j = Get-Content -LiteralPath $plotPath -Raw -Encoding UTF8 | ConvertFrom-Json
    $main = $j.plotlines.main
    $mainPlot = $main.currentNode
    $status = $main.status
    Write-Host "📖 메인 스토리 진행: $mainPlot [$status]"

    $completed = @($main.completedNodes)
    Write-Host ""
    Write-Host "✅ 완료된 노드: $($completed.Count)개"
    $completed | ForEach-Object { Write-Host "  • $_" }

    $upcoming = @($main.upcomingNodes)
    if ($upcoming.Count -gt 0) {
      Write-Host ""
      Write-Host "→ 다음 노드:"
      $upcoming | Select-Object -First 3 | ForEach-Object { Write-Host "  • $_" }
    }
    return @{ cur = $cur; json = $j }
  }
}

function Check-Foreshadowing($state) {
  Write-Host ""
  Write-Host "🎯 복선 추적"
  Write-Host "───────────"
  $j = $state.json
  $curCh = [int]$state.cur.chapter
  $fs = @($j.foreshadowing)
  $total = $fs.Count
  $active = @($fs | Where-Object { $_.status -eq 'active' }).Count
  $resolved = @($fs | Where-Object { $_.status -eq 'resolved' }).Count
  Write-Host "통계: 총 ${total}개, 활성 ${active}개, 회수됨 ${resolved}개"

  if ($active -gt 0) {
    Write-Host ""
    Write-Host "⚠️ 처리 대기 복선:"
    $fs | Where-Object { $_.status -eq 'active' } | ForEach-Object {
      $ch = $_.planted.chapter
      Write-Host "  • $($_.content) (제${ch}장에서 배치)"
    }
  }

  $overdue = @($fs | Where-Object { $_.status -eq 'active' -and $_.planted.chapter -and ($curCh - [int]$_.planted.chapter) -gt 30 }).Count
  if ($overdue -gt 0) { Write-Host ""; Write-Host "⚠️ 경고: ${overdue}개의 복선이 30챕터 이상 미처리" }
}

function Check-Conflicts($state) {
  Write-Host ""
  Write-Host "⚔️ 갈등 추적"
  Write-Host "───────────"
  $active = @($state.json.conflicts.active)
  $count = $active.Count
  if ($count -gt 0) {
    Write-Host "현재 활성 갈등: ${count}개"
    $active | ForEach-Object { Write-Host ("  • " + $_.name + " [" + $_.intensity + "]") }
  } else { Write-Host "현재 활성 갈등 없음" }
}

function Generate-Suggestions($state) {
  Write-Host ""
  Write-Host "💡 제안"
  Write-Host "───────"
  $ch = [int]$state.cur.chapter
  if ($ch -lt 10) { Write-Host "• 초반 10장은 매우 중요합니다. 독자를 끌어당길 충분한 훅이 있는지 확인하세요" }
  elseif ($ch -lt 30) { Write-Host "• 첫 번째 소규모 클라이맥스에 접근 중입니다. 갈등이 충분히 격렬한지 확인하세요" }
  elseif (($ch % 60) -gt 50) { Write-Host "• 권말에 접근 중입니다. 클라이맥스와 서스펜스 설정을 준비하세요" }

  $activeFo = @($state.json.foreshadowing | Where-Object { $_.status -eq 'active' }).Count
  if ($activeFo -gt 5) { Write-Host "• 활성 복선이 많습니다. 다음 몇 장에서 일부를 회수하는 것을 고려하세요" }
  $activeConf = @($state.json.conflicts.active).Count
  if ($activeConf -eq 0 -and $ch -gt 5) { Write-Host "• 현재 활성 갈등이 없습니다. 새로운 갈등 포인트 도입을 고려하세요" }
}

Write-Host "🔍 줄거리 일관성 검사 시작..."
Write-Host ""
Ensure-PlotTracker
$st = Analyze-PlotAlignment
Check-Foreshadowing $st
Check-Conflicts $st
Generate-Suggestions $st

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━"
Write-Host "✅ 검사 완료"

# 타임스탬프 업데이트
if (Test-Path $plotPath) {
  $json = Get-Content -LiteralPath $plotPath -Raw -Encoding UTF8 | ConvertFrom-Json
  $json.lastUpdated = (Get-Date).ToString('yyyy-MM-ddTHH:mm:ss')
  $json | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath $plotPath -Encoding UTF8
}
