#!/usr/bin/env bash
set -euo pipefail
flutter create . --platforms=android,ios --org ir.pezeshk --project-name pezeshk_khanevadeh
python3 - <<'PY'
from pathlib import Path
manifest = Path('android/app/src/main/AndroidManifest.xml')
s = manifest.read_text()
marker = '<manifest xmlns:android="http://schemas.android.com/apk/res/android">'
permissions = '\n    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />\n    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />\n    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />'
if 'android.permission.ACCESS_FINE_LOCATION' not in s:
    s = s.replace(marker, marker + permissions)
manifest.write_text(s)
plist = Path('ios/Runner/Info.plist')
s = plist.read_text()
if 'NSLocationWhenInUseUsageDescription' not in s:
    s = s.replace('</dict>', '\t<key>NSLocationWhenInUseUsageDescription</key>\n\t<string>برای تعیین محل سکونت و یافتن مرکز سلامت نزدیک استفاده می‌شود.</string>\n</dict>')
plist.write_text(s)
PY
