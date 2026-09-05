# تنظیمات پلتفرم

پروژه عمداً بدون پوشه‌های generated/android و generated/ios تحویل داده شده تا با نسخه جاری Flutter تولید شوند.

## تولید platform folders
```bash
flutter create . --platforms=android,ios --org ir.pezeshk --project-name pezeshk_khanevadeh
./tool/prepare_platforms.sh
flutter pub get
dart run flutter_launcher_icons
```

اسکریپت prepare_platforms مجوز موقعیت مکانی را اضافه می‌کند و target/compile SDK اندروید را در صورت استفاده از قالب‌های شناخته‌شده روی API 36 تنظیم می‌کند.

## Signing
- Android: keystore و Play App Signing را فقط روی محیط امن مالک پروژه تنظیم کنید.
- iOS: Team ID، Bundle ID، certificate و provisioning profile را در Apple Developer/Xcode تنظیم کنید.
- هیچ credential، keystore یا certificate در repository قرار نگیرد.
