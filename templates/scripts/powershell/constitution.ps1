# 소설 창작 헌법 관리 스크립트
# /constitution 명령어용

param(
    [string]$Command = "check"
)

# 공통 함수 가져오기
. "$PSScriptRoot\common.ps1"

# 프로젝트 루트 디렉토리 가져오기
$ProjectRoot = Get-ProjectRoot
Set-Location $ProjectRoot

# 파일 경로 정의
$ConstitutionFile = ".specify\memory\constitution.md"

switch ($Command) {
    "check" {
        # 헌법 파일 존재 여부 확인
        if (Test-Path $ConstitutionFile) {
            Write-Host "✅ 헌법 파일이 존재합니다: $ConstitutionFile" -ForegroundColor Green

            # 버전 정보 추출
            $content = Get-Content $ConstitutionFile -Raw
            if ($content -match "- 버전：(.+)") {
                $version = $matches[1].Trim()
            } else {
                $version = "알 수 없음"
            }

            if ($content -match "- 최종 수정：(.+)") {
                $updated = $matches[1].Trim()
            } else {
                $updated = "알 수 없음"
            }

            Write-Host "  버전: $version"
            Write-Host "  최종 수정: $updated"
            exit 0
        }
        else {
            Write-Host "❌ 헌법 파일이 아직 생성되지 않았습니다" -ForegroundColor Red
            Write-Host "  제안: /constitution 을 실행하여 창작 헌법을 작성하세요"
            exit 1
        }
    }

    "init" {
        # 헌법 파일 초기화
        $dir = Split-Path $ConstitutionFile -Parent
        if (-not (Test-Path $dir)) {
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
        }

        if (Test-Path $ConstitutionFile) {
            Write-Host "헌법 파일이 이미 존재합니다. 업데이트 준비 완료"
        }
        else {
            Write-Host "새 헌법 파일 생성 준비 완료"
        }
    }

    "validate" {
        # 헌법 파일 형식 검증
        if (-not (Test-Path $ConstitutionFile)) {
            Write-Host "오류: 헌법 파일이 존재하지 않습니다" -ForegroundColor Red
            exit 1
        }

        Write-Host "헌법 파일 검증 중..."

        # 필수 섹션 확인
        $requiredSections = @("핵심 가치관", "품질 기준", "창작 스타일", "콘텐츠 규범", "독자 계약")
        $content = Get-Content $ConstitutionFile -Raw
        $missingSections = @()

        foreach ($section in $requiredSections) {
            if ($content -notmatch "## .* $section") {
                $missingSections += $section
            }
        }

        if ($missingSections.Count -gt 0) {
            Write-Host "⚠️ 다음 섹션이 누락되었습니다:" -ForegroundColor Yellow
            foreach ($section in $missingSections) {
                Write-Host "  - $section"
            }
        }
        else {
            Write-Host "✅ 모든 필수 섹션이 존재합니다" -ForegroundColor Green
        }

        # 버전 정보 확인
        if ($content -match "^- 버전：") {
            Write-Host "✅ 버전 정보 완비" -ForegroundColor Green
        }
        else {
            Write-Host "⚠️ 버전 정보가 누락되었습니다" -ForegroundColor Yellow
        }
    }

    "export" {
        # 헌법 요약 내보내기
        if (-not (Test-Path $ConstitutionFile)) {
            Write-Host "오류: 헌법 파일이 존재하지 않습니다" -ForegroundColor Red
            exit 1
        }

        Write-Host "# 창작 헌법 요약"
        Write-Host ""

        $content = Get-Content $ConstitutionFile -Raw

        # 핵심 원칙 추출
        Write-Host "## 핵심 원칙"
        if ($content -match "### 원칙[\s\S]*?\*\*선언\*\*：(.+)") {
            Write-Host $matches[1]
        }
        else {
            Write-Host "(원칙 선언을 찾을 수 없습니다)"
        }

        Write-Host ""
        Write-Host "## 품질 기준선"
        if ($content -match "### 기준[\s\S]*?\*\*요구\*\*：(.+)") {
            Write-Host $matches[1]
        }
        else {
            Write-Host "(품질 기준을 찾을 수 없습니다)"
        }

        Write-Host ""
        Write-Host "상세 내용은 다음 파일을 확인하세요: $ConstitutionFile"
    }

    default {
        Write-Host "알 수 없는 명령어: $Command" -ForegroundColor Red
        Write-Host "지원되는 명령어: check, init, validate, export"
        exit 1
    }
}
