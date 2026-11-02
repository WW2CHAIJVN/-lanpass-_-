<div align="center">
  <img src="docs/banner.png" alt="lanpass" width="100%">
</div>

<div align="center">

**简体中文** | [English](README.en.md) | [日本語](README.ja.md) | [한국어](README.ko.md) | [Русский](README.ru.md) | [Español](README.es.md) | [Français](README.fr.md)

**当家庭组消失、网络发现失效、来宾访问被默认关闭时——它仍然能让 Windows 7 / 10 / 11 互相看见。**

<br>

<img src="https://img.shields.io/badge/Windows-7%20%7C%2010%20%7C%2011-0078D6?style=flat-square&logo=windows&logoColor=white" alt="Platform">
<img src="https://img.shields.io/badge/License-MIT-3DA639?style=flat-square" alt="License">
<img src="https://img.shields.io/badge/dependencies-zero-success?style=flat-square" alt="Dependencies">
<img src="https://img.shields.io/badge/backend-mshta%20%2B%20cmd-blue?style=flat-square" alt="Backend">

<br><br>

[特性](#特性) &nbsp;·&nbsp; [截图](#截图) &nbsp;·&nbsp; [快速开始](#快速开始) &nbsp;·&nbsp; [原理](#原理) &nbsp;·&nbsp; [性能](#性能) &nbsp;·&nbsp; [FAQ](#faq) &nbsp;·&nbsp; [安全](#安全与限制)

</div>

---

## 为什么会有这个项目

机房里有这样一幕：几十台电脑，同一台交换机，同一个网段，但「网上邻居」里互相看不见。

原因有两层，**第二层才是真正的病根**。

<br>

<table>
<tr>
<td width="50%" valign="top">

### 表层：家庭组没了

| 版本 | 家庭组 |
|------|--------|
| Windows 7 | 引入 |
| Windows 8.1 | 仍然支持 |
| Windows 10 1803 | **被移除** |

Win7 和 Win10/11 之间没有共同的家庭组机制。

</td>
<td width="50%" valign="top">

### 深层：SMB 来宾认证被关闭

从 **Windows 10 1709** 起：

| 注册表项 | 默认值 |
|---------|--------|
| `AllowInsecureGuestAuth` | `0` |
| `LimitBlankPasswordUse` | `1` |

即使绕过家庭组、用 IP 直连，Win10/11 仍会报：

> 你组织的安全策略阻止未经身份验证的来宾访问

</td>
</tr>
</table>

<div align="center">

**只解决家庭组没有用。卡住的是 SMB 认证这一层。**

</div>

---

## 特性

<table>
<tr>
<td width="25%" valign="top">

### 零依赖

只用系统自带的 `mshta` / `cmd` / `net` / `ping` / `arp`。

不需要 .NET、VC++ 运行库、Java、Python、Node。

</td>
<td width="25%" valign="top">

### 不靠网络发现

家庭组、网络发现、Computer Browser、SSDP、DNS 全部失效也照用。

</td>
<td width="25%" valign="top">

### 跨版本互通

Win7 / Win10 / Win11 双向访问。

自动修复 4 项注册表。

</td>
<td width="25%" valign="top">

### 双端设计

教师端管理全班，学生端一键交作业。

一个程序，两种角色。

</td>
</tr>
</table>

---

## 截图

<table>
<tr>
<td width="50%" align="center">

**教师端** · 父级主机

<img src="docs/screenshots/teacher.png" alt="教师端">

</td>
<td width="50%" align="center">

**学生端** · 子级主机

<img src="docs/screenshots/student.png" alt="学生端">

</td>
</tr>
</table>

---

## 快速开始

<details open>
<summary><b>方式一：EXE 版，双击即用</b></summary>

<br>

1. 把整个目录拷到机房电脑
2. 教师机双击 `教师端.exe`，学生机双击 `学生端.exe`
3. 点「配置共享」，UAC 弹窗点「是」
4. 教师端点「刷新学生机」，列表空就点「全段扫描」
5. 点学生那行的「打开」，进入共享目录收作业

</details>

<details>
<summary><b>方式二：绿色版，免安装</b></summary>

<br>

打开 `绿色版-免安装` 文件夹，双击 `启动教师端.bat` 或 `启动学生端.bat`。

功能完全一样，区别是**不写安装注册表、不释放文件到临时目录**，杀软误报概率更低。

</details>

<details>
<summary><b>方式三：机房没有 D 盘怎么办</b></summary>

<br>

用记事本打开两个文件，把 `D:\lan-share` 改成实际路径：

- `setup-share.bat` 里的 `set SHARE_DIR=D:\lan-share`
- `app.hta` 里的 `var SHARE_DIR  = "D:\\lan-share";`

改完重新点一次「配置共享」。

</details>

---

## 原理

### 1. 发现：不碰任何系统服务

```text
┌─────────────────────────────────────────────┐
│  读本机 ARP 表                              │
│  （TCP/IP 二层，与任何 Windows 服务无关）    │
└──────────────────┬──────────────────────────┘
                   │ ARP 为空时
                   ▼
┌─────────────────────────────────────────────┐
│  全段 ping 扫描 254 个地址                   │
│  分批 32 个并行，约 4 秒                     │
└──────────────────┬──────────────────────────┘
                   │ 填充 ARP 表
                   ▼
┌─────────────────────────────────────────────┐
│  读对方共享目录里的 .lanshare.ini            │
│  识别角色 teacher / student                  │
└─────────────────────────────────────────────┘
```

关键点：ping 的目的是**填充 ARP 表**，不是等 ICMP 回应。即使对方防火墙禁 ping，只要在线，ARP 层仍会记录它的 MAC。

### 2. 互通：四项注册表修复

```text
AllowInsecureGuestAuth = 1     允许来宾访问
LimitBlankPasswordUse  = 0     允许空密码账户远程访问
RestrictNullSessAccess = 0     允许匿名会话访问共享
net user guest /active:yes     启用 Guest 账户
```

### 3. 角色识别：一个文本文件

每台机器在共享目录写 `.lanshare.ini`：

```ini
ROLE=teacher
NAME=教师机-301
IP=192.168.5.10
```

对方读到就知道角色。**纯文件方案**，不需要服务器、数据库或广播协议。

### 4. 界面：HTA + JScript

用 Windows 自带的 `mshta.exe` 渲染 HTA 界面，IE8 引擎兼容模式。全部代码是明文 HTML + JScript，可直接审查。

---

## 性能

<div align="center">

| 指标 | 实测值 |
|:----:|:------:|
| 内存占用 | **34 MB** |
| 空闲 CPU | **0%** |
| 启动 CPU | **0.2 秒** |
| 快速刷新 | **约 1 秒** |
| 全段扫描 | **约 4 秒**（254 个地址） |

</div>

没有定时器轮询，不后台跑任何东西，启动完成后完全静止。奔腾级别机器可跑。

---

## FAQ

完整 **27 条**见 [docs/QRA.txt](docs/QRA.txt)。高频问题：

<details>
<summary><b>Win10 打不开 Win7 的共享，报「安全策略阻止来宾访问」？</b></summary>

<br>

就是本文开头说的 `AllowInsecureGuestAuth`。

**两台机器都点一次「配置共享」**，然后重启电脑。

</details>

<details>
<summary><b>列表一直是空的？</b></summary>

<br>

1. 点「全段扫描」
2. 确认双方 IP 前三位相同
3. 确认在同一台交换机
4. 确认都点过「配置共享」

</details>

<details>
<summary><b>杀毒软件报警？</b></summary>

<br>

见下方「关于防装拦截」和 [docs/SECURITY.md](docs/SECURITY.md)。

最常见的原因是 IExpress 自解压包 + mshta 执行脚本这两个特征被行为引擎打标。

</details>

---

## 关于防装拦截

`blk-guard.bat` 是一个**可选**功能，作用是在没有安装 360 / 2345 / 金山毒霸的机器上写入拦截规则。

| | |
|---|---|
| 触发时机 | 只在点「配置共享」时执行一次，不是常驻 |
| 检测到 360 | 完全跳过，不碰它 |
| 撤销方式 | 运行 `blk-guard-undo.bat` 一键删除 |
| 不需要它 | 删掉 `blk-guard.bat`，`setup-share.bat` 会自动跳过 |

**它会显著提高杀软误报率**。写 IFEO 让特定程序无法启动，本身是恶意软件的常见手法，被安全软件重点监控是必然的。用不用自己权衡。

---

## 安全与限制

<details>
<summary><b>会改哪些注册表、降低多少安全性</b></summary>

<br>

打开来宾访问意味着**同网段的人不需要密码**就能读写共享目录。

这在机房是合理取舍（机房本来就不该用密码拦学生），但请：

- 只在机房内网使用
- 不要把这类共享暴露到公网
- 知道怎么恢复默认设置（见 [docs/SECURITY.md](docs/SECURITY.md)）

</details>

<details>
<summary><b>已知限制</b></summary>

<br>

- 需要 SMB 445 端口可用。如果机房组策略禁用了文件共享服务，本工具也无能为力
- 交换机开启端口隔离（VLAN 隔离）时，任何局域网工具都无法互通
- 全段扫描基于 /24 网段（前三段相同），非 /24 掩码的网段请用手动填 IP

</details>

<details>
<summary><b>兼容性</b></summary>

<br>

| 系统 | 状态 |
|------|------|
| Windows 7 SP1 | 支持（纯系统命令，不依赖 .NET） |
| Windows 8 / 8.1 | 支持 |
| Windows 10 | 支持（实测） |
| Windows 11 | 支持 |
| 32 / 64 位 | 都支持 |

> Win7 上未做实机测试，代码按 IE8 引擎 + 纯系统命令编写，理论上兼容。有真实环境测试反馈欢迎提 Issue。

</details>

---

## 踩过的坑

开发过程中实测发现并修掉的问题，留给后来人：

| 坑 | 后果 | 解法 |
|----|------|------|
| 批处理 LF 换行 | 脚本全部解析失败 | 强制 CRLF |
| IE8 `tbody.innerHTML` 只读 | 列表渲染直接抛异常 | 改用 div + display:table |
| `net view` 依赖 Browser 服务 | 无服务时阻塞 30~60 秒 | 移除，只用 ARP |
| 读不可达 IP 的 UNC 路径 | 单台卡 28~31 秒 | 先批量 ping 预检 |
| `findstr` 不加 `/l` | 特殊字符被当正则，共享名判断全错 | 加字面匹配参数 |
| `window.eval` 在函数内 | 函数定义落进局部作用域 | 移到顶层 eval |

---

## License

<div align="center">

**[MIT](LICENSE)** · 随便用，出事不负责

</div>
 
