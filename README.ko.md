# lanpass

[简体中文](README.md) | [English](README.en.md) | [日本語](README.ja.md) | **한국어** | [Русский](README.ru.md) | [Español](README.es.md) | [Français](README.fr.md)

> 홈 그룹이 사라지고, 네트워크 검색이 작동하지 않고, 게스트 액세스가 기본으로 차단되어도 — lanpass는 Windows 7 / 10 / 11이 서로를 볼 수 있게 합니다.

<img src="https://img.shields.io/badge/Windows-7%20%7C%2010%20%7C%2011-0078D6?style=flat-square&logo=windows&logoColor=white" alt="Platform">
<img src="https://img.shields.io/badge/License-MIT-3DA639?style=flat-square" alt="License">
<img src="https://img.shields.io/badge/dependencies-zero-success?style=flat-square" alt="Dependencies">

## 문제

학교 컴퓨터실: 수십 대의 PC, 같은 스위치, 같은 서브넷. 그런데 "네트워크"에 아무것도 보이지 않습니다.

원인은 두 층입니다.

**표면적 원인**: 홈 그룹은 Windows 7에서 도입되어 **Windows 10 1803에서 제거**되었습니다. Win7과 Win10/11에는 공통 메커니즘이 없습니다.

**근본 원인**: Windows 10 1709부터 `AllowInsecureGuestAuth`의 기본값은 0입니다. Win10/11은 모든 익명 SMB 액세스를 거부합니다. 홈 그룹을 우회하여 IP로 직접 연결해도 *"조직의 보안 정책이 인증되지 않은 게스트 액세스를 차단합니다"*라는 오류가 발생합니다.

**홈 그룹만 고쳐서는 해결되지 않습니다. 막고 있는 것은 SMB 인증입니다.**

## 기능

| | |
|---|---|
| **무의존성** | 기본 제공 `mshta` / `cmd` / `net` / `ping` / `arp`만 사용. .NET, VC++ 런타임, Java, Python, Node 불필요 |
| **검색 서비스 불필요** | 홈 그룹, 네트워크 검색, Computer Browser, SSDP, DNS가 모두 중지되어도 동작 |
| **버전 간 호환** | Win7 / Win10 / Win11 양방향 |
| **두 가지 역할** | 교사용은 학급 전체 관리, 학생용은 원클릭 제출 |
| **인증 자동 수정** | 게스트 액세스 차단을 해결하는 레지스트리 값 4개 기록 |
| **능동 검색** | ARP 테이블 + 전체 서브넷 ping 스캔, 시스템 서비스 불필요 |
| **장치 기억** | 장치 목록을 캐시하여 다음 실행 시 즉시 표시 |
| **저부하** | 메모리 34 MB, 유휴 CPU 0%, 폴링 없음 |

## 빠른 시작

1. 폴더를 각 PC에 복사
2. 교사 PC: `教师端.exe` 실행, 학생 PC: `学生端.exe` 실행
3. "配置共享"(공유 구성) 클릭 후 UAC 승인
4. 교사: "刷新学生机"(학생 새로고침) 클릭. 목록이 비어 있으면 "全段扫描"(전체 검색) 클릭
5. 학생 행의 "打开"(열기)를 클릭하여 공유 폴더 열기

D: 드라이브가 없으면 `setup-share.bat`과 `app.hta` 양쪽에서 `D:\lan-share`를 실제 경로로 변경하세요.

## 화면

| 교사용 | 학생용 |
|---|---|
| ![](docs/screenshots/teacher.png) | ![](docs/screenshots/student.png) |

## 더 보기

- [자주 묻는 질문 27개 (중국어)](docs/QRA.txt)
- [보안 안내](docs/SECURITY.md)
- [빌드 방법](BUILD.md)

## 기술 노트

검색은 로컬 ARP 테이블을 읽습니다(레이어 2, Windows 서비스와 무관). ARP가 비어 있으면 전체 서브넷 ping 스캔(254개 주소, 32개 병렬, 약 4초)으로 채웁니다. ping은 ARP 테이블을 채우기 위한 것일 뿐 ICMP 응답을 기다리지 않습니다.

UI는 기본 제공 `mshta.exe`가 렌더링하는 HTA(IE8 호환 모드)입니다. 모든 소스는 평문 HTML + JScript이며 직접 감사할 수 있습니다.

## 라이선스

MIT
