# lanpass

[简体中文](README.md) | [English](README.en.md) | **日本語** | [한국어](README.ko.md) | [Русский](README.ru.md) | [Español](README.es.md) | [Français](README.fr.md)

> ホームグループが消え、ネットワーク検出が無効になり、ゲストアクセスが既定で拒否されても — lanpass は Windows 7 / 10 / 11 が互いを認識できるようにします。

<img src="https://img.shields.io/badge/Windows-7%20%7C%2010%20%7C%2011-0078D6?style=flat-square&logo=windows&logoColor=white" alt="Platform">
<img src="https://img.shields.io/badge/License-MIT-3DA639?style=flat-square" alt="License">
<img src="https://img.shields.io/badge/dependencies-zero-success?style=flat-square" alt="Dependencies">

## 問題

学校のPC教室：数十台のPC、同じスイッチ、同じサブネット。しかし「ネットワーク」に何も表示されない。

原因は二層あります。

**表層**：ホームグループは Windows 7 で導入され、**Windows 10 1803 で削除**されました。Win7 と Win10/11 に共通の仕組みはありません。

**根本原因**：Windows 10 1709 以降、`AllowInsecureGuestAuth` の既定値は 0 です。Win10/11 は匿名 SMB アクセスをすべて拒否します。ホームグループを迂回して IP で直接接続しても、*「組織のセキュリティ ポリシーにより、認証されていないゲスト アクセスがブロックされています」* と表示されます。

**ホームグループだけを直しても意味がありません。妨げているのは SMB 認証です。**

## 機能

| | |
|---|---|
| **依存関係ゼロ** | 標準の `mshta` / `cmd` / `net` / `ping` / `arp` のみ。.NET、VC++ ランタイム、Java、Python、Node は不要 |
| **検出サービス不要** | ホームグループ、ネットワーク検出、Computer Browser、SSDP、DNS がすべて停止しても動作 |
| **クロスバージョン** | Win7 / Win10 / Win11 の双方向 |
| **2つの役割** | 教師用はクラス全体を管理、学生用はワンクリック提出 |
| **認証の自動修正** | ゲストアクセスの制限を解除する 4 つのレジストリ値を書き込み |
| **アクティブ検出** | ARP テーブル + 全サブネット ping スキャン、システムサービス不要 |
| **デバイス記憶** | デバイス一覧をキャッシュ、次回起動時は即座に表示 |
| **低負荷** | メモリ 34 MB、アイドル時 CPU 0%、ポーリングなし |

## クイックスタート

1. フォルダを各PCにコピー
2. 教師PC：`教师端.exe` を実行、学生PC：`学生端.exe` を実行
3. 「配置共享」（共有設定）をクリックし、UAC を承認
4. 教師：「刷新学生机」（学生更新）をクリック。空の場合は「全段扫描」（全走査）をクリック
5. 学生の行の「打开」（開く）をクリックして共有フォルダを開く

D: ドライブがない場合は、`setup-share.bat` と `app.hta` の両方で `D:\lan-share` を実在するパスに変更してください。

## 画面

| 教師用 | 学生用 |
|---|---|
| ![](docs/screenshots/teacher.png) | ![](docs/screenshots/student.png) |

## 詳細

- [よくある質問 27 項目（中国語）](docs/QRA.txt)
- [セキュリティについて](docs/SECURITY.md)
- [ビルド手順](BUILD.md)

## 技術メモ

検出はローカルの ARP テーブルを読みます（レイヤ2、Windows サービスに依存しません）。ARP が空の場合は全サブネット ping スキャン（254 アドレス、32 並列、約 4 秒）で埋めます。ping は ARP テーブルを埋めるためだけに使い、ICMP の応答は待ちません。

UI は標準の `mshta.exe` が描画する HTA（IE8 互換モード）です。ソースはすべて平文の HTML + JScript で、そのまま監査できます。

## ライセンス

MIT
