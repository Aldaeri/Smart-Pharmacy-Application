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
    namespace = "com.example.smart_pharmacy_app"
    compileSdk = flutter.compileSdkVersion
//    ndkVersion = flutter.ndkVersion="29.0.13113456"
    ndkVersion= "29.0.13113456"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
//        sourceCompatibility = JavaVersion.VERSION_1_8
//        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
//        jvmTarget = "1.8"
    }

    buildFeatures {
        buildConfig = true
        mlModelBinding = true
    }

    aaptOptions {
        noCompress += listOf("tflite", "traineddata")  // التصحيح هنا
//        noCompress = 'traineddata'
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.smart_pharmacy_app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
//        minSdk = flutter.minSdkVersion
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
//        versionCode 1
//        versionName "1.0"
        multiDexEnabled = true
//        ndk {
//            abiFilters.clear()
//            abiFilters.add("arm64-v8a")
//            abiFilters += listOf("armeabi-v7a", "arm64-v8a", "x86", "x86_64")
 //       }
        ndk {
            abiFilters += listOf("arm64-v8a")
        }
        resConfigs("en", "ar")
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
//            minifyEnabled = true
//            shrinkResources = true
//            signingConfig = signingConfigs.getByName("debug")
        }
    }
}
dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:1.2.2")
}
flutter {
    source = "../.."
}
