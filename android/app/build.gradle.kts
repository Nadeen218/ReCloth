plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.graduation_project"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // Enable core library desugaring to support Java 8 features on older devices
        isCoreLibraryDesugaringEnabled = true

        // Setting compatibility to Java 1.8 for better library support
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    defaultConfig {
        // Unique Application ID from your Firebase configuration
        applicationId = "com.example.graduation_project"

        // Minimum SDK set to 21 to support MultiDex by default
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Enable multidex for apps with many dependencies
        multiDexEnabled = true
    }

    buildTypes {
        release {
            // Signing with the debug keys for development phase
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Core library desugaring dependency to resolve the AAR metadata issue
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.3")
}
