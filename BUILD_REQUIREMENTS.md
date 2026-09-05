# پیش‌نیاز ساخت

## Android
Flutter stable + Android SDK + Java/Gradle. برای انتشار release باید signing configuration تنظیم شود.

## iOS
macOS + Xcode سازگار با الزام فعلی App Store Connect + Apple Developer account. Build باید با signing مناسب archive و upload شود.

## نکته مهم
فایل AAB/IPA صرفاً با کپی کردن source تولید نمی‌شود. signing و account-specific metadata بخشی از فرآیند انتشار است.
