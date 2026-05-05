# Keep Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }

-dontwarn io.flutter.**

# If you use Firebase
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# If you use Dio
-keep class okhttp3.** { *; }
-keep class okio.** { *; }

# Prevent R8 crash for Kotlin/Coroutines
-keep class kotlinx.coroutines.** { *; }
-dontwarn kotlinx.coroutines.**
