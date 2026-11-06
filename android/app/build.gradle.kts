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
        release {
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
