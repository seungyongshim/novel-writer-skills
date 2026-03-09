#!/usr/bin/env pwsh
# 공용 함수 (PowerShell)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-ProjectRoot {
  $current = (Get-Location).Path
  while ($true) {
    $cfg = Join-Path $current ".specify/config.json"
    if (Test-Path $cfg) { return $current }
    $parent = Split-Path $current -Parent
    if (-not $parent -or $parent -eq $current) { break }
    $current = $parent
  }
  throw "프로젝트 루트 디렉토리를 찾을 수 없음 (.specify/config.json 누락)"
}

function Get-CurrentStoryDir {
  $root = Get-ProjectRoot
  $stories = Join-Path $root "stories"
  if (-not (Test-Path $stories)) { return $null }
  $dirs = Get-ChildItem -Path $stories -Directory | Sort-Object LastWriteTime -Descending
  if ($dirs.Count -gt 0) { return $dirs[0].FullName }
  return $null
}

function Get-ActiveStory {
  $storyDir = Get-CurrentStoryDir
  if ($storyDir) {
    return Split-Path $storyDir -Leaf
  }
  # 스토리가 없으면 기본 이름 반환
  return "story-$(Get-Date -Format 'yyyyMMdd')"
}
