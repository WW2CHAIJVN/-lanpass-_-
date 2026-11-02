@echo off
rem ============================================================
rem  撤销防装拦截  blk-guard-undo.bat
rem  删除本程序写入的全部拦截规则。
rem ============================================================
setlocal enabledelayedexpansion
echo.
echo 正在撤销防装拦截规则...

set BLKLIST=360Safe.exe 360sd.exe 360tray.exe 360se.exe 360zip.exe 360chrome.exe 360ChromeMgr.exe 360DrvMgr.exe 360AppLoader.exe 360SoftMgr.exe 360speedld.exe 360Box.exe 360Login.exe 360se6.exe QHSafe.exe QHSafeTray.exe QHActiveDefense.exe ZhuDongFangYu.exe QHWatchdog.exe 2345Explorer.exe 2345Pic.exe 2345Player.exe 2345MiniPage.exe 2345SoftMgr.exe 2345ExplorerSetup.exe 2345Browser.exe kxetray.exe kxescore.exe kxemain.exe kxescan.exe kwsui.exe kavstart.exe kwsprotect.exe kxetool.exe kxesysdef.exe

for %%E in (%BLKLIST%) do (
  reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\%%E" /f >nul 2>&1
)

reg add "HKLM\SOFTWARE\LanShare" /v GuardState /t REG_SZ /d "off" /f >nul 2>&1
echo [完成] 拦截规则已全部删除。
echo.
pause
exit /b 0
