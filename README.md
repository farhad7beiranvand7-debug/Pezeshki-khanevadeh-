# پزشک خانواده — RC2

اپلیکیشن عمومی برای مدیریت اعضای خانواده، محاسبه مراقبت‌های قابل‌فعال‌سازی و یادآوری زمان دریافت خدمات سلامت.

## اجرای محلی
```bash
flutter create . --platforms=android,ios --org ir.pezeshk --project-name pezeshk_khanevadeh
./tool/prepare_platforms.sh
flutter pub get
dart run flutter_launcher_icons
flutter run
```

## Android
برای ساخت نسخه قابل نصب APK:
```bash
flutter pub get
dart run flutter_launcher_icons
flutter build apk --release
```
خروجی:
`build/app/outputs/flutter-apk/app-release.apk`

برای Google Play، نسخه AAB:
```bash
flutter build appbundle --release --obfuscate --split-debug-info=build/symbols
```
خروجی:
`build/app/outputs/bundle/release/app-release.aab`

### ساخت خودکار در GitHub Actions
Workflow موجود در `.github/workflows/android.yml` با هر push به `main` یا با اجرای دستی، پروژه را بررسی و APK + AAB را می‌سازد. فایل‌ها در بخش **Actions → Run → Artifacts** قابل دریافت هستند.

> برای انتشار واقعی در Google Play باید release signing را جداگانه با GitHub Secrets/Play App Signing تنظیم کنید. کلید خصوصی را داخل repository قرار ندهید.

## iOS
ساخت و انتشار iOS به macOS + Xcode و Apple Developer Program نیاز دارد. از Xcode 26+ و SDK iOS 26+ استفاده کنید:
```bash
flutter build ipa --release
```

## نکات مهم
- قواعد پزشکی فعال در `lib/data/health_rules.dart` عمداً محدود هستند.
- فهرست بیماری‌ها نمونه آزاد نیست؛ فقط مواردی که برای برنامه سلامت/خدمات سطح اول relevance دارند نمایش داده می‌شوند.
- اپ تشخیص یا درمان نیست.
- مرکز سلامت تحت پوشش تا دریافت داده رسمی محدوده‌ها «حدس» زده نمی‌شود.
- برای انتشار عمومی باید `docs/SOURCES.md` و آخرین ابلاغ‌های رسمی وزارت بهداشت توسط مسئول علمی محصول بررسی و تأیید شوند.

## وضعیت نهایی انتشار
این پروژه V1.0.0 به‌صورت source release package آماده ساخت است. برای فایل‌های نهایی AAB/IPA، signing و حساب‌های انتشار باید در محیط مالک محصول انجام شود.


## تغییرات V1.1
- جریان ثبت عضو خانواده به ۴ مرحله ساده کاهش یافته است.
- سؤال‌های سلامت غیرضروری حذف شده‌اند؛ فعلاً فقط «دیابت» یک مراقبت فعال ایجاد می‌کند.
- یادآوری‌ها از Exact Alarm استفاده نمی‌کنند تا مجوز محدود اضافی لازم نباشد.
- خطاهای داده محلی و موقعیت مکانی با پیام کاربرپسند مدیریت می‌شوند.
- Workflow برای push و pull request روی main فعال است.

## V1.2 — گسترش کاتالوگ مراقبت
موتور مراقبت اکنون گروه‌های سنی، سلامت مدارس، مراقبت سالمندان، زنان و بارداری، سلامت دهان، تغذیه، ایراپن و بیماری‌های مزمن شایع را در قالب یادآوری‌های قابل به‌روزرسانی پوشش می‌دهد. این نسخه جایگزین سامانه رسمی سیب یا دستور پزشک/ماما نیست.
