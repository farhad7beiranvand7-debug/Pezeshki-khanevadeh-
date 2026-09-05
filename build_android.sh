#!/usr/bin/env bash
set -euo pipefail

flutter pub get
dart run flutter_launcher_icons
flutter analyze
flutter build apk --release
flutter build appbundle --release --obfuscate --split-debug-info=build/symbols

echo "APK: build/app/outputs/flutter-apk/app-release.apk"
echo "AAB: build/app/outputs/bundle/release/app-release.aab"
