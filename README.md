# Centile

Centile is a local-first Flutter app for managing goals, daily work, habits,
focus sessions, and reflections. The main areas of the app are Today, Plan,
Habits, Grow, and You.

App data is stored locally with Hive. Backups can be exported as JSON, and
reflection data can be exported as PDF.

## Run locally

Install Flutter and make sure Chrome appears in `flutter devices`, then run:

```bash
flutter pub get
flutter run -d chrome
```

Android Studio is not required for browser development.

## Checks

```bash
flutter analyze
flutter test
flutter build web --no-wasm-dry-run
```

The browser smoke tests use Playwright. Set them up once with:

```bash
cd qa
npm ci
npx playwright install chromium
cd ..
```

Run the Web build and smoke tests together with:

```bash
./scripts/qa-run.sh
```

## Project layout

- `lib/models` contains the Hive models and adapters.
- `lib/providers` contains shared application state.
- `lib/screens` contains the main app screens and flows.
- `lib/services` contains storage, backup, export, and notification code.
- `lib/widgets` contains reusable UI components.
- `test` contains Flutter unit and widget tests.
- `qa` contains the Playwright smoke tests.

## Platform notes

Chrome/Web is the default development target. Scheduled device notifications
are available on Android and iOS; the Web build keeps reminder settings visible
but does not attempt to schedule local OS notifications.
