import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// ---------------------------------------------------------------------------
// Release signing: reads keystore details from android/key.properties.
// Debug builds work without it. A RELEASE build without key.properties
// fails loudly so the developer knows they must create the file.
// ---------------------------------------------------------------------------
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
val hasKeystoreProperties = keystorePropertiesFile.exists()
if (hasKeystoreProperties) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.yonastigistu.t2_rental"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.yonastigistu.t2_rental"
        minSdk = 24
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    if (hasKeystoreProperties) {
        signingConfigs {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            if (hasKeystoreProperties) {
                signingConfig = signingConfigs.getByName("release")
            }
            // If key.properties is missing, signingConfig is left unset.
            // The taskGraph hook below ensures the release build fails loudly
            // rather than silently falling back to debug signing.
        }
    }
}

// Ensure release builds fail with a clear, helpful message when key.properties is missing,
// while allowing debug builds (flutter run, assembleDebug) to build without it.
gradle.taskGraph.whenReady {
    val isReleaseRequested = allTasks.any {
        it.name.contains("Release", ignoreCase = true) && !it.name.contains("Test", ignoreCase = true)
    }
    if (isReleaseRequested && !hasKeystoreProperties) {
        throw GradleException(
            """
            |
            | *** RELEASE BUILD FAILED: android/key.properties not found ***
            |
            | To build a release APK you must create android/key.properties
            | with your keystore details. See android/key.properties.example
            | and docs/release.md for instructions.
            |
            """.trimMargin()
        )
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
