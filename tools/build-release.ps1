<#
  lanpass 发行版打包脚本
  用法：右键「使用 PowerShell 运行」，或在 tools 目录执行：
        powershell -ExecutionPolicy Bypass -File .\build-release.ps1
  产物：dist\lanpass-v<版本>.zip + SHA256.txt
#>

param(
  [string]$Version = "1.0.0"
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $PSScriptRoot
if (-not (Test-Path (Join-Path $Root "app.hta"))) {
  Write-Host "[错误] 找不到仓库根目录（应当包含 app.hta）" -ForegroundColor Red
  Write-Host "       当前推断的根目录: $Root"
  pause
  exit 1
}

$PkgName = "lanpass-v$Version"
$DistDir = Join-Path $Root "dist"
$PkgDir  = Join-Path $DistDir $PkgName
$ZipPath = Join-Path $DistDir "$PkgName.zip"

Write-Host "============================================"
Write-Host " 打包 lanpass 发行版"
Write-Host "============================================"
Write-Host " 版本: $Version"
Write-Host " 根目录: $Root"
Write-Host ""

# 清理
if (Test-Path $PkgDir) { Remove-Item $PkgDir -Recurse -Force }
if (Test-Path $ZipPath) { Remove-Item $ZipPath -Force }
New-Item -ItemType Directory -Force -Path $PkgDir | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $PkgDir "绿色版-免安装") | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $PkgDir "说明文档") | Out-Null

# 根目录文件
$rootFiles = @("教师端.exe","学生端.exe")
foreach ($f in $rootFiles) {
  $src = Join-Path $Root $f
  if (Test-Path $src) { Copy-Item $src $PkgDir -Force; Write-Host "  + $f" }
  else { Write-Host "  ! 缺少 $f" -ForegroundColor Yellow }
}

# 绿色版文件
$greenFiles = @("app.hta","setup-share.bat","autostart.bat","blk-guard.bat","blk-guard-undo.bat",
                "bg-student.jpg","panel-dark.png","教师端.bat","学生端.bat")
foreach ($f in $greenFiles) {
  $src = Join-Path $Root $f
  if (Test-Path $src) { Copy-Item $src (Join-Path $PkgDir "绿色版-免安装") -Force }
  else { Write-Host "  ! 缺少 $f" -ForegroundColor Yellow }
}
# 绿色版启动器改名
$g = Join-Path $PkgDir "绿色版-免安装"
if (Test-Path (Join-Path $g "教师端.bat")) { Copy-Item (Join-Path $g "教师端.bat") (Join-Path $g "启动教师端.bat") -Force; Remove-Item (Join-Path $g "教师端.bat") -Force }
if (Test-Path (Join-Path $g "学生端.bat")) { Copy-Item (Join-Path $g "学生端.bat") (Join-Path $g "启动学生端.bat") -Force; Remove-Item (Join-Path $g "学生端.bat") -Force }

# 文档
$docDir = Join-Path $PkgDir "说明文档"
$docMap = @{
  "docs/QRA.txt" = "QRA.txt"
  "docs/SECURITY.md" = "安全说明.md"
}
foreach ($k in $docMap.Keys) {
  $src = Join-Path $Root $k
  if (Test-Path $src) { Copy-Item $src (Join-Path $docDir $docMap[$k]) -Force }
}
if (Test-Path (Join-Path $Root "README.md")) {
  Copy-Item (Join-Path $Root "README.md") (Join-Path $docDir "README.md") -Force
}

# 先看我（若存在）
$firstLook = Join-Path $Root "先看我-使用说明.txt"
if (Test-Path $firstLook) { Copy-Item $firstLook $PkgDir -Force }

Write-Host ""
Write-Host " 正在压缩..."
Compress-Archive -Path (Join-Path $PkgDir "*") -DestinationPath $ZipPath -CompressionLevel Optimal

$zi = Get-Item $ZipPath
$sha = (Get-FileHash $ZipPath -Algorithm SHA256).Hash

$shaFile = Join-Path $DistDir "SHA256.txt"
"$sha  $PkgName.zip" | Out-File $shaFile -Encoding ASCII

Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Host " 打包完成" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host " 文件: $ZipPath"
Write-Host " 大小: $([math]::Round($zi.Length/1KB,1)) KB"
Write-Host " SHA256: $sha"
Write-Host ""
Write-Host " 下一步：把 dist\$PkgName.zip 上传到 GitHub Release"
Write-Host ""
pause
