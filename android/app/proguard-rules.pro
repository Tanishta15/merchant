# Add project-specific ProGuard rules here.
# You can control the ProGuard optimization by adding rules.
# By default, it only includes the Android optimizations.
# Read more at https://developer.android.com/studio/build/shrink-code.html

# Keep all Flutter classes
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }

# Example rules to keep your app's classes and resources:
-keep class com.example.merchant.** { *; }
