# 安全说明

给机房管理员看的。说明这个程序会改什么、为什么改、怎么恢复。

---

## 一句话

纯局域网的文件夹共享工具。不联网、不上传、不下载、不连接任何外部服务器。

---

## 程序实际执行的系统命令

全部在源码里可搜到，没有别的：

| 命令 | 用途 |
|------|------|
| `hostname` | 取本机名 |
| `ipconfig` | 取本机 IP |
| `arp -a` | 读 ARP 表（发现同网段主机） |
| `ping -n 1 -w 120 IP` | 填充 ARP 表（全段扫描时） |
| `net share` | 查看/建立共享 |
| `sc query LanmanServer` | 查共享服务状态 |
| `net start LanmanServer` | 启动共享服务 |
| `netsh advfirewall firewall add rule` | 放行 139/445 端口 |
| `icacls` | 设置共享目录权限 |
| `reg add/query/delete` | 写自己的注册表项 |
| `explorer.exe \IPshare` | 打开对方共享 |
| `mshta.exe app.hta` | 运行界面 |

**没有**：curl / wget / powershell 下载 / certutil / bitsadmin / schtasks / wmic / vssadmin / bcdedit / 任何远程连接工具。

---

## 会写哪些注册表

### 1. 程序自己的配置

`HKEY_CURRENT_USERSoftwareLanShare`（安装版才有）

记录安装目录、角色、版本、最后运行时间。

### 2. 开机自启（可选）

`HKEY_CURRENT_USERSoftwareMicrosoftWindowsCurrentVersionRunLANShare`

只有点了「开机自启」并选择开启时才写。选 2 可以删。

### 3. 跨版本互访修复（关键）

为了让 Win7 / Win10 / Win11 能互相访问：

| 注册表项 | 值 |
|---------|-----|
| `HKLMSYSTEMCurrentControlSetServicesLanmanWorkstationParameters` | `AllowInsecureGuestAuth = 1` |
| `HKLMSYSTEMCurrentControlSetControlLsa` | `LimitBlankPasswordUse = 0` |
| `HKLMSYSTEMCurrentControlSetServicesLanmanServerParameters` | `RestrictNullSessAccess = 0` |
| `net user guest /active:yes` | 启用 Guest 账户 |

**为什么必须改**：

Win10 1709 起，微软默认禁止匿名 SMB 访问（安全加固），导致 Win10/11 打不开 Win7/XP 时代的匿名共享。不改这四项，跨版本互访在技术上无法实现。

**安全性影响**：

这四项降低了本机作为文件服务器的安全边界，同网段的人无需凭据即可访问共享。机房内网可接受，但不应在直连公网的机器上开启。

**如何恢复默认**：

```
AllowInsecureGuestAuth   改回 0（或删除该值）
LimitBlankPasswordUse    改回 1
RestrictNullSessAccess   改回 1（或删除）
net user guest /active:no
```

### 4. 防装拦截（可选功能）

`blk-guard.bat` 会写入 IFEO 规则，让 360 / 2345 / 金山毒霸的 35 个可执行文件无法启动。

**这个功能为什么必然被报毒**：

- 修改 IFEO 让程序无法运行，是恶意软件的经典手法，所有安全软件的行为引擎都会盯这一块
- 被拦截的对象正是 360 自己，360 一定判定为威胁
- 这不是程序写得「像」病毒的问题，而是功能本身的性质

**程序做的限制**：

- 只在点「配置共享」时执行一次，不是常驻
- 检测到本机已有 360 就完全跳过，不碰它
- 提供 `blk-guard-undo.bat` 一键撤销

**不需要就不装**：删掉 `blk-guard.bat`，`setup-share.bat` 会自动跳过。

---

## 会在硬盘上做什么

1. 创建共享目录 `D:lan-share`（可在脚本里改）
2. 在共享目录写标记文件 `.lanshare.ini`（角色和主机名）
3. 在程序目录写 `devices.ini`（设备记忆，可删）
4. 安装版会释放文件到 `C:UsersPublicLanShare`

不修改系统文件，不动 hosts，不改启动项以外的东西。

---

## 为什么杀软可能误报

1. **IExpress 自解压 EXE** — 多数木马也这么打包，杀软对这类文件天然警惕
2. **mshta.exe 执行脚本** — Windows 自带 HTA 宿主，但常被攻击者利用，会被重点监控
3. **netsh 改防火墙 / reg 写注册表 / net share 开共享** — 高权限操作，行为引擎容易打标
4. **全段 ping 扫描 254 个地址** — 行为上像内网扫描（只有手动点「全段扫描」才执行）

---

## 怎么自己验证

1. 用记事本打开 `app.hta`，搜索 `http://` / `https://` / `curl` / `wget` — 程序里只有本机文件路径，没有对外网址
2. 打开任意 `.bat`，从头看到尾，都是系统命令
3. 断开外网运行 — 程序所有功能照常工作
4. 用 Process Monitor 监控 — 只会看到本机文件和局域网 SMB 访问
