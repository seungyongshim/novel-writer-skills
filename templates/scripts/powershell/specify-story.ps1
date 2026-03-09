# 스토리 사양 정의 스크립트
# /specify 명령어용

param(
    [switch]$Json,
    [string]$StoryName
)

# 공통 함수 가져오기
. "$PSScriptRoot\common.ps1"

# 프로젝트 루트 디렉토리 가져오기
$ProjectRoot = Get-ProjectRoot
Set-Location $ProjectRoot

# 스토리 이름과 경로 결정
if ([string]::IsNullOrEmpty($StoryName)) {
    # 최신 스토리 찾기
    $StoriesDir = "stories"
    if (Test-Path $StoriesDir) {
        $latestStory = Get-ChildItem $StoriesDir -Directory |
            Sort-Object LastWriteTime -Descending |
            Select-Object -First 1

        if ($latestStory) {
            $StoryName = $latestStory.Name
        }
    }

    # 여전히 없으면 기본 이름 생성
    if ([string]::IsNullOrEmpty($StoryName)) {
        $StoryName = "story-$(Get-Date -Format 'yyyyMMdd')"
    }
}

# 경로 설정
$StoryDir = "stories\$StoryName"
$SpecFile = "$StoryDir\specification.md"

# 디렉토리 생성
if (-not (Test-Path $StoryDir)) {
    New-Item -ItemType Directory -Path $StoryDir -Force | Out-Null
}

# 파일 상태 확인
$SpecExists = $false
$Status = "new"

if (Test-Path $SpecFile) {
    $SpecExists = $true
    $Status = "exists"
}

# JSON 형식 출력
if ($Json) {
    @{
        STORY_NAME = $StoryName
        STORY_DIR = $StoryDir
        SPEC_PATH = $SpecFile
        STATUS = $Status
        PROJECT_ROOT = $ProjectRoot
    } | ConvertTo-Json
}
else {
    Write-Host "스토리 사양 초기화"
    Write-Host "================"
    Write-Host "스토리 이름: $StoryName"
    Write-Host "사양 경로: $SpecFile"

    if ($SpecExists) {
        Write-Host "상태: 사양 파일이 이미 존재합니다. 업데이트 준비 완료"
    }
    else {
        Write-Host "상태: 새 사양 생성 준비 완료"
    }

    # 헌법 확인
    if (Test-Path ".specify\memory\constitution.md") {
        Write-Host ""
        Write-Host "✅ 창작 헌법이 감지되었습니다. 사양은 헌법 원칙을 따릅니다" -ForegroundColor Green
    }
}
