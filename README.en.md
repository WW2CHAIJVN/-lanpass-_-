# lanpass

[简体中文](README.md) | **English** | [日本語](README.ja.md) | [한국어](README.ko.md) | [Русский](README.ru.md) | [Español](README.es.md) | [Français](README.fr.md)

> When HomeGroup is gone, network discovery fails, and guest access is disabled by default — lanpass still lets Windows 7 / 10 / 11 see each other.

<img src="https://img.shields.io/badge/Windows-7%20%7C%2010%20%7C%2011-0078D6?style=flat-square&logo=windows&logoColor=white" alt="Platform">
<img src="https://img.shields.io/badge/License-MIT-3DA639?style=flat-square" alt="License">
<img src="https://img.shields.io/badge/dependencies-zero-success?style=flat-square" alt="Dependencies">

## The problem

In a school computer lab: dozens of PCs, one switch, one subnet — yet the "Network" folder shows nothing.

Two layers of cause.

**Surface layer**: HomeGroup was introduced in Windows 7 and **removed in Windows 10 1803**. Win7 and Win10/11 share no common mechanism.

**Root cause**: Since Windows 10 1709, `AllowInsecureGuestAuth` defaults to 0. Win10/11 rejects all anonymous SMB access. Even if you bypass HomeGroup and connect by IP, you still get *"Your organization's security policies block unauthenticated guest access"*.

**Fixing HomeGroup alone does not help. The blocker is SMB authentication.**

## Features

| | |
|---|---|
| **Zero dependencies** | Only built-in `mshta` / `cmd` / `net` / `ping` / `arp`. No .NET, VC++ runtime, Java, Python, or Node |
| **No discovery services** | Works even when HomeGroup, Network Discovery, Computer Browser, SSDP, and DNS are all dead |
| **Cross-version** | Win7 / Win10 / Win11, both directions |
| **Two roles** | Teacher client for the whole class, student client for one-click submission |
| **Auto-fix auth** | Writes 4 registry values that resolve the guest-access block |
| **Active discovery** | ARP table + full-subnet ping sweep, no system service required |
| **Device memory** | Cached device list, instant on next launch |
| **Low footprint** | 34 MB RAM, 0% idle CPU, no polling |

## Quick start

1. Copy the folder to each lab PC
2. Teacher PC: run `教师端.exe`; student PC: run `学生端.exe`
3. Click "配置共享" (Configure share), approve UAC
4. Teacher: click "刷新学生机" (Refresh students). Empty list? Click "全段扫描" (Full scan)
5. Click "打开" (Open) on a student row to browse their shared folder

No D: drive? Edit `D:\lan-share` to an existing path in both `setup-share.bat` and `app.hta`.

## Interface

| Teacher | Student |
|---|---|
| ![](docs/screenshots/teacher.png) | ![](docs/screenshots/student.png) |

## More

- [Full FAQ (27 entries, Chinese)](docs/QRA.txt)
- [Security notes](docs/SECURITY.md)
- [Build instructions](BUILD.md)

## Tech notes

Discovery reads the local ARP table (layer 2, independent of any Windows service). When ARP is empty, a full-subnet ping sweep (254 addresses, 32 parallel, about 4 seconds) populates it — ping is only used to fill the ARP table, not to wait for ICMP replies.

The UI is an HTA rendered by the built-in `mshta.exe` (IE8 compatibility mode). All source is plain-text HTML + JScript and can be audited directly.

## License

MIT
 
