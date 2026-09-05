# پرونده نهایی انتشار «پزشک خانواده» V1.0.0

## 1) خروجی‌های لازم
### Android
خروجی نهایی برای Google Play:
`build/app/outputs/bundle/release/app.aab`

Flutter انتشار Android را به‌صورت App Bundle توصیه می‌کند. AAB باید با Upload Key امضا شود و Play App Signing مدیریت کلید امضای توزیع را بر عهده بگیرد.

### iOS
خروجی نهایی برای App Store:
`build/ios/ipa/*.ipa`

ساخت و انتشار iOS نیازمند macOS/Xcode و Apple Developer Program است. IPA باید با signing معتبر مالک محصول ساخته شود.

## 2) دستور ساخت Android
```bash
flutter clean
flutter pub get
dart run flutter_launcher_icons
flutter analyze
flutter build appbundle --release --obfuscate --split-debug-info=build/symbols
```

## 3) دستور ساخت iOS
```bash
flutter clean
flutter pub get
dart run flutter_launcher_icons
flutter analyze
flutter build ipa --release --obfuscate --split-debug-info=build/symbols
```

برای iOS باید Signing/Team/Bundle ID در Xcode یا App Store Connect تنظیم شده باشد.

## 4) پیش از ارسال Android
- target SDK = 36 یا بالاتر
- Release signing فعال
- Play App Signing تنظیم شده
- نسخه و build number یکتا
- تست نصب و اعلان روی Android واقعی
- بررسی Data Safety در Play Console
- Privacy Policy عمومی

## 5) پیش از ارسال iOS
- Xcode 26 یا بالاتر
- iOS 26 SDK یا بالاتر
- Bundle ID یکتا
- Signing معتبر
- نسخه و Build Number یکتا
- تست روی iPhone واقعی
- App Privacy و Age Rating تکمیل
- Privacy Policy عمومی

## 6) نکته پزشکی
این اپ تشخیص، تجویز یا جایگزین پزشک نیست. موتور مراقبت باید فقط از قواعدی استفاده کند که مسئول علمی محصول با منبع رسمی و نسخه/تاریخ مشخص تأیید کرده باشد.

## 7) اطلاعات هویتی که باید قبل از انتشار تعیین شوند
- نام حقوقی مالک/شرکت
- ایمیل پشتیبانی
- وب‌سایت/دامنه Privacy Policy
- Package Name
- Bundle ID
- نام ناشر در فروشگاه‌ها
- Team ID اپل
- حساب Google Play Console
