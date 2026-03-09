#!/usr/bin/env pwsh
# 추적 시스템 초기화 (PowerShell)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. "$PSScriptRoot/common.ps1"

Write-Host "🚀 추적 시스템 초기화 중..."

$root = Get-ProjectRoot
$storyDir = Get-CurrentStoryDir
if (-not $storyDir) { throw "먼저 /story 와 /outline 을 완료하세요. stories/*/ 디렉토리를 찾을 수 없습니다" }

$storyName = Split-Path $storyDir -Leaf
$specTrack = Join-Path $root "spec/tracking"
New-Item -ItemType Directory -Path $specTrack -Force | Out-Null

Write-Host "📖 《$storyName》 추적 시스템 초기화 중..."

$utc = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")

# plot-tracker.json
$plotPath = Join-Path $specTrack "plot-tracker.json"
if (-not (Test-Path $plotPath)) {
  Write-Host "📝 plot-tracker.json 생성 중..."
  $plot = @{
    novel = $storyName
    lastUpdated = $utc
    currentState = @{ chapter = 0; volume = 1; mainPlotStage = '준비 단계'; location = '미정'; timepoint = '이야기 시작 전' }
    plotlines = @{ main = @{ name='메인 스토리'; description='개요에서 추출 예정'; status='시작 전'; currentNode='기점'; completedNodes=@(); upcomingNodes=@(); plannedClimax=@{ chapter=$null; description='기획 예정' } }; subplots=@() }
    foreshadowing = @()
    conflicts = @{ active=@(); resolved=@(); upcoming=@() }
    checkpoints = @{ volumeEnd=@(); majorEvents=@() }
    notes = @{ plotHoles=@(); inconsistencies=@(); reminders=@('실제 스토리 내용에 맞게 추적 데이터를 업데이트하세요') }
  } | ConvertTo-Json -Depth 12
  Set-Content -LiteralPath $plotPath -Value $plot -Encoding UTF8
}

# timeline.json
$timelinePath = Join-Path $specTrack "timeline.json"
if (-not (Test-Path $timelinePath)) {
  Write-Host "⏰ timeline.json 생성 중..."
  $timeline = @{
    novel = $storyName
    lastUpdated = $utc
    storyTimeUnit = '일'
    realWorldReference = $null
    timeline = @(@{ chapter=0; storyTime='0일째'; description='이야기 시작 전'; events=@('추가 예정'); location='미정' })
    parallelEvents = @()
    timeSpan = @{ start='0일째'; current='0일째'; elapsed='0일' }
  } | ConvertTo-Json -Depth 12
  Set-Content -LiteralPath $timelinePath -Value $timeline -Encoding UTF8
}

# relationships.json
$relationsPath = Join-Path $specTrack "relationships.json"
if (-not (Test-Path $relationsPath)) {
  Write-Host "👥 relationships.json 생성 중..."
  $relations = @{
    novel = $storyName
    lastUpdated = $utc
    characters = @{ '주인공' = @{ name='설정 예정'; relationships=@{ allies=@(); enemies=@(); romantic=@(); neutral=@() } } }
    factions = @{}
    relationshipChanges = @()
    currentTensions = @()
  } | ConvertTo-Json -Depth 12
  Set-Content -LiteralPath $relationsPath -Value $relations -Encoding UTF8
}

# character-state.json
$charStatePath = Join-Path $specTrack "character-state.json"
if (-not (Test-Path $charStatePath)) {
  Write-Host "📍 character-state.json 생성 중..."
  $cs = @{
    novel = $storyName
    lastUpdated = $utc
    characters = @{ '주인공' = @{ name='설정 예정'; status='건강'; location='미정'; possessions=@(); skills=@(); lastSeen=@{ chapter=0; description='아직 등장 전' }; development=@{ physical=0; mental=0; emotional=0; power=0 } } }
    groupPositions = @{}
    importantItems = @{}
  } | ConvertTo-Json -Depth 12
  Set-Content -LiteralPath $charStatePath -Value $cs -Encoding UTF8
}

Write-Host ""
Write-Host "✅ 추적 시스템 초기화 완료!"
Write-Host ""
Write-Host "📊 다음 추적 파일이 생성되었습니다:"
Write-Host "   • spec/tracking/plot-tracker.json - 줄거리 추적"
Write-Host "   • spec/tracking/timeline.json - 타임라인 관리"
Write-Host "   • spec/tracking/relationships.json - 관계 네트워크"
Write-Host "   • spec/tracking/character-state.json - 캐릭터 상태"
Write-Host ""
Write-Host "💡 다음 단계:"
Write-Host "   1. /write 를 사용하여 창작 시작 (추적 데이터 자동 업데이트)"
Write-Host "   2. 정기적으로 /track 으로 종합 보고서 확인"
Write-Host "   3. /plot-check 등 명령어로 일관성 검사"
