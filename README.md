<p align="center">
  <img src="docs/images/SIMer.png" width="128" height="128" alt="SIMer Logo" />
</p>

<h1 align="center">SIMer</h1>

<p align="center">
  <strong>完全离线的 SIM 卡与 eSIM 信息管理应用</strong><br>
  简体中文 · English<br>
  Apple Wallet 风格的卡片交互，为多卡用户、海外保号卡玩家和 eSIM 爱好者打造。
</p>

<p align="center">
  <a href="https://github.com/xiaoxizi-lyx/SIMer/actions/workflows/ci.yml"><img src="https://github.com/xiaoxizi-lyx/SIMer/actions/workflows/ci.yml/badge.svg" alt="SIMer CI" /></a>
  <img src="https://img.shields.io/badge/Flutter-3.47.9-02569B?logo=flutter&logoColor=white" alt="Flutter 3.47.9" />
  <img src="https://img.shields.io/badge/Android-7.0%2B-3DDC84?logo=android&logoColor=white" alt="Android 7.0+" />
  <img src="https://img.shields.io/badge/Database-SQLite-003B57?logo=sqlite&logoColor=white" alt="SQLite" />
  <img src="https://img.shields.io/badge/Privacy-100%25%20Offline-green" alt="100% Offline" />
  <img src="https://img.shields.io/badge/License-MIT-blue.svg" alt="License: MIT" />
</p>

---

## ✨ 核心特性

- 📇 **钱包风格卡片**：渐变拟物卡片，点击沿 Y 轴 3D 翻转，正面看摘要，背面看完整信息。
- 📱 **实体 SIM 与 eSIM 全字段记录**：ICCID（等宽分组显示）、多个号码、运营商、国家/地区、来源渠道和备注；流量、通话、短信与话费余额；通话、短信、数据、VoLTE、Wi-Fi Calling、热点共享、eSIM 转移、国际漫游等功能的支持情况。
- 📷 **eSIM 激活码识别**：相机扫码、从相册截图识别或粘贴激活码文本，按 GSMA SGP.22 规范解析 `LPA:1$<SM-DP+ 地址>$<Matching ID>[$<SM-DP+ OID>[$<确认码要求标志>]]`。确认码不包含在二维码中，需要时应用会提醒你手动填写。可一键复制完整激活码，也可以把保存的激活码重新显示为二维码，在另一台设备上扫码安装。
- ⏳ **三种有效期模式**：
  - **固定到期日**：适合按期充值续订的卡，到期当天仍算有效。
  - **滚动有效期（N 天内需使用一次）**：适合 giffgaff 等需要定期使用才能保号的卡。即将到期或已过期时，在卡片上点「我已使用」即可续期，支持撤销。
  - **无期限**：长期有效的卡。
- 🔔 **到期提醒**：为每张卡预约系统通知（提前 N 天、到期当天、过期次日），可设置提醒时间。不需要后台常驻，重启手机后自动恢复；点击通知直接打开对应卡片。
- 🌍 **预置运营商**：内置 16 个国家和地区的 59 家常见运营商及其品牌色；自定义运营商会自动分配不冲突的颜色。
- 🏷️ **标签、筛选与搜索**：自定义标签；按状态（激活 / 未激活 / 即将到期 / 已过期，显示数量）、国家/地区、运营商和标签筛选；搜索运营商、号码、ICCID、国家名、标签、SM-DP+ 地址、来源和备注，号码与 ICCID 忽略空格和分隔符；按添加时间、到期时间、运营商或国家/地区排序。
- 🗃️ **归档**：暂时不用的卡可以归档，之后恢复或彻底删除。
- 🔒 **应用锁与防窥**：用指纹、面容或设备密码解锁；离开应用超过设定时间（立即 / 30 秒 / 1 分钟 / 5 分钟）后自动重新上锁，锁屏覆盖所有页面和弹窗；「防窥保护」在最近任务中隐藏应用内容；ICCID、eSIM 激活码与确认码默认打码显示，点击眼睛图标才显示完整内容。
- 💾 **加密备份与恢复**：导出时默认用密码加密（AES-256-GCM），保存到文件或分享；导入前可预览内容并选择如何处理重复的卡片；兼容 1.x 与 2.0 导出的备份。
- 🌐 **中英文界面**：跟随系统语言，也可以在设置中固定为简体中文或 English。
- 🌙 **深浅色主题**：浅色米白（#FAF8F5）、深色深灰（#1C1C1E），可跟随系统；适配大字体和系统「移除动画」设置。

---

## 🛡️ 隐私与安全

SIMer 是纯本地应用：没有账户、没有服务器，也没有统计、崩溃上报或广告 SDK。

