#!/usr/bin/env pwsh
# 타임라인 관리 및 검사 (PowerShell)

param(
  [ValidateSet('show','add','check','sync')]
  [string]$Command = 'show',
  [string]$Param1,
  [string]$Param2
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. "$PSScriptRoot/common.ps1"

$root = Get-ProjectRoot
$storyDir = Get-CurrentStoryDir
if (-not $storyDir) { throw "스토리 프로젝트를 찾을 수 없습니다 (stories/*)" }

$timelinePath = Join-Path $storyDir "spec/tracking/timeline.json"
if (-not (Test-Path $timelinePath)) { $timelinePath = Join-Path $root "spec/tracking/timeline.json" }

function Init-Timeline {
  if (-not (Test-Path $timelinePath)) {
    Write-Host "⚠️  타임라인 파일을 찾을 수 없어 생성 중..."
    $tpl = Join-Path $root "templates/tracking/timeline.json"
    if (-not (Test-Path $tpl)) { throw "템플릿 파일을 찾을 수 없습니다" }
    New-Item -ItemType Directory -Path (Split-Path $timelinePath -Parent) -Force | Out-Null
    Copy-Item $tpl $timelinePath -Force
    Write-Host "✅ 타임라인 파일이 생성되었습니다"
  }
}

function Show-Timeline {
  Write-Host "📅 스토리 타임라인"
  Write-Host "━━━━━━━━━━━━━━━━━━━━"
  if (-not (Test-Path $timelinePath)) { Write-Host "타임라인 파일을 찾을 수 없습니다"; return }
  $j = Get-Content -LiteralPath $timelinePath -Raw -Encoding UTF8 | ConvertFrom-Json
  $cur = $j.storyTime.current
  if (-not $cur) { $cur = '미설정' }
  Write-Host "⏰ 현재 시간: $cur"
  Write-Host ""
  $events = @($j.events)
  if ($events.Count -gt 0) {
    Write-Host "📖 주요 이벤트:"
    Write-Host "───────────────"
    $events | Sort-Object chapter -Descending | Select-Object -First 5 | ForEach-Object {
      Write-Host ("제{0}장 | {1} | {2}" -f $_.chapter, $_.date, $_.event)
    }
  }
  $p = $j.parallelEvents.timepoints
  if ($p) {
    Write-Host ""
    Write-Host "🔄 병렬 이벤트:"
    $p.PSObject.Properties | ForEach-Object { Write-Host ("{0}: {1}" -f $_.Name, (@($_.Value) -join ', ')) }
  }
}

function Add-Event([int]$chapter, [string]$date, [string]$event) {
  if (-not $chapter -or -not $date -or -not $event) { throw "사용법: check-timeline.ps1 add <챕터번호> <시간> <이벤트설명>" }
  Init-Timeline
  $j = Get-Content -LiteralPath $timelinePath -Raw -Encoding UTF8 | ConvertFrom-Json
  if (-not $j.events) { $j | Add-Member -NotePropertyName events -NotePropertyValue @() }
  $j.events += [pscustomobject]@{ chapter=$chapter; date=$date; event=$event; duration=''; participants=@() }
  $j.events = @($j.events | Sort-Object chapter)
  $j.lastUpdated = (Get-Date).ToString('yyyy-MM-ddTHH:mm:ss')
  $j | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath $timelinePath -Encoding UTF8
  Write-Host "✅ 이벤트 추가됨: 제${chapter}장 - $date - $event"
}

function Check-Continuity {
  Write-Host "🔍 타임라인 연속성 검사"
  Write-Host "━━━━━━━━━━━━━━━━━━━━"
  if (-not (Test-Path $timelinePath)) { throw "타임라인 파일이 존재하지 않습니다" }
  $j = Get-Content -LiteralPath $timelinePath -Raw -Encoding UTF8 | ConvertFrom-Json
  $chapters = @($j.events | Sort-Object chapter | ForEach-Object { $_.chapter })
  $issues = 0
  $prev = -1
  foreach ($c in $chapters) {
    if ($prev -ge 0 -and $c -le $prev) {
      Write-Host "⚠️  챕터 순서 이상: 제${c}장이 제${prev}장 뒤에 나타남"
      $issues++
    }
    $prev = $c
  }
  if ($issues -eq 0) { Write-Host "`n✅ 타임라인 검사 통과, 논리 문제가 발견되지 않았습니다" }
  else { Write-Host "`n⚠️  ${issues}개의 잠재적 문제가 발견되었습니다. 확인하세요" }
  $j.lastChecked = (Get-Date).ToString('yyyy-MM-ddTHH:mm:ss')
  if (-not $j.anomalies) { $j | Add-Member anomalies (@{}) }
  $j.anomalies.lastCheckIssues = $issues
  $j | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath $timelinePath -Encoding UTF8
}

function Sync-Parallel([string]$timepoint, [string]$eventsCsv) {
  if (-not $timepoint -or -not $eventsCsv) { throw "사용법: check-timeline.ps1 sync <시간대> <이벤트목록,쉼표구분>" }
  Init-Timeline
  $j = Get-Content -LiteralPath $timelinePath -Raw -Encoding UTF8 | ConvertFrom-Json
  if (-not $j.parallelEvents) { $j | Add-Member -NotePropertyName parallelEvents -NotePropertyValue @{ timepoints=@{} } }
  $events = $eventsCsv.Split(',').Trim()
  $j.parallelEvents.timepoints[$timepoint] = $events
  $j.lastUpdated = (Get-Date).ToString('yyyy-MM-ddTHH:mm:ss')
  $j | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath $timelinePath -Encoding UTF8
  Write-Host "✅ 병렬 이벤트 동기화 완료: $timepoint"
}

switch ($Command) {
  'show'  { Init-Timeline; Show-Timeline }
  'add'   { Add-Event -chapter ([int]$Param1) -date $Param2 -event ($args | Select-Object -Skip 2 | Out-String).Trim() }
  'check' { Check-Continuity }
  'sync'  { Sync-Parallel -timepoint $Param1 -eventsCsv $Param2 }
}
