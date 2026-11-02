@echo off
rem ============================================================
rem  机房数据共享 - 一键配置本机共享
rem  兼容 Win7 / Win10 / Win11
rem  零 .NET 依赖：只用 net / icacls / netsh / sc / mshta
rem ============================================================
setlocal
set SHARE_DIR=D:\lan-share
set SHARE_NAME=share

rem --- 提权：用 mshta 触发 UAC（零 .NET，系统自带）---
rem 不做不可靠的 net session 检测，改为实际功能测试
reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies" >nul 2>&1
if errorlevel 1 goto :elevate
goto :run

:elevate
echo.
echo 需要管理员权限，正在请求提权...
echo 会弹出「用户帐户控制」窗口，请点「是」。
echo.
mshta "javascript:var s=new ActiveXObject('Shell.Application');s.ShellExecute('cmd.exe','/c \"\"%~f0\"\" admin',null,'runas',1);close();"
echo.
echo 若没有弹出窗口，或你点了「否」，请手动操作：
echo   右键 setup-share.bat 选择「以管理员身份运行」
echo.
pause
exit /b 1

:run
echo ============================================
echo  机房数据共享 - 配置本机共享
echo ============================================
echo.

rem 1. 创建共享目录
if not exist "%SHARE_DIR%" (
  mkdir "%SHARE_DIR%" 2>nul
)
if exist "%SHARE_DIR%" (
  echo [OK] 共享目录已就绪：%SHARE_DIR%
) else (
  echo [错误] 无法创建 %SHARE_DIR%
  echo        可能 D 盘不存在或没有写权限。
  goto :fail
)

rem 2. 建立共享（先删同名旧共享）
rem findstr 必须加 /l 字面匹配，否则 $ 等字符会被当正则
net share 2>nul | findstr /i /l /b /c:"%SHARE_NAME%" >nul
if not errorlevel 1 (
  echo [INFO] 共享 %SHARE_NAME% 已存在，先删除
  net share %SHARE_NAME% /delete >nul 2>&1
)

net share %SHARE_NAME%="%SHARE_DIR%" /grant:everyone,full >nul 2>&1
if errorlevel 1 (
  echo [错误] 创建共享失败。
  echo        请确认「Server (LanmanServer)」服务正在运行，且已用管理员身份运行。
  goto :fail
)
echo [OK] 已共享 %SHARE_NAME% 指向 %SHARE_DIR%

rem 3. NTFS 权限：Everyone 读写
icacls "%SHARE_DIR%" /grant Everyone:(OI)(CI)F /T >nul 2>&1
if errorlevel 1 (
  echo [警告] NTFS 权限设置失败，通常不影响使用
) else (
  echo [OK] 已设置 NTFS 权限 Everyone 读写
)

rem --- 3.5 跨版本兼容修复：Win7 <-> Win10/11 互访的关键 ---
rem Win10 1709+ 默认 AllowInsecureGuestAuth=0，会拒绝所有匿名 SMB 访问，
rem 这正是"Win10 打不开 Win7 共享"报安全策略错误的根本原因。
echo.
echo --- 跨版本兼容修复 ---
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters" /v AllowInsecureGuestAuth /t REG_DWORD /d 1 /f >nul 2>&1
if errorlevel 1 (
  echo [警告] 未能设置 AllowInsecureGuestAuth
) else (
  echo [OK] 已允许来宾访问（Win10/11 才能打开 Win7 的共享）
)
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v LimitBlankPasswordUse /t REG_DWORD /d 0 /f >nul 2>&1
if errorlevel 1 (
  echo [警告] 未能关闭空密码限制
) else (
  echo [OK] 已允许空密码账户远程访问
)
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v RestrictNullSessAccess /t REG_DWORD /d 0 /f >nul 2>&1
echo [OK] 已允许匿名会话访问共享
net user guest /active:yes >nul 2>&1
echo [OK] 已启用 Guest 账户
rem 4. 确保 Server 服务在运行
echo.
echo --- 共享服务 ---
sc query LanmanServer 2>nul | findstr /i "RUNNING" >nul
if errorlevel 1 (
  echo [INFO] 正在启动 LanmanServer ...
  net start LanmanServer >nul 2>&1
  sc query LanmanServer 2>nul | findstr /i "RUNNING" >nul
  if errorlevel 1 (
    echo [错误] 无法启动共享服务，请重启电脑后再试
  ) else (
    echo [OK] 共享服务已启动
  )
) else (
  echo [OK] 共享服务运行中
)

rem 5. 防火墙：直接放行 SMB 端口，不依赖规则组的中英文名称
echo.
echo --- 防火墙 ---
netsh advfirewall firewall add rule name="LANShare-SMB-TCP" dir=in action=allow protocol=TCP localport=139,445 >nul 2>&1
netsh advfirewall firewall add rule name="LANShare-SMB-UDP" dir=in action=allow protocol=UDP localport=137,138 >nul 2>&1
netsh advfirewall firewall show rule name="LANShare-SMB-TCP" >nul 2>&1
if errorlevel 1 (
  echo [警告] 未能自动添加防火墙规则
  echo        若同学连不上，请手动放行「文件和打印机共享」
) else (
  echo [OK] 已放行共享端口 139/445 TCP 与 137/138 UDP
)

rem 6. 汇总本机信息
echo.
echo ============================================
echo  配置完成
echo ============================================
echo  共享目录：%SHARE_DIR%
echo  共享名：  %SHARE_NAME%
echo.
echo  本机 IP 与访问路径：
for /f "tokens=2 delims=:" %%A in ('ipconfig ^| findstr /i "IPv4"') do (
  for /f "tokens=* delims= " %%B in ("%%A") do (
    echo    \\%%B\%SHARE_NAME%
  )
)
echo.
echo  同学在「运行」(Win+R) 输入上面的路径即可打开。
echo  也可在本程序里点「刷新列表」，选中机器后点「打开共享目录」。
rem 7. 防装拦截（检测到 360 会自动跳过）
echo.
echo --- 防装拦截 ---
if exist "%~dp0blk-guard.bat" (
  call "%~dp0blk-guard.bat"
) else (
  echo [跳过] 找不到 blk-guard.bat
)

echo.
pause
exit /b 0

:fail

echo.
echo 配置失败。请记录上面的错误信息，或改用：
echo   右键 setup-share.bat 选择「以管理员身份运行」
echo.
pause
exit /b 1