- **系统层面禁止联网**：正式版安装包不申请 `INTERNET` 权限，Android 不允许它建立任何网络连接。CI 会检查每个发布的安装包，一旦带有该权限就构建失败。字体随应用内置；二维码识别使用打包在应用内的 Google ML Kit 模型，在本机离线运行。
- **不参与系统备份和换机迁移**：关闭了 Android 云备份和设备间迁移（`allowBackup="false"` 加 `dataExtractionRules`），数据不会在你不知情的情况下被复制到其他地方。
- **数据只由你带走**：换机时，在「设置 → 导出备份」中手动导出，自己把文件传到新设备，再「导入备份」。
- **备份默认加密**：导出时设置的密码经 PBKDF2-HMAC-SHA512（21 万次迭代）派生密钥，再用 AES-256-GCM 加密整份备份；密码错误或文件被改动时无法解密。请牢记密码，忘记后无法恢复。也可以选择导出未加密的明文 JSON，其中包含 ICCID、号码、eSIM 激活码等敏感信息，请妥善保管、用完及时删除。通过「分享」导出时生成的临时文件会在下次导出或下次启动时自动清理。

正式版安装包申请的权限：

| 权限 | 用途 |
| --- | --- |
| `CAMERA` | 扫描 eSIM 二维码；拒绝后仍可用相册识别或粘贴激活码 |
| `USE_BIOMETRIC`、`USE_FINGERPRINT` | 应用锁的指纹 / 面容验证 |
| `POST_NOTIFICATIONS` | 到期提醒通知 |
| `RECEIVE_BOOT_COMPLETED` | 重启手机后恢复已预约的提醒 |
| `VIBRATE` | 提醒通知振动 |
| `ACCESS_NETWORK_STATE` | 由扫码组件（ML Kit）引入，只能查询是否有网络，不能联网 |

> 调试版（`flutter run`）保留了网络权限，用于热重载；只有正式版是离线的。

---

## 📦 下载与安装

