import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// ── Release 签名 ──────────────────────────────────────────────
// 优先读取环境变量（CI），其次读取 android/key.properties（本地构建，已被 git 忽略）。
// key.properties 示例：
//   storeFile=/absolute/path/to/simer-release.jks   (相对路径以 android/ 目录为基准)
//   storePassword=******
//   keyAlias=simer
//   keyPassword=******
val keystoreProperties =
    Properties().apply {
        val file = rootProject.file("key.properties")
        if (file.exists()) {
            FileInputStream(file).use { load(it) }
        }
    }

fun signingValue(
    envName: String,
    propertyName: String,
): String? =
    System.getenv(envName)?.takeIf { it.isNotBlank() }
        ?: keystoreProperties.getProperty(propertyName)?.takeIf { it.isNotBlank() }

val releaseStoreFile = signingValue("SIMER_KEYSTORE_FILE", "storeFile")
val releaseStorePassword = signingValue("SIMER_KEYSTORE_PASSWORD", "storePassword")
val releaseKeyAlias = signingValue("SIMER_KEY_ALIAS", "keyAlias")
val releaseKeyPassword = signingValue("SIMER_KEY_PASSWORD", "keyPassword")
val hasReleaseSigning =
    listOf(releaseStoreFile, releaseStorePassword, releaseKeyAlias, releaseKeyPassword)
        .all { it != null }

// CI 发版时设置 SIMER_REQUIRE_RELEASE_SIGNING=true：缺少正式签名直接失败，杜绝 debug 签名包流出。
if (System.getenv("SIMER_REQUIRE_RELEASE_SIGNING") == "true" && !hasReleaseSigning) {
    throw GradleException(
        "Release signing is required but SIMER_KEYSTORE_FILE / SIMER_KEYSTORE_PASSWORD / " +
            "SIMER_KEY_ALIAS / SIMER_KEY_PASSWORD are not all set.",
    )
}

val isReleaseTaskRequested =
    gradle.startParameter.taskNames.any { it.contains("Release", ignoreCase = true) }

// ── 与正式版并存的构建 ─────────────────────────────────────────
// 正式版包名为 io.github.xiaoxizi_lyx.simer。其他构建加包名后缀并改用不同的应用名，
// 可以和正式版同时安装、数据互不影响；否则签名不同会导致安装失败，
// 而 flutter run 遇到这种情况会先卸载已安装的正式版（连同数据）再重装。
//   debug   → .debug，「SIMer Debug」
//   profile → .profile，「SIMer Profile」
//   release + SIMER_TEST_BUILD=true（CI 中 PR / main 的测试包）→ .ci，「SIMer CI」
val isTestBuild = System.getenv("SIMER_TEST_BUILD") == "true"
if (isTestBuild && System.getenv("SIMER_REQUIRE_RELEASE_SIGNING") == "true") {
    throw GradleException("SIMER_TEST_BUILD cannot be combined with SIMER_REQUIRE_RELEASE_SIGNING.")
}

android {
    namespace = "io.github.xiaoxizi_lyx.simer"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "io.github.xiaoxizi_lyx.simer"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
        manifestPlaceholders["appLabel"] = "SIMer"
    }

    signingConfigs {
        if (hasReleaseSigning) {
            create("release") {
                storeFile = rootProject.file(releaseStoreFile!!)
                storePassword = releaseStorePassword
                keyAlias = releaseKeyAlias
                keyPassword = releaseKeyPassword
            }
        }
    }

    buildTypes {
        debug {
            applicationIdSuffix = ".debug"
            manifestPlaceholders["appLabel"] = "SIMer Debug"
        }
        // profile 由 Flutter Gradle 插件创建，这里在它出现时再配置
        matching { it.name == "profile" }.configureEach {
            applicationIdSuffix = ".profile"
            manifestPlaceholders["appLabel"] = "SIMer Profile"
        }
        release {
            if (isTestBuild) {
                applicationIdSuffix = ".ci"
                manifestPlaceholders["appLabel"] = "SIMer CI"
            }
            signingConfig =
                if (hasReleaseSigning) {
                    signingConfigs.getByName("release")
                } else {
                    if (isReleaseTaskRequested) {
                        logger.warn(
                            "SIMer: release signing is not configured, falling back to the debug key. " +
                                "This build must NOT be distributed.",
                        )
                    }
                    signingConfigs.getByName("debug")
                }
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
