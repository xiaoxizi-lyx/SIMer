# 贡献指南 (Contributing to SIMer)

感谢你对 SIMer 的关注与支持！我们欢迎社区贡献者参与改进项目，无论是提交 Issue 汇报问题、提出改进意见，还是提交代码合并请求（Pull Request）。

---

## 🛠️ 本地开发环境配置

1. **安装必要工具**：
   - [Flutter SDK](https://docs.flutter.dev/get-started/install) **3.47.9**（stable 渠道，与 CI 使用的版本一致）
   - Android Studio 或 VS Code（配合 Flutter & Dart 插件）
   - Android SDK，JDK 17 或更高版本

2. **克隆仓库**：
   ```bash
   git clone https://github.com/xiaoxizi-lyx/SIMer.git
   cd SIMer
   ```

3. **获取依赖**（按 `pubspec.lock` 锁定的版本安装）：
   ```bash
   flutter pub get --enforce-lockfile
   ```

4. **格式检查**：
   ```bash
   dart format --output=none --set-exit-if-changed lib test
   ```

5. **代码静态检查**（`analysis_options.yaml` 启用了严格模式，要求零告警）：
   ```bash
   flutter analyze
   ```

6. **运行测试**：
   ```bash
   flutter test
   ```

---

## 📋 提交规范 (Commit Guidelines)

我们推荐遵循 [Conventional Commits](https://www.conventionalcommits.org/) 规范编写提交信息：

```text
<type>(<scope>): <subject>

<body>
```

- **feat**: 新增功能（Feature）
- **fix**: 修复 Bug
- **docs**: 仅文档相关修改
- **style**: 格式化、缺失分号等代码风格变动（不影响代码逻辑）
- **refactor**: 代码重构（既不是新增功能也不是修复 Bug）
- **test**: 新增或修改测试代码
- **chore**: 构建工具、脚本、依赖更新等杂项

*示例：*
```text
feat(scanner): integrate QrParserService for robust LPA QR parsing
fix(models): resolve expiration calculation bug on day-of-expiry
```

---

## 🔀 Pull Request 流程

1. **Fork 本仓库** 到个人 GitHub 账号。
2. **基于 `main` 分支拉取新的特性分支**：
   ```bash
   git checkout -b feat/your-feature-name
   ```
3. **完成代码编写并确保本地检查通过**：
   - 运行 `dart format lib test` 格式化代码。
   - 运行 `flutter analyze` 确保无 Lint 告警。
   - 运行 `flutter test` 确保所有测试通过。
   - 若引入了新功能或修复了 Bug，请在 `test/` 下补充相应的测试用例（数据库相关测试使用 `sqflite_common_ffi`，参考 `test/support/test_db.dart`）。
   - 涉及界面的改动，请附上截图（浅色与深色模式）。
   - 需要在手机上试用时，可以下载 PR 的 CI 测试包（Actions → 本次运行 → Artifacts → `ci-test-apks`）。它的包名带 `.ci` 后缀，可以和正式版同时安装，不会影响正式版的数据。
4. **推送到远程并提交 Pull Request**：
   - 清晰描述修改动机、方案及自测结果。
   - 关联对应的 Issue（如 `Fixes #12`）。
5. **等待 Code Review** 并根据反馈及时修正代码。

---

## 🛡️ 隐私与安全准则

SIMer 是一个 **100% 离线、零网络上报** 的隐私优先应用。在提交 PR 时请严格遵守以下红线：
1. **禁止引入任何网络通信、遥测追踪（Analytics）、崩溃上报或广告 SDK**。正式版安装包不得包含 `INTERNET` 权限，CI 会检查每个安装包，带有该权限即失败。
2. **禁止开启系统备份或换机迁移**：保持 `android:allowBackup="false"` 与 `data_extraction_rules.xml` 排除所有数据。数据只能由用户手动导出。
3. **严禁将真实的电话号码、ICCID、eSIM 激活码等个人数据提交至仓库**，测试数据请使用明显虚构的值。
4. 不要提交签名密钥（`*.jks`、`key.properties`），发布签名只保存在 GitHub Secrets 中，详见 [docs/RELEASING.md](docs/RELEASING.md)。
5. 若需新增第三方依赖，请先在 Issue 中说明必要性与安全性评估，并确认它不会引入网络权限或后台服务。
