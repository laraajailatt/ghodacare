import java.util.Properties


   
val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localPropertiesFile.reader(Charsets.UTF_8).use { reader ->
        localProperties.load(reader)
    }
}

val flutterRoot = localProperties.getProperty("flutter.sdk")
    ?: error("Flutter SDK not found. Define location with flutter.sdk in the local.properties file.")

val flutterVersionCode = localProperties.getProperty("flutter.versionCode") ?: "1"

val flutterVersionName = localProperties.getProperty("flutter.versionName") ?: "1.0"

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android") // Updated plugin for Kotlin Android
    id("com.google.gms.google-services") // Apply this for Firebase
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.laraajailatt.ghodacare"
    compileSdk = 35  // Flutter's compileSdk version
    ndkVersion = "27.0.12077973" 
    defaultConfig {
        applicationId = "com.laraajailatt.ghodacare"
        minSdk = 21  // Your Flutter minSdkVersion
        targetSdk = 35  // Your Flutter targetSdkVersion
        versionCode = 1
        versionName = "1.0"
        multiDexEnabled = true
    }

   // sourceSets {
     //   main.java.srcDirs += "src/main/kotlin"
    //}

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
            //minifyEnabled = true
            //shrinkResources = true
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4") // Uncommented dependency
    implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk7:1.8.0")
    implementation("androidx.multidex:multidex:2.0.1")
    implementation(platform("com.google.firebase:firebase-bom:32.5.0"))
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.firebase:firebase-auth")
    implementation("com.google.firebase:firebase-firestore")
}

flutter {
    source = "../.."
}

//task("clean") {
   // delete(rootProject.buildDir)
//}
