# Accountanter Release Guide

This guide describes how to build and package Accountanter for different platforms.

## General Preparation

Before building for any platform, ensure your dependencies are up to date and your version number is correct.

1.  **Update Dependencies**:
    ```bash
    flutter pub get
    ```
2.  **Run Code Generation** (if you've modified database schemas):
    ```bash
    dart run build_runner build --delete-conflicting-outputs
    ```
3.  **Check Version**:
    Open `pubspec.yaml` and update the `version:` line (e.g., `0.1.0+2`).
    *   `0.1.0` is the user-visible version.
    *   `2` is the internal build number.

---

## 💻 Windows Release (Recommended for Desktop)

Since you are developing on Windows, this is the easiest release to create.

1.  **Build**:
    ```bash
    flutter build windows
    ```
2.  **Output**:
    The result will be in `build/windows/x64/runner/Release/`.
3.  **Distribution**:
    To share the app, zip the entire contents of the `Release` folder. The user will need all the files in that folder to run `accountanter.exe`.

---

## 📱 Android Release

1.  **Build APK** (Simplest for direct installation):
    ```bash
    flutter build apk --release
    ```
2.  **Build App Bundle** (For Google Play Store):
    ```bash
    flutter build appbundle
    ```
3.  **Output**:
    *   APK: `build/app/outputs/flutter-apk/app-release.apk`
    *   AAB: `build/app/outputs/bundle/release/app-release.aab`

> [!IMPORTANT]
> For a production release, you should sign your APK. See [Flutter's official guide on signing](https://docs.flutter.dev/deployment/android#signing-the-app).

---

## 🌐 Web Release

1.  **Build**:
    ```bash
    flutter build web
    ```
2.  **Output**:
    The result will be in `build/web/`.
3.  **Distribution**:
    Upload the contents of `build/web/` to your web host.

---

## 🍎 iOS / macOS Release

> [!NOTE]
> Requires a Mac with Xcode.

1.  **iOS Build**:
    ```bash
    flutter build ios --release
    ```
2.  **macOS Build**:
    ```bash
    flutter build macos
    ```
3.  **Output**:
    *   iOS: `build/ios/iphoneos/Runner.app` (usually followed by Xcode archiving)
    *   macOS: `build/macos/Build/Products/Release/accountanter.app`

---

## ✅ Verification Checklist

- [ ] `flutter analyze` passes.
- [ ] `flutter test` passes.
- [ ] No "TODO" or "FixMe" comments remain in critical code.
- [ ] Version number is incremented.
