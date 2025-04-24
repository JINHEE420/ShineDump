# Dumpshine Flutter

## Build Instructions

This document outlines how to build and run the Dumpshine Flutter application for various environments and platforms.

### Prerequisites

- Flutter SDK 3.1.0 or newer
- Android Studio (for Android builds)
- Xcode 14+ (for iOS builds)
- Valid keystore for Android release builds
- Valid Apple Developer account for iOS releases

### Environment Configurations

The application supports different environments through configuration files:

- `vn.env` - Vietnamese environment configures
- `ko.env` - Korean environment configures

### Run on a device/simulator
#### Setup project
```bash
# Get dependencies and generate l10n (localizations)
flutter pub get

# A build system for Dart code generation and modular compilation.
dart run build_runner build --delete-conflicting-outputs
```

#### Android
Connect with an android device or emulator

```bash
# Run with Vietnamese environment
flutter run --dart-define-from-file=env/vn.env --flavor vn

# Run with Korean environment
flutter run --dart-define-from-file=env/ko.env --flavor ko
```

#### iOS
Sign In to your Apple Developer account in Xcode.

Connect with an iOS device or simulator

```bash
# Open Xcode and select the device you want to run
open ios/Runner.xcworkspace

# Run with Vietnamese environment
flutter run --dart-define-from-file=env/vn.env

# Run with Korean environment
flutter run --dart-define-from-file=env/ko.env
```

### Release Builds
Open terminal from the root folder

#### Android APK

```bash
# Build release APK with Vietnamese environment
flutter build apk --release --dart-define-from-file=env/vn.env --flavor vn

# Build release APK with Customer environment
flutter build apk --release --dart-define-from-file=env/ko.env --flavor ko
```

#### Android App Bundle (for Google Play)

```bash
flutter build appbundle --release --dart-define-from-file=env/ko.env --flavor ko
```

#### iOS Build

```bash
# Build IPA package
flutter build ipa --release --dart-define-from-file=env/ko.env
```

### Output Locations

- Android APK: `build/app/outputs/apk/ko/release/*.apk`
- Android App Bundle: `build/app/outputs/bundle/koRelease/*.aab`
- iOS IPA: `build/ios/ipa/*.ipa`

### Troubleshooting

If you encounter build issues:

1. Clean the project: `flutter clean`
2. Get dependencies: `flutter pub get`
3. Try building again with the appropriate environment file

For more details about available environment variables, check the environment files in the env directory.