# R8/ProGuard keep rules for release builds.
# These protect code accessed via reflection, which R8's static analysis
# cannot see and would otherwise strip, causing release-only crashes.

# --- Flutter engine/embedding ---
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# --- Play Core (referenced by Flutter's deferred components, often absent) ---
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }

# --- flutter_local_notifications (uses Gson for (de)serializing notification models) ---
-keep class com.dexterous.** { *; }
-keep class com.google.gson.** { *; }
-keepattributes Signature
-keepattributes *Annotation*
# Keep generic signatures and the no-arg constructors Gson relies on.
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# --- Firebase (core / auth / messaging) ---
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# --- pdfx (native PDF rendering) ---
-keep class io.github.classgraph.** { *; }
-dontwarn io.github.classgraph.**
