@echo off
rem ============================================================
rem  机房共享 - 学生端（子级主机）启动器
rem  双击运行
rem ============================================================
setlocal
set HERE=%~dp0

if not exist "%HERE%app.hta" (
  echo [错误] 找不到 app.hta，请把整个文件夹一起拷贝。
  pause
  exit /b 1
)

rem 防呆：已有「机房共享」窗口就不重复开
tasklist /v /fi "imagename eq mshta.exe" 2>nul | find "机房共享" >nul
if not errorlevel 1 (
  echo 程序已经在运行了，不用重复打开。
  timeout /t 2 >nul
  exit /b 0
)

rem 低优先级启动，减少对奔腾 CPU 的占用
start "" /low mshta.exe "%HERE%app.hta" student
