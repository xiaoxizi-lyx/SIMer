<p align="center">
  <img src="assets/images/SIMer.png" width="128" height="128" alt="SIMer Logo" />
</p>

<h1 align="center">SIMer</h1>

<p align="center">
  <strong>现代化、优雅的 SIM 卡与 eSIM 卡信息记录管理应用</strong><br>
  灵感汲取自 Apple Wallet 风格卡片交互，专为多卡用户、海外漫游卡玩家及 eSIM 爱好者打造。
</p>

<p align="center">
  <a href="https://github.com/xiaoxizi-lyx/SIMer/actions"><img src="https://github.com/xiaoxizi-lyx/SIMer/actions/workflows/ci.yml/badge.svg" alt="SIMer CI" /></a>
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Platform-Android-3DDC84?logo=android&logoColor=white" alt="Android" />
  <img src="https://img.shields.io/badge/Database-SQLite-003B57?logo=sqlite&logoColor=white" alt="SQLite" />
  <img src="https://img.shields.io/badge/Privacy-100%25%20Offline-green" alt="Offline First" />
  <img src="https://img.shields.io/badge/License-MIT-blue.svg" alt="License" />
</p>

---

## ✨ 核心特性

- 📇 **Apple Wallet 风格卡片**：拟物感卡片流光渐变视觉，支持丝滑流畅的 **3D 沿 Y 轴翻转动画**，正反面分层查看摘要与完整技术细节。
- 📱 **物理 SIM 与 eSIM 兼顾**：全字段记录 ICCID（等宽卡号排版）、多手机号、运营商名称、归属国家/地区、SIM 来源及备注。
- 📷 **LPA 智能扫码解析**：原生集成相机扫描器，精准解析 eSIM 的 LPA 格式二维码（`LPA:1$<SM-DP+>$<MatchingID>[$<ConfirmCode>]`），一键自动填充。
- ⏳ **灵活的多模式有效期管理**：
  - **固定到期日**：适用于充值按期续订卡。
  - **滚动有效期（N 天一用）**：针对英国 Giffgaff、新西兰 One NZ 等需定期活跃的保号卡，到期前倒计时预警，支持在卡片上点击“✅ 我已使用”一键按周期顺延。
  - **无期限**：适用于长期有效卡。
- 🌍 **丰富的预置运营商**：内置覆盖 20+ 国家地区、55+ 常见运营商的专属品牌主色调；若用户自定义添加未收录运营商，系统将从美观调色盘中动态分配互不冲突的主题色。
- 🏷️ **标签管理与多维筛选**：支持用户自定义标签分类，支持按卡片状态（激活/未激活/已过期）、国家地区、运营商及标签快速筛选，配备全文模糊搜索与动态排序。
- 🔒 **生物识别安全锁**：原生接入 Android `BiometricPrompt`（指纹识别 / 面容识别），提供私密凭据安全门控。
- 💾 **本地离线优先与数据备份**：
  - 数据持久化保存在本地 SQLite 数据库，无任何后台隐式网络上报。
  - 支持全量导出为格式化 JSON 文件，并支持随时导入（支持 UUID 自动排重）。
- 🌙 **深浅色自适应主题**：浅色模式选用舒适米白质感（#FAF8F5），深色模式选用细腻深灰（#1C1C1E），告别纯黑刺眼。

---

## 🛠️ 技术栈

| 模块 | 实现方案 |
| --- | --- |
| 跨平台框架 | **Flutter** (Dart 3.x) |
| 状态管理 | **Provider** (MVVM 风格) |
| 本地数据库 | **SQLite** (`sqflite` 事务与级联存储) |
| 扫码组件 | **Mobile Scanner** (`mobile_scanner`) |
| 安全认证 | **Local Auth** (`local_auth` + `FlutterFragmentActivity`) |
| 后台保活与提醒 | `flutter_local_notifications` + `workmanager` |
| 持久化偏好 | `shared_preferences` |

---

## 📂 项目结构规范

```text
sim_keeper/
├── android/            # Android 原生平台配置与清单
├── assets/
│   └── images/         # 品牌与高清图标资源 (SIMer.png)
├── lib/
│   ├── data/           # 静态数据源 (55+ 运营商预置色、70+ 国家Emoji)
│   ├── database/       # SQLite Helper 与数据结构事务处理
│   ├── models/         # 核心领域实体 (SimCard, FeatureSet, Tag, Carrier, Enums)
│   ├── providers/      # 状态管理层 (SimCardProvider, FilterProvider, ThemeProvider, AuthProvider)
│   ├── screens/        # 各业务页面 (首页、表单、LPA扫码、设置、标签管理、归档回收站、锁屏)
│   ├── services/       # 业务服务层 (二维码解析、备份导入导出、本地通知、生物识别)
│   ├── theme/          # 调色盘、组件样式与全局主题定义
│   └── widgets/        # 卡片正面/背面/3D翻转等可复用组件
└── test/               # 核心服务与业务模型单元测试
```

---

## 🚀 编译与本地运行

### 前置要求

- 安装 [Flutter SDK](https://docs.flutter.dev/get-started/install) (>= 3.2.0)
- Android SDK (推荐 Build-Tools 34+)

### 启动运行

1. 克隆代码仓库：
   ```bash
   git clone git@github.com:xiaoxizi-lyx/SIMer.git
   cd SIMer
   ```

2. 安装依赖：
   ```bash
   flutter pub get
   ```

3. 运行项目（调试模式）：
   ```bash
   flutter run
   ```

4. 构建 Android APK：
   ```bash
   flutter build apk --release
   ```

---

## 🛡️ 隐私与安全声明

1. **零网络追踪**：SIMer 是完全基于本地运行的单机记录工具，没有用户账户体系，不收集、不上传任何个人通讯凭据、ICCID 或网络流量。
2. **敏感信息提示**：在进行 JSON 明文导出与备份分享时，请妥善保管导出的文件，防止包含未激活 eSIM 确认码及卡号的信息外泄。

---

## 📄 开源许可证

本项目基于 [MIT License](LICENSE) 开源。
