param(
    [switch]$Json,
    [switch]$PathsOnly
)

# 스토리 개요 명확화 지원 스크립트
# /clarify 명령어용, 현재 스토리 경로 스캔 및 반환

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Get script directory
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Source common functions
. "$ScriptDir\common.ps1"

# Get project root
$ProjectRoot = Get-ProjectRoot
Set-Location $ProjectRoot

# Find the current story directory
$StoriesDir = "stories"
if (-not (Test-Path $StoriesDir -PathType Container)) {
    if ($Json) {
        Write-Output '{"error": "No stories directory found"}'
    } else {
        Write-Error "오류: stories 디렉토리를 찾을 수 없습니다. 먼저 /story 를 실행하여 스토리 개요를 작성하세요"
    }
    exit 1
}

# Get the latest story
$StoryDirs = Get-ChildItem -Path $StoriesDir -Directory | Sort-Object Name -Descending
if ($StoryDirs.Count -eq 0) {
    if ($Json) {
        Write-Output '{"error": "No story found"}'
    } else {
        Write-Error "오류: 스토리를 찾을 수 없습니다. 먼저 /story 를 실행하여 스토리 개요를 작성하세요"
    }
    exit 1
}

$StoryDir = $StoryDirs[0]
$StoryName = $StoryDir.Name

# Find story file (새 형식 specification.md)
$StoryFile = Join-Path $StoryDir.FullName "specification.md"

if (-not (Test-Path $StoryFile -PathType Leaf)) {
    if ($Json) {
        Write-Output '{"error": "Story file not found (specification.md required)"}'
    } else {
        Write-Error "오류: 스토리 파일 specification.md 를 찾을 수 없습니다"
    }
    exit 1
}

# Check if clarification already exists
$ClarificationExists = $false
$StoryContent = Get-Content $StoryFile -Raw
if ($StoryContent -match "## 명확화 기록") {
    $ClarificationExists = $true
}

# Count existing clarification sessions
$ClarificationCount = 0
if ($ClarificationExists) {
    $matches = [regex]::Matches($StoryContent, "### 명확화 세션")
    $ClarificationCount = $matches.Count
}

# Convert paths to forward slashes for JSON
$StoryFilePath = $StoryFile.Replace('\', '/')
$StoryDirPath = $StoryDir.FullName.Replace('\', '/')
$ProjectRootPath = $ProjectRoot.Replace('\', '/')

# Output in JSON format if requested
if ($Json) {
    if ($PathsOnly) {
        # Minimal output for command template
        $output = @{
            STORY_PATH = $StoryFilePath
            STORY_NAME = $StoryName
            STORY_DIR = $StoryDirPath
        }
    } else {
        # Full output for analysis
        $output = @{
            STORY_PATH = $StoryFilePath
            STORY_NAME = $StoryName
            STORY_DIR = $StoryDirPath
            CLARIFICATION_EXISTS = $ClarificationExists
            CLARIFICATION_COUNT = $ClarificationCount
            PROJECT_ROOT = $ProjectRootPath
        }
    }
    Write-Output (ConvertTo-Json $output -Compress)
} else {
    Write-Output "스토리 발견: $StoryName"
    Write-Output "파일 경로: $StoryFile"
    if ($ClarificationExists) {
        Write-Output "기존 명확화 세션: $ClarificationCount 회"
    } else {
        Write-Output "아직 명확화가 진행되지 않았습니다"
    }
}
