plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services") // Apply this for Firebase
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.laraajailatt.ghodacare"
    compileSdk = 30  // Flutter's compileSdk version
    ndkVersion = "27.0.12077973" 
    defaultConfig {
        applicationId = "com.laraajailatt.ghodacare"
        minSdk = 21  // Your Flutter minSdkVersion
        targetSdk = 30  // Your Flutter targetSdkVersion
        versionCode = 1
        versionName = "1.0"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }
    defaultConfig {
        multiDexEnabled = true
    }
    kotlinOptions {
        jvmTarget = "11"
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    coreLibraryDesugaring 'com.android.tools:desugar_jdk_libs:1.1.5'  // Add this dependency
    implementation "org.jetbrains.kotlin:kotlin-stdlib-jdk7:$kotlin_version"
    implementation 'androidx.multidex:multidex:2.0.1'
    implementation platform('com.google.firebase:firebase-bom:32.5.0')
    implementation 'com.google.firebase:firebase-analytics'
    implementation 'com.google.firebase:firebase-auth'
    implementation 'com.google.firebase:firebase-firestore'
}    

flutter {
    source = "../.."
}

task("clean") {
    delete(rootProject.buildDir)
}
