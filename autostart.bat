@echo off
rem ============================================================
rem  机房共享 - 开机自启 设置 / 取消
rem  用法：autostart.bat [teacher^|student]
rem  不带参数则交互询问
rem ============================================================
setlocal
set HERE=%~dp0
set KEY=HKCU\Software\Microsoft\Windows\CurrentVersion\Run
set NAME=LANShare
set ROLE=%~1

if "%ROLE%"=="" goto :ask
goto :menu

:ask
echo.
echo 本机是教师机还是学生机？
echo   1 = 教师机（父级）
echo   2 = 学生机（子级）
set /p RC=请输入 1 / 2 然后回车：
if "%RC%"=="1" set ROLE=teacher
if "%RC%"=="2" set ROLE=student
if "%ROLE%"=="" (
  echo 输入无效。
  pause
  exit /b 1
)

:menu
if /i "%ROLE%"=="teacher" set BAT=教师端.bat
if /i "%ROLE%"=="student" set BAT=学生端.bat
if "%BAT%"=="" (
  echo 角色参数无效：%ROLE%
  pause
  exit /b 1
)

echo ============================================
echo   开机自启 设置  （当前角色：%ROLE%）
echo ============================================
echo.
echo   1 = 开启开机自启
echo   2 = 关闭开机自启
echo   3 = 查看当前状态
echo.
set /p CHOICE=请输入 1 / 2 / 3 然后回车：

if "%CHOICE%"=="1" goto :do_on
if "%CHOICE%"=="2" goto :do_off
if "%CHOICE%"=="3" goto :do_status
echo 输入无效，退出。
pause
exit /b 1

:do_on
if not exist "%HERE%app.hta" (
  echo [错误] 找不到 app.hta，请确认程序文件完整。
  pause
  exit /b 1
)
rem 自启目标直接指向 mshta + app.hta + 角色，不依赖外部 bat
reg add "%KEY%" /v %NAME% /t REG_SZ /d "mshta.exe \"%HERE%app.hta\" %ROLE%" /f >nul
if errorlevel 1 (
  echo [失败] 写入注册表失败。
) else (
  echo [成功] 已设为开机自启（角色：%ROLE%）
  echo        下次登录 Windows 会自动打开。
)
pause
exit /b 0

:do_off
reg delete "%KEY%" /v %NAME% /f >nul 2>&1
if errorlevel 1 (
  echo [提示] 当前没有设置开机自启。
) else (
  echo [成功] 已取消开机自启。
)
pause
exit /b 0

:do_status
reg query "%KEY%" /v %NAME% >nul 2>&1
if errorlevel 1 (
  echo [状态] 当前：未设置开机自启
) else (
  echo [状态] 当前：已开启开机自启
  reg query "%KEY%" /v %NAME% 2>nul | findstr /i "%NAME%"
)
pause
exit /b 0
