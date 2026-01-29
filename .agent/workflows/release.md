---
description: Build a release version of the application
---

This workflow guides the agent through building a release version of the Accountanter app.

1. Ensure dependencies are up to date and code generation is complete.
// turbo
```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

2. Run analyses and tests to ensure stability.
// turbo
```bash
flutter analyze
flutter test
```

3. Build for the requested platform.

   - **Windows**:
     // turbo
     ```bash
     flutter build windows
     ```
   - **Android**:
     // turbo
     ```bash
     flutter build apk --release
     ```
   - **Web**:
     // turbo
     ```bash
     flutter build web
     ```

4. Notify the user of the build completion and output location.
   - Windows: `build/windows/x64/runner/Release/`
   - Android: `build/app/outputs/flutter-apk/app-release.apk`
   - Web: `build/web/`
