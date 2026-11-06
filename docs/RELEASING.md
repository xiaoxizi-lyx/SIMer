# 发布流程（维护者）

SIMer 的正式安装包由 GitHub Actions 在推送 `v*` 标签时构建、签名并发布到 GitHub Releases。
**所有版本必须使用同一个正式签名密钥**，否则用户无法覆盖升级（只能卸载重装，本地数据会丢失）。

## 一、首次配置：生成签名密钥并添加 Secrets（只需做一次）

### 1. 在本地生成 keystore

```bash
keytool -genkeypair -v -keystore simer-release.jks -storetype PKCS12 -keyalg RSA -keysize 4096 -validity 10000 -alias simer
```

按提示设置密码并填写证书信息（姓名、组织等可随意填写）。
PKCS12 格式的密钥库中，**密钥密码与密钥库密码相同**。

> ⚠️ 请把 `simer-release.jks` 与密码备份到安全的位置（例如密码管理器）。
> 一旦丢失，之后发布的版本将无法覆盖升级已安装的版本。
> 不要把 keystore 提交到仓库（`.gitignore` 已忽略 `*.jks`）。

### 2. 把 keystore 转成 Base64

```bash
base64 -w 0 simer-release.jks > simer-release.jks.base64
```

- macOS：`base64 -i simer-release.jks -o simer-release.jks.base64`
- Windows PowerShell：`[Convert]::ToBase64String([IO.File]::ReadAllBytes("$PWD\simer-release.jks")) | Set-Content simer-release.jks.base64`

`keytool` 随 JDK 提供；没有单独安装 JDK 时，可以使用 Android Studio 自带的
（macOS 在 `/Applications/Android Studio.app/Contents/jbr/Contents/Home/bin/`，Windows 在 `C:\Program Files\Android\Android Studio\jbr\bin\`）。

### 3. 在 GitHub 仓库中添加 4 个 Secrets

进入仓库 **Settings → Secrets and variables → Actions → New repository secret**，逐个添加：

| Secret 名称 | 内容 |
| --- | --- |
| `SIMER_KEYSTORE_BASE64` | 第 2 步生成的 `simer-release.jks.base64` 文件的全部内容（一整行） |
| `SIMER_KEYSTORE_PASSWORD` | 生成 keystore 时设置的密码 |
| `SIMER_KEY_ALIAS` | `simer`（即上面命令中 `-alias` 的值） |
| `SIMER_KEY_PASSWORD` | 与 `SIMER_KEYSTORE_PASSWORD` 相同 |

添加完成后可删除本地的 `.base64` 文件。

## 二、每次发布

1. 修改 `pubspec.yaml` 中的版本号，例如 `version: 2.0.1+3`
   - `+` 后的构建号必须**每次递增**（分 ABI 安装包的 versionCode 为 `ABI 编号 × 1000 + 构建号`）。
2. 在 `CHANGELOG.md` 顶部新增对应版本的条目，标题格式为 `## [2.0.1] - 日期`，CI 会把这一节作为 Release 说明。
3. 合并到 `main` 后，在 `main` 的最新提交上打标签并推送：

   ```bash
   git checkout main
   git pull
   git tag v2.0.1
   git push origin v2.0.1
   ```

   不需要在 GitHub 网页上手动创建 Release，标签推送后由 CI 自动发布。

4. CI 会依次完成：格式检查 → 静态分析 → 测试 → 校验标签与 `pubspec.yaml` 版本一致 → 用正式密钥构建
   `arm64-v8a` / `armeabi-v7a` / `x86_64` 三个安装包 → 检查安装包**不含 INTERNET 权限**、**不是 debug 签名**
   → 生成 `SHA256SUMS.txt` → 发布 GitHub Release。

标签中包含 `-`（如 `v2.1.0-beta.1`）时会标记为预发布版本。

## 三、本地构建正式签名的安装包（可选）

在 `android/` 目录下创建 `key.properties`（已被 git 忽略）：

```properties
storeFile=/absolute/path/to/simer-release.jks
storePassword=******
keyAlias=simer
keyPassword=******
```

然后运行：

```bash
flutter build apk --release --split-per-abi
```

未配置签名时，本地 release 构建会回退到 debug 签名并在构建日志中警告——这样的安装包**不能分发**。
