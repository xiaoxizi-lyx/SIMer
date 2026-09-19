# 贡献指南 (Contributing to SIMer)

感谢你对 SIMer 的关注与支持！我们欢迎社区贡献者参与改进项目，无论是提交 Issue 汇报问题、提出改进意见，还是提交代码合并请求（Pull Request）。

---

## 🛠️ 本地开发环境配置

1. **安装必要工具**：
   - [Flutter SDK](https://docs.flutter.dev/get-started/install) (>= 3.2.0)
   - Android Studio 或 VS Code（配合 Flutter & Dart 插件）
   - Android SDK (推荐使用 Platform 34+)

2. **克隆仓库**：
   ```bash
   git clone https://github.com/xiaoxizi-lyx/SIMer.git
   cd SIMer
   ```

3. **获取依赖**：
   ```bash
   flutter pub get
   ```

4. **运行测试**：
   ```bash
   flutter test
   ```

5. **代码静态检查**：
   ```bash
   flutter analyze
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
   - 运行 `flutter analyze` 确保无 Lint 告警。
   - 运行 `flutter test` 确保所有单元测试通过。
   - 若引入了新功能或修复了 Bug，请补充相应的测试用例。
4. **推送到远程并提交 Pull Request**：
   - 清晰描述修改动机、方案及自测结果。
   - 关联对应的 Issue（如 `Fixes #12`）。
5. **等待 Code Review** 并根据反馈及时修正代码。

---

## 🛡️ 隐私与安全准则

SIMer 是一个 **100% 离线、零网络上报** 的隐私优先应用。在提交 PR 时请严格遵守以下红线：
1. **禁止引入任何隐式网络上报、遥测追踪（Analytics）或广告 SDK**。
2. **严禁将测试用的真实电话号码、ICCID、激活码等个人数据提交至仓库**。
3. 若需新增第三方依赖，请先在 Issue 中说明必要性与安全性评估。
