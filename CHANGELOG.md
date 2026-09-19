# 更新日志 (Changelog)

本项目遵循 [Semantic Versioning (语义化版本 2.0.0)](https://semver.org/lang/zh-CN/) 以及 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/) 规范。

---

## [1.0.1] - 2026-09-19

### 优化与规范化 (Standardization & Improvements)
- **CI/CD**：集成 GitHub Actions 自动化工作流（代码静态分析、单元测试、Android Release APK 自动构建）。
- **数据备份**：完整打通 JSON 备份导出与导入，支持通过 `file_picker` 自由选择备份文件，并与 Provider 数据状态深度联动。
- **提醒调度**：应用启动时正式接入 WorkManager 定时检查与到期预警后台任务。
- **扫码重构**：扫码页面深度对接 `QrParserService`，统一 LPA 二维码解析逻辑与容错回退机制。
- **日期计算**：修复卡片在当天过期时的整除截断判定偏差，采用时间戳精确判定。
- **测试修复**：重构并扩充单元测试用例，覆盖模型边界计算、序列化及二维码解析。
- **社区建设**：补充 `CONTRIBUTING.md`、Issue / PR 模板及 Gradle Wrapper 版本追踪支持。

---

## [1.0.0] - 2026-09-19

### 初始发布 (Initial Release)
- **卡片管理**：Apple Wallet 风格拟物卡片，支持 3D 沿 Y 轴翻转，正反面查看卡片摘要与技术参数。
- **双模支持**：支持物理 SIM 卡与 eSIM 卡信息的全字段记录（ICCID、多号码、运营商、归属地等）。
- **LPA 扫码**：原生集成相机扫码，精准识别与解析 eSIM LPA 激活信息。
- **有效期追踪**：提供固定到期日、滚动周期（N天一用）及无期限三种模式，卡片支持“✅ 我已使用”快捷打卡。
- **运营商配色**：预置全球 20+ 国家和地区、55+ 主流运营商主题色，支持未收录运营商智能颜色分配。
- **安全锁定**：接入 Android 生物识别（指纹与面容）安全锁屏门禁。
- **本地存储**：数据全量存储于 SQLite 本地数据库，无后台网络追踪。
