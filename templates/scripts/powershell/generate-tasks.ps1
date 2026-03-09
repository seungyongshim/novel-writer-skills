#!/usr/bin/env pwsh
# 집필 작업 생성

$STORIES_DIR = "stories"

# 최신 스토리 디렉토리 찾기
function Get-LatestStory {
    $latest = Get-ChildItem -Path $STORIES_DIR -Directory |
              Sort-Object Name -Descending |
              Select-Object -First 1

    if ($latest) {
        return $latest.FullName
    }
    return $null
}

$storyDir = Get-LatestStory

if (!$storyDir) {
    Write-Host "오류: 스토리 프로젝트를 찾을 수 없습니다"
    Write-Host "먼저 /story 명령어를 사용하여 스토리를 생성하세요"
    exit 1
}

$outlineFile = "$storyDir/outline.md"
$tasksFile = "$storyDir/tasks.md"
$progressFile = "$storyDir/progress.json"

if (!(Test-Path $outlineFile)) {
    Write-Host "오류: 챕터 기획을 찾을 수 없습니다"
    Write-Host "먼저 /outline 명령어를 사용하여 챕터 기획을 작성하세요"
    exit 1
}

# 현재 날짜 가져오기
$currentDate = Get-Date -Format "yyyy-MM-dd"
$currentDateTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

# 작업 파일 생성, 기본 정보 미리 채우기
$tasksContent = @"
# 집필 작업 목록

## 작업 개요
- **생성일**: $currentDate
- **최종 업데이트**: $currentDate
- **작업 상태**: 생성 대기 중

---
"@
$tasksContent | Out-File -FilePath $tasksFile -Encoding UTF8

# 진행도 파일 생성 또는 업데이트
if (!(Test-Path $progressFile)) {
    $progressContent = @{
        created_at = $currentDateTime
        updated_at = $currentDateTime
        total_chapters = 0
        completed = 0
        in_progress = 0
        word_count = 0
    } | ConvertTo-Json
    $progressContent | Out-File -FilePath $progressFile -Encoding UTF8
}

Write-Host "스토리 디렉토리: $storyDir"
Write-Host "기획 파일: $outlineFile"
Write-Host "작업 파일: $tasksFile"
Write-Host "현재 날짜: $currentDate"
Write-Host ""
Write-Host "챕터 기획 기반 작업 생성:"
Write-Host "- 챕터 집필 작업"
Write-Host "- 캐릭터 보완 작업"
Write-Host "- 세계관 보충"
Write-Host "- 수정 작업"
