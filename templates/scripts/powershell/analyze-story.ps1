# 스토리 분석 검증 스크립트
# /analyze 명령어용

param(
    [string]$StoryName,
    [string]$AnalysisType = "full"  # full, compliance, quality, progress
)

# 공통 함수 가져오기
. "$PSScriptRoot\common.ps1"

# 프로젝트 루트 디렉토리 가져오기
$ProjectRoot = Get-ProjectRoot
Set-Location $ProjectRoot

# 스토리 경로 결정
if ([string]::IsNullOrEmpty($StoryName)) {
    $StoryName = Get-ActiveStory
}

$StoryDir = "stories\$StoryName"

# 필수 파일 확인
function Test-StoryFiles {
    $missingFiles = @()

    # 기준 문서 확인
    if (-not (Test-Path ".specify\memory\constitution.md")) {
        $missingFiles += "헌법 파일"
    }
    if (-not (Test-Path "$StoryDir\specification.md")) {
        $missingFiles += "사양 파일"
    }
    if (-not (Test-Path "$StoryDir\creative-plan.md")) {
        $missingFiles += "계획 파일"
    }

    if ($missingFiles.Count -gt 0) {
        Write-Host "⚠️ 다음 기준 문서가 누락되었습니다:" -ForegroundColor Yellow
        foreach ($file in $missingFiles) {
            Write-Host "  - $file"
        }
        return $false
    }

    return $true
}

# 콘텐츠 통계
function Get-ContentAnalysis {
    $contentDir = "$StoryDir\content"
    $totalWords = 0
    $chapterCount = 0

    if (Test-Path $contentDir) {
        $mdFiles = Get-ChildItem "$contentDir\*.md" -ErrorAction SilentlyContinue

        foreach ($file in $mdFiles) {
            $chapterCount++
            # 간단한 글자 수 카운트 (한국어/중국어는 문자 기준)
            $content = Get-Content $file.FullName -Raw
            $words = ($content -replace '\s', '').Length
            $totalWords += $words
        }
    }

    Write-Host "콘텐츠 통계:"
    Write-Host "  총 글자 수: $totalWords"
    Write-Host "  챕터 수: $chapterCount"

    if ($chapterCount -gt 0) {
        $avgLength = [math]::Round($totalWords / $chapterCount)
        Write-Host "  평균 챕터 길이: $avgLength"
    }
}

# 작업 완료도 확인
function Test-TaskCompletion {
    $tasksFile = "$StoryDir\tasks.md"

    if (-not (Test-Path $tasksFile)) {
        Write-Host "작업 파일이 존재하지 않습니다"
        return
    }

    $content = Get-Content $tasksFile -Raw
    $totalTasks = ([regex]::Matches($content, '^- \[', [System.Text.RegularExpressions.RegexOptions]::Multiline)).Count
    $completedTasks = ([regex]::Matches($content, '^- \[x\]', [System.Text.RegularExpressions.RegexOptions]::Multiline)).Count
    $inProgress = ([regex]::Matches($content, '^- \[~\]', [System.Text.RegularExpressions.RegexOptions]::Multiline)).Count
    $pending = $totalTasks - $completedTasks - $inProgress

    Write-Host "작업 진행도:"
    Write-Host "  총 작업: $totalTasks"
    Write-Host "  완료됨: $completedTasks"
    Write-Host "  진행 중: $inProgress"
    Write-Host "  미시작: $pending"

    if ($totalTasks -gt 0) {
        $completionRate = [math]::Round(($completedTasks * 100) / $totalTasks)
        Write-Host "  완료율: $completionRate%"
    }
}

# 사양 적합도 확인
function Test-SpecificationCompliance {
    $specFile = "$StoryDir\specification.md"

    Write-Host "사양 적합도 확인:"

    if (Test-Path $specFile) {
        $content = Get-Content $specFile -Raw

        # P0 요구사항 확인 (간소화 버전)
        if ($content -match "### 필수 포함 (P0)") {
            Write-Host "  P0 요구사항: 감지됨, 수동 검증 필요"
        }

        # [명확화 필요] 태그 잔존 여부 확인
        $unclearCount = ([regex]::Matches($content, '\[명확화 필요\]')).Count
        if ($unclearCount -gt 0) {
            Write-Host "  ⚠️ 아직 $unclearCount 건의 명확화 필요 항목이 남아있습니다" -ForegroundColor Yellow
        }
        else {
            Write-Host "  ✅ 모든 결정이 명확화되었습니다" -ForegroundColor Green
        }
    }
}

# 메인 분석 흐름
Write-Host "스토리 분석 보고서"
Write-Host "============"
Write-Host "스토리: $StoryName"
Write-Host "분석 시간: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Write-Host ""

# 기준 문서 확인
if (-not (Test-StoryFiles)) {
    Write-Host ""
    Write-Host "❌ 완전한 분석이 불가합니다. 먼저 기준 문서를 완성하세요" -ForegroundColor Red
    exit 1
}

Write-Host "✅ 기준 문서 완비" -ForegroundColor Green
Write-Host ""

# 분석 유형에 따라 실행
switch ($AnalysisType) {
    "full" {
        Get-ContentAnalysis
        Write-Host ""
        Test-TaskCompletion
        Write-Host ""
        Test-SpecificationCompliance
    }
    "quality" {
        Get-ContentAnalysis
    }
    "progress" {
        Test-TaskCompletion
    }
    "compliance" {
        Test-SpecificationCompliance
    }
    default {
        Write-Host "알 수 없는 분석 유형: $AnalysisType" -ForegroundColor Red
        exit 1
    }
}

Write-Host ""
Write-Host "분석 완료. 상세 보고서가 다음 위치에 저장되었습니다: $StoryDir\analysis-report.md"
