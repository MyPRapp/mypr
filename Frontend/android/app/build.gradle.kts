plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

java {
    toolchain {
        languageVersion = JavaLanguageVersion.of(17)
    }
}

android {
    namespace = "com.etairia.mypr"
    compileSdk = 35
    ndkVersion = "27.2.12479018"

    compileOptions {
        // Flag to enable support for the new language APIs
        isCoreLibraryDesugaringEnabled = true

        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.etairia.mypr"
        minSdk = 21
        targetSdk = 35
        versionCode = flutter.versionCode ?: 1
        versionName = flutter.versionName ?: "1.0.0"
    }

    signingConfigs {
        create("release") {
            storeFile = file("C:\\Users\\georg\\mypr_signing\\upload-key.jks")
            storePassword = System.getenv("STORE_PASSWORD")
                ?: project.findProperty("STORE_PASSWORD") as String? ?: ""
            keyAlias = "upload"
            keyPassword = System.getenv("KEY_PASSWORD")
                ?: project.findProperty("KEY_PASSWORD") as String? ?: ""
        }
    }

    buildTypes {
        //TODO Change this before release
        debug { isDebuggable = false }
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true // Enable code shrinking
            isShrinkResources = true // Enable resource shrinking
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
    // implementation("androidx.window:window:1.0.0")
    // implementation("androidx.window:window-java:1.0.0")
}

flutter {
    source = "../.."
}
