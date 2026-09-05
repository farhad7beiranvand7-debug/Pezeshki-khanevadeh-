# ساخت APK در GitHub

1. این پروژه را در یک repository خالی GitHub قرار دهید.
2. شاخه `main` را push کنید.
3. GitHub Actions به‌صورت خودکار Workflow با نام `Build Android APK and AAB` را اجرا می‌کند.
4. پس از پایان موفق، وارد همان اجرای Workflow شوید.
5. در بخش **Artifacts** فایل `pezeshk-khanevadeh-apk` را دریافت کنید.
6. برای Google Play، فایل `pezeshk-khanevadeh-aab` را استفاده کنید.

## نکته انتشار
APK تولیدشده برای نصب و تست مناسب است. برای انتشار رسمی Google Play، باید release signing و Play App Signing را در محیط مالک محصول تنظیم کنید و کلید خصوصی را هرگز داخل GitHub repository نگذارید.

## target API
اسکریپت `tool/prepare_platforms.sh` هنگام ایجاد پوشه‌های Android، target/compile SDK را روی API 36 تنظیم می‌کند؛ در صورت تغییر قالب Flutter در آینده، مقدار تولیدشده را در فایل Gradle بررسی کنید.
