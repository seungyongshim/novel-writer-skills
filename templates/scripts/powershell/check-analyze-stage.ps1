#!/usr/bin/env pwsh
# analyze 명령어가 실행해야 할 단계를 감지
# JSON 형식의 단계 정보 반환

param(
    [switch]$Json
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# 공통 함수 로드
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $scriptDir "common.ps1")

# 프로젝트 루트 디렉토리와 스토리 디렉토리 가져오기
try {
    $projectRoot = Get-ProjectRoot
    $storyDir = Get-CurrentStoryDir
} catch {
    Write-Error "오류: $_"
    exit 1
}

if (-not $storyDir) {
    Write-Error "오류: 스토리 디렉토리를 찾을 수 없습니다"
    exit 1
}

# 기본 반환값
$analyzeType = "content"
$chapterCount = 0
$hasSpec = $false
$hasPlan = $false
$hasTasks = $false
$reason = ""

# 사양 파일 확인
$specPath = Join-Path $storyDir "specification.md"
if (Test-Path $specPath) {
    $hasSpec = $true
}

# 계획 파일 확인
$planPath = Join-Path $storyDir "creative-plan.md"
if (Test-Path $planPath) {
    $hasPlan = $true
}

# 작업 파일 확인
$tasksPath = Join-Path $storyDir "tasks.md"
if (Test-Path $tasksPath) {
    $hasTasks = $true
}

# 챕터 수 집계
$contentDir = Join-Path $storyDir "content"
if (-not (Test-Path $contentDir)) {
    $contentDir = Join-Path $storyDir "chapters"
}

if (Test-Path $contentDir) {
    # .md 파일 수 집계 (인덱스 파일 제외)
    $chapters = Get-ChildItem -Path $contentDir -Filter "*.md" -File |
                Where-Object { $_.Name -notin @("README.md", "index.md") }
    $chapterCount = $chapters.Count
}

# 결정 로직
if ($chapterCount -eq 0) {
    # 챕터 콘텐츠 없음 → 프레임워크 분석
    $analyzeType = "framework"
    $reason = "챕터 콘텐츠가 없습니다. 프레임워크 일관성 분석을 권장합니다"
} elseif ($chapterCount -lt 3) {
    # 챕터 수 부족 → 프레임워크 분석 (집필 계속 권장)
    $analyzeType = "framework"
    $reason = "챕터 수가 적습니다 ($chapterCount 장). 집필 계속 또는 프레임워크 검증을 권장합니다"
} else {
    # 챕터 충분 → 콘텐츠 분석
    $analyzeType = "content"
    $reason = "$chapterCount 장이 완료되었습니다. 콘텐츠 품질 분석이 가능합니다"
}

# JSON 또는 사람이 읽기 쉬운 형식으로 출력
if ($Json) {
    # JSON 형식 출력
    $output = @{
        analyze_type = $analyzeType
        chapter_count = $chapterCount
        has_spec = $hasSpec
        has_plan = $hasPlan
        has_tasks = $hasTasks
        story_dir = $storyDir
        reason = $reason
    }

    $output | ConvertTo-Json -Compress
} else {
    # 사람이 읽기 쉬운 출력
    Write-Host "분석 단계 감지 결과"
    Write-Host "=================="
    Write-Host "스토리 디렉토리: $storyDir"
    Write-Host "챕터 수: $chapterCount"
    Write-Host "사양 파일: $(if ($hasSpec) { '✅' } else { '❌' })"
    Write-Host "계획 파일: $(if ($hasPlan) { '✅' } else { '❌' })"
    Write-Host "작업 파일: $(if ($hasTasks) { '✅' } else { '❌' })"
    Write-Host ""
    Write-Host "권장 모드: $analyzeType"
    Write-Host "사유: $reason"
}
