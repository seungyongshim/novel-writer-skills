#!/usr/bin/env pwsh
# 캐릭터 관계 관리 (PowerShell)

param(
  [ValidateSet('show','update','history','check')]
  [string]$Command = 'show',
  [string]$A,
  [ValidateSet('allies','enemies','romantic','neutral','family','mentors')]
  [string]$Relation,
  [string]$B,
  [int]$Chapter,
  [string]$Note
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. "$PSScriptRoot/common.ps1"

$root = Get-ProjectRoot
$storyDir = Get-CurrentStoryDir
$relPath = $null
if ($storyDir -and (Test-Path (Join-Path $storyDir 'spec/tracking/relationships.json'))) {
  $relPath = Join-Path $storyDir 'spec/tracking/relationships.json'
} elseif (Test-Path (Join-Path $root 'spec/tracking/relationships.json')) {
  $relPath = Join-Path $root 'spec/tracking/relationships.json'
} else {
  $tpl1 = Join-Path $root '.specify/templates/tracking/relationships.json'
  $tpl2 = Join-Path $root 'templates/tracking/relationships.json'
  $dest = Join-Path $root 'spec/tracking/relationships.json'
  New-Item -ItemType Directory -Path (Split-Path $dest -Parent) -Force | Out-Null
  if (Test-Path $tpl1) { Copy-Item $tpl1 $dest -Force; $relPath = $dest }
  elseif (Test-Path $tpl2) { Copy-Item $tpl2 $dest -Force; $relPath = $dest }
  else { throw 'relationships.json 을 찾을 수 없으며 템플릿으로부터 생성할 수도 없습니다' }
}

function Show-Header { Write-Host "👥 캐릭터 관계 관리"; Write-Host "━━━━━━━━━━━━━━━━━━━━" }

function Show-Relations {
  Show-Header
  try { $j = Get-Content -LiteralPath $relPath -Raw -Encoding UTF8 | ConvertFrom-Json } catch { throw 'relationships.json 형식이 유효하지 않습니다' }
  Write-Host "파일: $relPath"; Write-Host ''
  $main = $j.characters.PSObject.Properties.Name | Select-Object -First 1
  if (-not $main) { Write-Host '캐릭터 기록 없음'; return }
  Write-Host "주인공: $main"
  $c = $j.characters.$main
  $r = if ($c.relationships) { $c.relationships } else { $c }
  $map = @{
    romantic = '💕 연애'; allies='🤝 동맹'; mentors='📚 스승'; enemies='⚔️ 적대'; family='👪 가족'; neutral='・ 관계'
  }
  foreach ($k in 'romantic','allies','mentors','enemies','family','neutral') {
    $lst = @($r.$k)
    if ($lst.Count -gt 0) { Write-Host ("├─ {0}: {1}" -f $map[$k], ($lst -join ', ')) }
  }
  Write-Host ''
  if ($j.history) {
    Write-Host '최근 변화:'
    $last = $j.history[-1]
    if ($last) { $last.changes | ForEach-Object { Write-Host ("- " + ($_.characters -join '↔') + ": " + ($_.relation ?? $_.type)) } }
  } elseif ($j.relationshipChanges) {
    Write-Host '최근 변화:'
    $j.relationshipChanges | Select-Object -Last 5 | ForEach-Object { Write-Host ("- " + ($_.type ?? '변화') + ": " + ($_.characters -join '↔')) }
  }
}

function Ensure-Character($json, [string]$name) {
  if (-not $json.characters.$name) {
    $json.characters | Add-Member -NotePropertyName $name -NotePropertyValue (@{ name=$name; relationships=@{ allies=@(); enemies=@(); romantic=@(); family=@(); mentors=@(); neutral=@() } })
  }
}

function Update-Relation([string]$a, [string]$rel, [string]$b) {
  if (-not $a -or -not $rel -or -not $b) { throw '사용법: manage-relations.ps1 update -A 인물A -Relation allies|enemies|romantic|neutral|family|mentors -B 인물B [-Chapter N] [-Note 설명]' }
  $j = Get-Content -LiteralPath $relPath -Raw -Encoding UTF8 | ConvertFrom-Json
  Ensure-Character $j $a
  Ensure-Character $j $b
  $lst = @($j.characters.$a.relationships.$rel)
  if ($lst -notcontains $b) { $lst += $b }
  $j.characters.$a.relationships.$rel = $lst
  $j.lastUpdated = (Get-Date).ToString('yyyy-MM-ddTHH:mm:ss')
  if ($j.history) {
    $chg = [pscustomobject]@{ type='update'; characters=@($a,$b); relation=$rel; note=($Note ?? '') }
    $rec = [pscustomobject]@{ chapter=($Chapter ? $Chapter : $null); date=(Get-Date).ToString('s'); changes=@($chg) }
    $j.history += $rec
  } elseif ($j.relationshipChanges) {
    $j.relationshipChanges += [pscustomobject]@{ type='update'; characters=@($a,$b); relation=$rel }
  } else {
    $j | Add-Member -NotePropertyName history -NotePropertyValue @()
  }
  $j | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath $relPath -Encoding UTF8
  Write-Host "✅ 관계 업데이트 완료: $a [$rel] $b"
}

function Show-History {
  Show-Header
  $j = Get-Content -LiteralPath $relPath -Raw -Encoding UTF8 | ConvertFrom-Json
  if ($j.history) {
    foreach ($h in $j.history) {
      $chap = if ($h.chapter) { $h.chapter } else { 0 }
      $desc = ($h.changes | ForEach-Object { ($_.characters -join '↔') + '→' + ($_.relation ?? $_.type) }) -join '; '
      Write-Host ("제{0}장: {1}" -f $chap, $desc)
    }
  } elseif ($j.relationshipChanges) {
    foreach ($h in $j.relationshipChanges) { Write-Host ((($h.date ?? '') + ' ' + ($h.type ?? '') + ': ' + ($h.characters -join '↔') + '→' + ($h.relation ?? ''))) }
  } else { Write-Host '아직 기록이 없습니다' }
}

function Check-Relations {
  Show-Header
  $j = Get-Content -LiteralPath $relPath -Raw -Encoding UTF8 | ConvertFrom-Json
  $names = @($j.characters.PSObject.Properties.Name)
  $refs = @()
  foreach ($name in $names) {
    $rel = $j.characters.$name.relationships
    if (-not $rel) { continue }
    foreach ($k in 'allies','enemies','romantic','family','mentors','neutral') {
      $refs += @($rel.$k)
    }
  }
  $refs = $refs | Where-Object { $_ } | Select-Object -Unique
  $missing = @($refs | Where-Object { $names -notcontains $_ })
  if ($missing.Count -gt 0) {
    Write-Host "⚠ 미등록 캐릭터 참조가 발견되었습니다. 보충을 권장합니다:"
    $missing | ForEach-Object { Write-Host "  - $_" }
  } else { Write-Host "✅ 관계 데이터 검사 통과" }
}

switch ($Command) {
  'show'   { Show-Relations }
  'update' { Update-Relation -a $A -rel $Relation -b $B }
  'history'{ Show-History }
  'check'  { Check-Relations }
}
