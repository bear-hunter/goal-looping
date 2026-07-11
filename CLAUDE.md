# AGENTS.md

Project-level instructions for AI coding agents working in this repository.

## Project Context

This is a Flutter app named `centile`. It has generated platform folders for Android, iOS, macOS, Linux, Windows, and Web, but local development on Karl's MacBook should default to Flutter Web in Chrome.

## Primary Rule: Run In Browser

- Always use Chrome/Web as the default local run target.
- Do not require Android Studio or the Android SDK for ordinary development, testing, or demos.
- Do not ask Karl to install Android Studio just to run this project locally.
- Prefer:

```bash
flutter run -d chrome
```

- For build verification, prefer:

```bash
flutter build web --no-wasm-dry-run
```

- If `--no-wasm-dry-run` is not needed, a normal web build is also acceptable:

```bash
flutter build web
```

## Known Local Environment Notes

- `flutter doctor` may report Android SDK or Xcode issues. Those are not blockers for Chrome/Web development.
- Chrome is the expected device for this repo:

```bash
flutter devices
```

- If macOS blocks Flutter's `dartaotruntime`, this is a Gatekeeper/quarantine issue with the local Flutter SDK, not an Android Studio issue. Karl may allow it from macOS Privacy & Security. If appropriate, an agent can inspect quarantine flags with:

```bash
xattr /opt/homebrew/share/flutter/bin/cache/dart-sdk/bin/dartaotruntime
```

## Codebase-First Workflow

- Read relevant source files before changing code.
- Search the repo with `rg` before guessing where behavior lives.
- Keep changes scoped to the user's request.
- Do not refactor unrelated code while fixing or adding a feature.
- Do not commit, push, create PRs, rebase, or perform destructive git operations unless Karl explicitly asks in the current task.

## Web Compatibility

- This app currently compiles for Web, but some features are platform-sensitive.
- Be careful around code using:
  - `dart:io`
  - `path_provider`
  - `file_picker`
  - `share_plus`
  - `flutter_local_notifications`
  - PDF export and local file export flows
  - native database code under `lib/services/database/`
- If a change touches those areas, verify Web compilation and consider conditional imports or web-safe fallbacks.

## Validation

After code changes, run the most relevant checks available. For this repo, prefer:

```bash
flutter analyze
flutter build web --no-wasm-dry-run
```

When working on UI behavior, also run:

```bash
flutter run -d chrome
```

Then manually smoke-test the changed flow in the browser.

## Collaboration Style

- If Karl asks a diagnostic or "can we" question, answer the question first and wait unless he explicitly asks for implementation.
- If Karl asks to implement, fix, create, update, or change something, proceed after inspecting the relevant code.
- Keep final answers concise and include what was changed, what was verified, and any remaining caveats.

## Lessons Learned

- [WORKS][flutter-web-default]: This project can run locally in Chrome with `flutter run -d chrome`; Android Studio is not required for browser development.
- [WORKS][web-build]: `flutter build web --no-wasm-dry-run` succeeds for the current codebase and avoids non-fatal wasm dry-run noise.
- [FAIL][macos-dartaotruntime-quarantine]: If Chrome run fails because macOS says `"dartaotruntime" Not Opened`, the blocked Flutter SDK binary has a Gatekeeper/quarantine issue; use macOS Privacy & Security allow flow or remove the quarantine attribute from the Flutter SDK binary.
