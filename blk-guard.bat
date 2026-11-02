@echo off
rem ============================================================
rem  防装拦截  blk-guard.bat
rem  作用：在没有安装 360 系列 / 2345 / 金山毒霸的机器上，
rem        写入拦截规则，防止以后被安装。
rem  用法：blk-guard.bat        写入拦截
rem        blk-guard.bat check  只检测不写入
rem  注意：需要管理员权限；检测到 360 自动跳过。
rem ============================================================
setlocal enabledelayedexpansion

if /i "%~1"=="check" set CHECKONLY=1

set FOUND=
set REASON=

rem ---------- 1. 目录检测 ----------
if not defined FOUND (
  if exist "%ProgramFiles%\360" (
  set FOUND=1
  set REASON=安装目录 Program Files\360
  )
)
if not defined FOUND (
  if exist "%ProgramFiles(x86)%\360" (
  set FOUND=1
  set REASON=安装目录 Program Files x86\360
  )
)
if not defined FOUND (
  if exist "%ProgramData%\360" (
  set FOUND=1
  set REASON=安装目录 ProgramData\360
  )
)
if not defined FOUND (
  if exist "%LOCALAPPDATA%\360" (
  set FOUND=1
  set REASON=安装目录 LocalAppData\360
  )
)

dir /b "%ProgramFiles%\360*" >nul 2>&1
if not errorlevel 1 (
  set FOUND=1
  set REASON=Program Files 下存在 360 目录
)
dir /b "%ProgramFiles(x86)%\360*" >nul 2>&1
if not errorlevel 1 (
  set FOUND=1
  set REASON=Program Files x86 下存在 360 目录
)

rem ---------- 2. 进程检测 ----------
if not defined FOUND (
  tasklist /fo csv 2>nul | findstr /i "360safe 360sd 360tray 360se 360zip 360chrome qhsafe qhactivedefense zhudongfangyu 360drvmgr 360softmgr" >nul
  if not errorlevel 1 (
    set FOUND=1
    set REASON=有 360 进程在运行
  )
)

rem ---------- 3. 注册表检测（精确匹配专属主键）----------
if not defined FOUND (
  reg query "HKLM\SOFTWARE\360" >nul 2>&1
  if not errorlevel 1 (
    set FOUND=1
    set REASON=存在 HKLM SOFTWARE 360 主键
  )
)
if not defined FOUND (
  reg query "HKLM\SOFTWARE\WOW6432Node\360" >nul 2>&1
  if not errorlevel 1 (
    set FOUND=1
    set REASON=存在 WOW6432Node 360 主键
  )
)
if not defined FOUND (
  reg query "HKLM\SOFTWARE\Qihoo" >nul 2>&1
  if not errorlevel 1 (
    set FOUND=1
    set REASON=存在 Qihoo 主键
  )
)
if not defined FOUND (
  reg query "HKCU\SOFTWARE\360" >nul 2>&1
  if not errorlevel 1 (
    set FOUND=1
    set REASON=存在 HKCU SOFTWARE 360 主键
  )
)
if not defined FOUND (
  reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" /s /f "360安全" 2>nul | findstr /i "360安全" >nul
  if not errorlevel 1 (
    set FOUND=1
    set REASON=卸载项含 360安全
  )
)
if not defined FOUND (
  reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" /s /f "360杀毒" 2>nul | findstr /i "360杀毒" >nul
  if not errorlevel 1 (
    set FOUND=1
    set REASON=卸载项含 360杀毒
  )
)
if not defined FOUND (
  reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" /s /f "奇虎" 2>nul | findstr /i "奇虎" >nul
  if not errorlevel 1 (
    set FOUND=1
    set REASON=卸载项含 奇虎
  )
)
rem ---------- 4. 结果判定 ----------
if defined FOUND (
  echo.
  echo [跳过] 检测到本机存在 360 系列产品
  echo        依据：!REASON!
  echo        出于安全考虑，本次不写入任何拦截规则。
  echo.
  reg add "HKLM\SOFTWARE\LanShare" /v GuardState /t REG_SZ /d "skipped-360" /f >nul 2>&1
  reg add "HKLM\SOFTWARE\LanShare" /v GuardReason /t REG_SZ /d "!REASON!" /f >nul 2>&1
  exit /b 2
)

if defined CHECKONLY (
  echo [检测结果] 未发现 360，可以安装防装拦截。
  exit /b 0
)

rem ---------- 5. 写入拦截规则 ----------
echo.
echo 未检测到 360，正在写入防装拦截规则...

set DBG=%SystemRoot%\System32\systray.exe
set BLKLIST=360Safe.exe 360sd.exe 360tray.exe 360se.exe 360zip.exe 360chrome.exe 360ChromeMgr.exe 360DrvMgr.exe 360AppLoader.exe 360SoftMgr.exe 360speedld.exe 360Box.exe 360Login.exe 360se6.exe QHSafe.exe QHSafeTray.exe QHActiveDefense.exe ZhuDongFangYu.exe QHWatchdog.exe 2345Explorer.exe 2345Pic.exe 2345Player.exe 2345MiniPage.exe 2345SoftMgr.exe 2345ExplorerSetup.exe 2345Browser.exe kxetray.exe kxescore.exe kxemain.exe kxescan.exe kwsui.exe kavstart.exe kwsprotect.exe kxetool.exe kxesysdef.exe

for %%E in (%BLKLIST%) do (
  reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\%%E" /v Debugger /t REG_SZ /d "%DBG%" /f >nul 2>&1
  reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\%%E" /v BlkGuard /t REG_SZ /d "LanShare" /f >nul 2>&1
)

rem 验证是否真的写进去了
reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\360Safe.exe" /v Debugger >nul 2>&1
if errorlevel 1 (
  echo [失败] 拦截规则写入失败，通常是没有管理员权限。
  reg add "HKLM\SOFTWARE\LanShare" /v GuardState /t REG_SZ /d "failed" /f >nul 2>&1
  exit /b 1
)

reg add "HKLM\SOFTWARE\LanShare" /v GuardState /t REG_SZ /d "enabled" /f >nul 2>&1
reg add "HKLM\SOFTWARE\LanShare" /v GuardTime /t REG_SZ /d "%DATE% %TIME%" /f >nul 2>&1

echo [完成] 已拦截 35 个可执行文件名的启动
echo        覆盖 360 全家桶 / 2345 / 金山毒霸 主力程序
echo.
echo        如需恢复：运行 blk-guard-undo.bat
echo.
exit /b 0
