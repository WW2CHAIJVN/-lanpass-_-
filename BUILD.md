# 构建说明

本项目是**纯源码 + 零依赖**的形态。没有编译过程——所谓"构建"只是把 EXE 打出来而已。

---

## 源码怎么直接运行

**不需要装任何东西**，双击这两个之一即可：

| 文件 | 角色 |
|------|------|
| 启动教师端.bat | 教师端（父级主机） |
| 启动学生端.bat | 学生端（子级主机） |

或者手动：

```bat
mshta.exe "app.hta" teacher
mshta.exe "app.hta" student
```

> 注意：所有文件必须在**同一目录**。`app.hta` 通过相对路径加载 `bg-student.jpg`、`panel-dark.png`、`setup-share.bat`、`autostart.bat`，移动文件会破坏路径。

---

## 文件作用

| 文件 | 作用 |
|------|------|
| `app.hta` | 主程序。双端共用，靠命令行参数区分角色 |
| `setup-share.bat` | 一键配置共享 + 跨版本互访修复 |
| `autostart.bat` | 开机自启设置（接收 teacher / student 参数） |
| `install.bat` | EXE 自解压后的安装逻辑 |
| `blk-guard.bat` | 防装拦截（可选，可删） |
| `blk-guard-undo.bat` | 撤销防装拦截 |
| `bg-student.jpg` | 学生端深色主题背景 |
| `panel-dark.png` | 学生端半透明卡片纹理（4×4） |

---

## 怎么构建 EXE

EXE 是用 **Windows 自带的 IExpress** 打包的，不需要 Visual Studio、不需要编译器。

### 方法一：用仓库里的脚本

```bat
tools\打包发行版.bat
```

产物在 `dist\`。

### 方法二：手动用 IExpress

1. 运行 `iexpress.exe`（Win+R 输入即可）
2. 选择 **Create new Self Extraction Directive file**
3. 选择 **Extract files and run an installation command**
4. 包标题随意，**不提示**，**不显示许可协议**
5. 安装程序填：`cmd /c install.bat teacher`（教师版）或 `student`（学生版）
6. 选择 **Store files using Long File Name inside Package**
7. **不重启**
8. 不保存 SED
9. 添加文件：`app.hta`、`setup-share.bat`、`autostart.bat`、`README.txt`、`install.bat`、`bg-student.jpg`、`panel-dark.png`、`QRA.txt`、`blk-guard.bat`、`blk-guard-undo.bat`
10. 隐藏解压动画、不显示完成消息
11. 输出文件名：`教师端.exe` / `学生端.exe`
12. 选择 **No restart**
13. 保存 SED（可选，方便下次）

两种方法产出完全一致。

---

## 发布新版本

```bat
tools\打包发行版.bat 1.1.0
```

生成 `dist\lanpass-v1.1.0.zip` + SHA256。

如果需要自动上传到 GitHub Release（需先装 [gh](https://cli.github.com) 并 `gh auth login`）：

```bat
tools\发布到GitHub.bat 1.1.0
```

---

## 为什么不用编译器

项目的硬约束是**在机房老机器上零安装运行**：

- 不需要 .NET（任何版本）
- 不需要 VC++ 运行库
- 不需要 Java / Python / Node
- 不需要任何第三方 DLL

达到这个约束的最低成本方案，就是用系统自带的 `mshta.exe` 当界面容器，用批处理做系统操作。代价是 UI 能力受限于 IE8 引擎，收益是一个 U 盘拷过去就能跑。

---

## 源码结构

```text
lanpass/
├── app.hta                 主程序（HTML + JScript，明文可读）
├── setup-share.bat         共享配置
├── autostart.bat           开机自启
├── install.bat             EXE 安装逻辑
├── blk-guard.bat           防装拦截（可选）
├── blk-guard-undo.bat      撤销拦截
├── 启动教师端.bat           绿色版入口
├── 启动学生端.bat           绿色版入口
├── bg-student.jpg          学生端背景
├── panel-dark.png          学生端纹理
├── README.md               项目说明
├── LICENSE                 MIT
├── BUILD.md                本文件
├── docs/
│   ├── QRA.txt             常见问题 27 条
│   ├── SECURITY.md         安全说明
│   └── screenshots/        界面截图
└── tools/
    ├── build-release.ps1   打包脚本
    ├── publish-release.ps1 发布脚本
    ├── 打包发行版.bat
    └── 发布到GitHub.bat
```

---

## 验证

改完代码后，最快的验证方式：

1. 双击 `启动教师端.bat`
2. 看界面是否正常显示（不该有脚本错误弹框）
3. 点「配置共享」，确认无报错
4. 点「刷新学生机」，确认列表能出来

浏览器开发者工具用不上（HTA 不是浏览器环境），出错时会弹 Windows 脚本错误对话框，里面有行号。
