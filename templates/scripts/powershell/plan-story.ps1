# 창작 계획 스크립트
# /plan 명령어용

param(
    [string]$StoryName
)

# 공통 함수 가져오기
. "$PSScriptRoot\common.ps1"

# 프로젝트 루트 디렉토리 가져오기
$ProjectRoot = Get-ProjectRoot
Set-Location $ProjectRoot

# 스토리 이름 결정
if ([string]::IsNullOrEmpty($StoryName)) {
    $StoryName = Get-ActiveStory
}

$StoryDir = "stories\$StoryName"
$SpecFile = "$StoryDir\specification.md"
$ClarifyFile = "$StoryDir\clarification.md"
$PlanFile = "$StoryDir\creative-plan.md"

Write-Host "창작 계획 수립"
Write-Host "============"
Write-Host "스토리: $StoryName"
Write-Host ""

# 선행 문서 확인
$missing = @()

if (-not (Test-Path ".specify\memory\constitution.md")) {
    $missing += "헌법 파일"
}

if (-not (Test-Path $SpecFile)) {
    $missing += "사양 파일"
}

if ($missing.Count -gt 0) {
    Write-Host "⚠️ 다음 선행 문서가 누락되었습니다:" -ForegroundColor Yellow
    foreach ($doc in $missing) {
        Write-Host "  - $doc"
    }
    Write-Host ""
    Write-Host "먼저 다음을 완료하세요:"
    if (-not (Test-Path ".specify\memory\constitution.md")) {
        Write-Host "  1. /constitution - 창작 헌법 작성"
    }
    if (-not (Test-Path $SpecFile)) {
        Write-Host "  2. /specify - 스토리 사양 정의"
    }
    exit 1
}

# 미명확화 항목 확인
if (Test-Path $SpecFile) {
    $content = Get-Content $SpecFile -Raw
    $unclearCount = ([regex]::Matches($content, '\[명확화 필요\]')).Count

    if ($unclearCount -gt 0) {
        Write-Host "⚠️ 사양에 $unclearCount 건의 명확화 필요 항목이 있습니다" -ForegroundColor Yellow
        Write-Host "먼저 /clarify 를 실행하여 핵심 결정을 명확화하는 것을 권장합니다"
        Write-Host ""
    }
}

# 명확화 기록 확인
if (Test-Path $ClarifyFile) {
    Write-Host "✅ 명확화가 완료되었습니다. 명확화 결정에 기반하여 계획을 수립합니다" -ForegroundColor Green
}
else {
    Write-Host "📝 명확화 기록이 없습니다. 원본 사양에 기반하여 계획을 수립합니다"
}

# 계획 파일 확인
if (Test-Path $PlanFile) {
    Write-Host ""
    Write-Host "📋 계획 파일이 이미 존재합니다. 기존 계획을 업데이트합니다"

    # 현재 버전 표시
    $planContent = Get-Content $PlanFile -Raw
    if ($planContent -match "버전：(.+)") {
        Write-Host "  현재 버전: $($matches[1])"
    }
}
else {
    Write-Host ""
    Write-Host "📝 새로운 창작 계획을 생성합니다"
}

Write-Host ""
Write-Host "계획 파일 경로: $PlanFile"
Write-Host ""
Write-Host "준비 완료, 창작 계획을 수립할 수 있습니다"
