<#
  lanpass GitHub Release 发布脚本
  前提：已安装 GitHub CLI (gh) 并登录  ->  gh auth login

  用法：
    powershell -ExecutionPolicy Bypass -File .\publish-release.ps1

  做三件事：
    1. 检查 gh 是否可用、是否已登录
    2. 运行 build-release.ps1 打包
    3. 创建 Release 并上传附件
#>

param(
  [string]$Version = "1.0.0",
  [string]$NotesFile = ""
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $PSScriptRoot

Write-Host "============================================"
Write-Host " 发布 lanpass v$Version 到 GitHub"
Write-Host "============================================"

# 1. 检查 gh
$gh = Get-Command gh -ErrorAction SilentlyContinue
if (-not $gh) {
  Write-Host ""
  Write-Host "[错误] 没有找到 gh (GitHub CLI)" -ForegroundColor Red
  Write-Host ""
  Write-Host " 安装方法（任选其一）："
  Write-Host "   winget install --id GitHub.cli"
  Write-Host "   或到 https://cli.github.com 下载安装包"
  Write-Host ""
  Write-Host " 安装后运行:  gh auth login"
  Write-Host ""
  pause
  exit 1
}

# 2. 检查登录
$auth = gh auth status 2>&1
if ($LASTEXITCODE -ne 0) {
  Write-Host "[错误] gh 尚未登录" -ForegroundColor Red
  Write-Host " 请先运行:  gh auth login"
  pause
  exit 1
}
Write-Host "[OK] gh 已登录"

# 3. 打包
$buildScript = Join-Path $PSScriptRoot "build-release.ps1"
if (-not (Test-Path $buildScript)) {
  Write-Host "[错误] 找不到 build-release.ps1" -ForegroundColor Red
  pause
  exit 1
}
Write-Host ""
Write-Host " 正在打包..."
& powershell -ExecutionPolicy Bypass -File $buildScript -Version $Version

$zip = Join-Path $Root "dist\lanpass-v$Version.zip"
if (-not (Test-Path $zip)) {
  Write-Host "[错误] 打包失败，找不到 $zip" -ForegroundColor Red
  pause
  exit 1
}

# 4. 发布说明
if ($NotesFile -eq "") {
  $candidate = Join-Path $Root "RELEASE_NOTES_v$Version.md"
  if (Test-Path $candidate) { $NotesFile = $candidate }
}

# 5. 创建 Release
Write-Host ""
Write-Host " 正在创建 Release v$Version ..."
$tag = "v$Version"

$existing = gh release view $tag 2>&1
if ($LASTEXITCODE -eq 0) {
  Write-Host "[提示] Release $tag 已存在，将上传并覆盖附件"
  gh release upload $tag $zip --clobber
} else {
  if ($NotesFile -ne "" -and (Test-Path $NotesFile)) {
    gh release create $tag $zip --title "lanpass $tag" --notes-file $NotesFile
  } else {
    gh release create $tag $zip --title "lanpass $tag" --generate-notes
  }
}

if ($LASTEXITCODE -eq 0) {
  Write-Host ""
  Write-Host "============================================" -ForegroundColor Green
  Write-Host " 发布成功" -ForegroundColor Green
  Write-Host "============================================" -ForegroundColor Green
  gh release view $tag
} else {
  Write-Host "[失败] 发布出错，请检查上面的输出" -ForegroundColor Red
}

pause