在 [Releases](https://github.com/xiaoxizi-lyx/SIMer/releases) 页面下载对应设备的安装包，需要 Android 7.0 及以上：

| 安装包 | 适用设备 |
| --- | --- |
| `SIMer-v<版本>-arm64-v8a.apk` | 绝大多数 Android 手机（推荐） |
| `SIMer-v<版本>-armeabi-v7a.apk` | 较旧的 32 位 ARM 设备 |
| `SIMer-v<版本>-x86_64.apk` | x86_64 平板、模拟器与 ChromeOS |

每个版本都附有 `SHA256SUMS.txt`，可以校验下载的安装包是否完整：

```bash
sha256sum -c SHA256SUMS.txt --ignore-missing
```

### 核验签名

校验和只能说明文件下载完整，核对签名证书才能确认安装包出自本项目。2.0 起的所有正式版都使用同一个证书，信息如下（可以整段粘贴到 [AppVerifier](https://github.com/soupslurpr/AppVerifier) 中核对已安装的应用）：

```text
io.github.xiaoxizi_lyx.simer
62:CC:31:FE:51:C5:A8:C6:35:E1:BC:19:37:28:7D:DD:6B:BD:DF:02:11:E8:73:74:69:0D:C5:22:8B:7D:52:23
```

也可以用 Android SDK 中的 `apksigner` 查看安装包，输出中 `certificate SHA-256 digest` 后面是同一串指纹（小写、不带冒号）：

```bash
apksigner verify --print-certs SIMer-v<版本>-arm64-v8a.apk
```

指纹不一致时请不要安装。

### 从 1.x 升级

2.0 起应用包名改为 `io.github.xiaoxizi_lyx.simer`，并开始使用固定的正式签名，因此**不能覆盖安装 1.x**（1.x 的安装包使用临时调试签名，本来也无法覆盖升级）。安装 2.0 后，桌面上会同时出现新旧两个 SIMer，请按以下步骤迁移数据：

1. 打开旧版 SIMer，在「设置 → 导出数据」中导出 JSON 备份，通过分享面板保存到「文件」或发给自己。
2. 打开 2.0，在「设置 → 导入备份」中选择这个文件，确认预览内容后导入。
3. 核对卡片和标签无误后卸载旧版。旧版的包名是 `com.simkeeper.sim_keeper`，可以在系统「设置 → 应用」中区分。
4. 删除导出的备份文件。

从 2.0 起，之后的版本都可以直接覆盖升级，数据会保留。

---

## 🛠️ 技术栈

| 模块 | 实现 |
| --- | --- |
| 框架 | Flutter 3.47.9 / Dart 3.13 |
| 状态管理 | `provider` |
| 本地数据库 | `sqflite`（SQLite，按版本迁移） |
| 扫码 | `mobile_scanner`（Google ML Kit，模型随应用内置） |
| 应用锁 | `local_auth`（Android `BiometricPrompt`，配合 `FlutterFragmentActivity`） |
| 到期提醒 | `flutter_local_notifications` + `timezone`（系统预约通知） |
| 备份导入导出 | `file_picker`（系统存储访问框架）、`share_plus` |
| 备份加密 | `cryptography`（纯 Dart 的 AES-256-GCM 与 PBKDF2） |
| 二维码生成 | `qr`（纯 Dart） |
| 界面文案 | `flutter_localizations` + `gen-l10n`（`lib/l10n/*.arb`） |
| 偏好设置 | `shared_preferences` |
| 测试 | `flutter_test`、`sqflite_common_ffi`、`integration_test`（Android 模拟器） |

---

## 📂 项目结构

```text
SIMer/
├── android/              # Android 工程：签名配置、正式版去除网络权限的清单
├── assets/fonts/         # 内置字体（Inter、Roboto Mono）及其 OFL 许可证
├── docs/                 # README 图片与发布流程（RELEASING.md）
├── lib/
│   ├── data/             # 预置运营商与国家/地区数据
│   ├── database/         # SQLite 数据库、迁移与备份导入
│   ├── l10n/             # 界面文案（app_zh.arb 为模板、app_en.arb）与生成的代码
│   ├── models/           # 领域模型（SimCard、CalendarDate、FeatureSet、Tag、Carrier 等）
│   ├── providers/        # 状态管理（卡片、筛选、主题、语言、应用锁、提醒）
│   ├── screens/          # 页面：首页、添加/编辑表单（sim_form/）、扫码、设置、标签、归档、锁屏
│   ├── services/         # 激活码解析、备份编解码与加密、导入导出、提醒规划与通知、生物识别、平台通道
│   ├── theme/            # 颜色、字体与主题
│   └── widgets/          # 卡片正反面、翻转、倒计时、筛选栏、二维码等组件
├── integration_test/     # 在 Android 设备 / 模拟器上运行完整应用的测试
└── test/                 # 单元测试与组件测试
```

---

## 🚀 本地开发

### 前置要求

- [Flutter SDK](https://docs.flutter.dev/get-started/install) **3.47.9**（stable 渠道，与 CI 一致）
- Android SDK，JDK 17 或更高版本

### 运行与检查

```bash
git clone https://github.com/xiaoxizi-lyx/SIMer.git
cd SIMer
flutter pub get
flutter run
```

调试版的包名是 `io.github.xiaoxizi_lyx.simer.debug`，桌面上显示为「SIMer Debug」，可以和正式版同时安装，不会影响正式版的数据。

提交前请确保以下检查全部通过（CI 会执行同样的检查）：

```bash
dart format --output=none --set-exit-if-changed lib test integration_test
flutter analyze
flutter test
```

连接 Android 手机或启动模拟器后，可以运行在真实系统上启动完整应用的集成测试（CI 会在模拟器上运行）：

```bash
flutter test integration_test
```

修改界面文字时，编辑 `lib/l10n/app_zh.arb`（模板）和 `lib/l10n/app_en.arb`，然后运行 `flutter gen-l10n` 并把生成的代码一起提交。

### 构建安装包

```bash
flutter build apk --release --split-per-abi
```

没有配置签名时，本地 release 构建会使用调试签名，只能自己测试，不能分发。正式签名和发布流程见 [docs/RELEASING.md](docs/RELEASING.md)。

| 构建 | 包名 | 桌面名称 |
| --- | --- | --- |
| 正式版（推送 `v*` 标签时由 CI 构建） | `io.github.xiaoxizi_lyx.simer` | SIMer |
| CI 测试包（PR 与 `main`，在 Actions 的 Artifacts 中下载） | `io.github.xiaoxizi_lyx.simer.ci` | SIMer CI |
| 调试版（`flutter run`） | `io.github.xiaoxizi_lyx.simer.debug` | SIMer Debug |
| profile 版（`flutter run --profile`） | `io.github.xiaoxizi_lyx.simer.profile` | SIMer Profile |

后三种都可以和正式版同时安装，数据各自独立。

---

## 📄 开源许可

本项目基于 [MIT License](LICENSE) 开源。内置字体 [Inter](assets/fonts/OFL-Inter.txt) 与 [Roboto Mono](assets/fonts/OFL-RobotoMono.txt) 采用 SIL Open Font License 1.1。

应用图标中的 Android 机器人形象复制或修改自 Google 创作并分享的作品，依据[知识共享署名 3.0 许可协议](https://creativecommons.org/licenses/by/3.0/)使用（The Android robot is reproduced or modified from work created and shared by Google and used according to terms described in the Creative Commons 3.0 Attribution License）。
