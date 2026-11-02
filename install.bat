@echo off
rem ============================================================
rem  机房共享 - 安装并启动（由 EXE 自解压后调用）
rem  用法：install.bat teacher  或  install.bat student
rem ============================================================
setlocal
set ROLE=%~1
if "%ROLE%"=="" set ROLE=student

set SRC=%~dp0
set DEST=%PUBLIC%\LanShare

rem ---- 1. 确定安装目录 ----
if not exist "%PUBLIC%" set DEST=%LOCALAPPDATA%\LanShare
if not exist "%DEST%" mkdir "%DEST%" 2>nul
if not exist "%DEST%" (
  echo [错误] 无法创建安装目录：%DEST%
  echo        请检查磁盘空间或权限。
  pause
  exit /b 1
)

rem ---- 2. 复制程序文件 ----
copy /Y "%SRC%app.hta"        "%DEST%\" >nul 2>&1
copy /Y "%SRC%setup-share.bat" "%DEST%\" >nul 2>&1
copy /Y "%SRC%autostart.bat"   "%DEST%\" >nul 2>&1
copy /Y "%SRC%README.txt"      "%DEST%\" >nul 2>&1
copy /Y "%SRC%bg-student.jpg"  "%DEST%\" >nul 2>&1
copy /Y "%SRC%panel-dark.png"  "%DEST%\" >nul 2>&1
copy /Y "%SRC%QRA.txt" "%DEST%\" >nul 2>&1
copy /Y "%SRC%blk-guard.bat" "%DEST%\" >nul 2>&1
copy /Y "%SRC%blk-guard-undo.bat" "%DEST%\" >nul 2>&1

if not exist "%DEST%\app.hta" (
  echo [错误] 复制文件失败，安装目录：%DEST%
  pause
  exit /b 1
)

rem ---- 3. 写入注册表 ----
reg add "HKCU\Software\LanShare" /v InstallDir /t REG_SZ /d "%DEST%" /f >nul 2>&1
reg add "HKCU\Software\LanShare" /v Role       /t REG_SZ /d "%ROLE%" /f >nul 2>&1
reg add "HKCU\Software\LanShare" /v Version    /t REG_SZ /d "1.0"  /f >nul 2>&1
reg add "HKCU\Software\LanShare" /v LastRun    /t REG_SZ /d "%DATE% %TIME%" /f >nul 2>&1
reg add "HKCU\Software\LanShare" /v AppPath    /t REG_SZ /d "%DEST%\app.hta" /f >nul 2>&1

rem ---- 4. 校验注册表 ----
reg query "HKCU\Software\LanShare" /v Role >nul 2>&1
if errorlevel 1 (
  echo [警告] 注册表写入失败，程序仍可使用，但记录不完整。
)

rem ---- 5. 防呆：已有窗口就不重复开 ----
rem 说明：以 mshta.exe 进程存在为准。机房环境通常不会有别的 HTA 程序。
tasklist /fi "imagename eq mshta.exe" 2>nul | find /i "mshta.exe" >nul
if not errorlevel 1 (
  exit /b 0
)

rem ---- 6. 启动图形界面（低优先级）----
start "" /low mshta.exe "%DEST%\app.hta" %ROLE%

exit /b 0
