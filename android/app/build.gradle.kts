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

// ---- Load keystore props from android/key.properties ----
val keystoreProperties = Properties().apply {
    val f = rootProject.file("key.properties") // android/key.properties
    if (f.exists()) load(FileInputStream(f))
}

// Read values OUTSIDE signingConfigs (avoids scope issues)
val releaseKeyAlias: String? = keystoreProperties.getProperty("keyAlias")
val releaseKeyPassword: String? = keystoreProperties.getProperty("keyPassword")
val releaseStoreFile: String? = keystoreProperties.getProperty("storeFile")
val releaseStorePassword: String? = keystoreProperties.getProperty("storePassword")

android {
    namespace = "com.jood.offers"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        // تحذير deprecated عادي، مش بيكسر البيلد
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.jood.offers"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // ---- Release signing (uses android/app/upload-keystore.jks) ----
    signingConfigs {
        create("release") {
            if (releaseKeyAlias.isNullOrBlank() ||
                releaseKeyPassword.isNullOrBlank() ||
                releaseStoreFile.isNullOrBlank() ||
                releaseStorePassword.isNullOrBlank()
            ) {
                throw GradleException(
                    "Missing signing config. Make sure android/key.properties contains: " +
                            "keyAlias, keyPassword, storeFile, storePassword"
                )
            }

            keyAlias = releaseKeyAlias
            keyPassword = releaseKeyPassword
            // storeFile value should be: upload-keystore.jks (file exists in android/app)
            storeFile = file(releaseStoreFile!!)
            storePassword = releaseStorePassword
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}
