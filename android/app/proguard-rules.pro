# Flutter-specific ProGuard rules
# Keep Flutter classes
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }

# Keep Hive classes (until migration to Drift is complete)
-keep class com.hive.** { *; }
-keepclassmembers class * extends com.google.protobuf.GeneratedMessageLite { *; }

# Keep Flutter Local Notifications
-keep class com.dexterous.** { *; }

# Keep PDF/Printing libraries
-keep class com.pdfview.** { *; }

# Keep timezone data
-keep class org.threeten.bp.** { *; }

# Keep model classes (they use reflection for serialization)
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Prevent stripping of native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep Kotlin metadata
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod

# Google Play Core (for deferred components - don't use but Flutter references it)
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }

# Optimization settings
-optimizationpasses 5
-dontusemixedcaseclassnames
-verbose

# Remove logging in release
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}
