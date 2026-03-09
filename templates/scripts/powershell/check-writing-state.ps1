# 집필 상태 확인 스크립트
# /write 명령어용

# 공통 함수 가져오기
. "$PSScriptRoot\common.ps1"

# 프로젝트 루트 디렉토리 가져오기
$ProjectRoot = Get-ProjectRoot
Set-Location $ProjectRoot

# 현재 스토리 가져오기
$StoryName = Get-ActiveStory
$StoryDir = "stories\$StoryName"

Write-Host "집필 상태 확인"
Write-Host "============"
Write-Host "현재 스토리: $StoryName"
Write-Host ""

# 방법론 문서 확인
function Test-MethodologyDocs {
    $missing = @()

    if (-not (Test-Path ".specify\memory\constitution.md")) {
        $missing += "헌법"
    }
    if (-not (Test-Path "$StoryDir\specification.md")) {
        $missing += "사양"
    }
    if (-not (Test-Path "$StoryDir\creative-plan.md")) {
        $missing += "계획"
    }
    if (-not (Test-Path "$StoryDir\tasks.md")) {
        $missing += "작업"
    }

    if ($missing.Count -gt 0) {
        Write-Host "⚠️ 다음 기준 문서가 누락되었습니다:" -ForegroundColor Yellow
        foreach ($doc in $missing) {
            Write-Host "  - $doc"
        }
        Write-Host ""
        Write-Host "7단계 방법론에 따라 선행 단계를 완료하세요:"
        Write-Host "1. /constitution - 창작 헌법 작성"
        Write-Host "2. /specify - 스토리 사양 정의"
        Write-Host "3. /clarify - 핵심 결정 명확화"
        Write-Host "4. /plan - 창작 계획 수립"
        Write-Host "5. /tasks - 작업 목록 생성"
        return $false
    }

    Write-Host "✅ 방법론 문서 완비" -ForegroundColor Green
    return $true
}

# 대기 중인 집필 작업 확인
function Test-PendingTasks {
    $tasksFile = "$StoryDir\tasks.md"

    if (-not (Test-Path $tasksFile)) {
        Write-Host "❌ 작업 파일이 존재하지 않습니다" -ForegroundColor Red
        return $false
    }

    # 작업 상태 집계
    $content = Get-Content $tasksFile -Raw
    $pending = ([regex]::Matches($content, '^- \[ \]', [System.Text.RegularExpressions.RegexOptions]::Multiline)).Count
    $inProgress = ([regex]::Matches($content, '^- \[~\]', [System.Text.RegularExpressions.RegexOptions]::Multiline)).Count
    $completed = ([regex]::Matches($content, '^- \[x\]', [System.Text.RegularExpressions.RegexOptions]::Multiline)).Count

    Write-Host ""
    Write-Host "작업 상태:"
    Write-Host "  대기 중: $pending"
    Write-Host "  진행 중: $inProgress"
    Write-Host "  완료됨: $completed"

    if ($pending -eq 0 -and $inProgress -eq 0) {
        Write-Host ""
        Write-Host "🎉 모든 작업이 완료되었습니다!" -ForegroundColor Green
        Write-Host "/analyze 를 실행하여 종합 검증을 권장합니다"
        return $true
    }

    # 다음 집필 작업 표시
    Write-Host ""
    Write-Host "다음 집필 작업:"
    $lines = $content -split "`n"
    foreach ($line in $lines) {
        if ($line -match '^- \[ \]') {
            Write-Host $line
            break
        }
    }

    return $true
}

# 완료된 콘텐츠 확인
function Test-CompletedContent {
    $contentDir = "$StoryDir\content"

    if (Test-Path $contentDir) {
        $mdFiles = Get-ChildItem "$contentDir\*.md" -ErrorAction SilentlyContinue
        $chapterCount = $mdFiles.Count

        if ($chapterCount -gt 0) {
            Write-Host ""
            Write-Host "완료된 챕터: $chapterCount"
            Write-Host "최근 집필:"

            $recentFiles = $mdFiles |
                Sort-Object LastWriteTime -Descending |
                Select-Object -First 3

            foreach ($file in $recentFiles) {
                Write-Host "  - $($file.Name)"
            }
        }
    }
    else {
        Write-Host ""
        Write-Host "아직 집필을 시작하지 않았습니다"
    }
}

# 메인 흐름
if (-not (Test-MethodologyDocs)) {
    exit 1
}

Test-PendingTasks | Out-Null
Test-CompletedContent

Write-Host ""
Write-Host "준비 완료, 집필을 시작할 수 있습니다"
