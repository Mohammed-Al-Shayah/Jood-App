import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// ---- Load keystore properties (android/key.properties) ----
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.example.jood"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.jood"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // ---- Release signing (uses android/app/upload-keystore.jks) ----
    signingConfigs {
        create("release") {
            // Fail fast with clear error if key.properties missing or incomplete
            val keyAliasValue = keystoreProperties["keyAlias"] as String?
                ?: error("Missing keyAlias in android/key.properties")
            val keyPasswordValue = keystoreProperties["keyPassword"] as String?
                ?: error("Missing keyPassword in android/key.properties")
            val storeFileValue = keystoreProperties["storeFile"] as String?
                ?: error("Missing storeFile in android/key.properties")
            val storePasswordValue = keystoreProperties["storePassword"] as String?
                ?: error("Missing storePassword in android/key.properties")

            keyAlias = keyAliasValue
            keyPassword = keyPasswordValue
            storeFile = file(storeFileValue) // upload-keystore.jks is inside android/app
            storePassword = storePasswordValue
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            // اترك بقية إعدادات release كما هي بمشروعك (minify/shrink) لو عندك
        }
    }
}

flutter {
    source = "../.."
}
