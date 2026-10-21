# AGENTS.md — FitnessCenter Mobile

Flutter **Android-only** member client of the FitnessCenter Suite (with the
FastAPI backend and Nuxt admin web). Members browse the catalog, check live slot
availability, book/cancel classes, manage their profile, and receive real-time
push. See `README.md` for the full narrative.

## Stack

Flutter · Dart (SDK ^3.9) · Firebase (Auth + Cloud Messaging) ·
`get` (GetX) · `flutter_riverpod` · `http` ·
`flutter_local_notifications` · `flutter_secure_storage`.

### State management — three layers, on purpose

There is no `get_it` in this project; the service locator is GetX's.

| Concern | Tool | Where |
| --- | --- | --- |
| Routing, service location, navigation, snackbars | **GetX** (`package:get`) | `app/config/app_routes.dart`, every `di/*_injector.dart` |
| Feature state (MVVM) | **`ChangeNotifier`** via `ViewModelBase` | `features/*/presentation/viewmodels/` |
| Scoped, auto-disposing UI filter state | **Riverpod** | `features/available_slots_listing/presentation/state/` |

The Riverpod slice is deliberately narrow: `StateNotifierProvider.autoDispose
.family` keyed by a scope id, so each listing screen instance gets its own
filter state that disposes with it. That is awkward to express with a shared
`ChangeNotifier` in the GetX locator, which is why it is the one place Riverpod
is used. Don't spread it further, and don't replace it with a locator-held
view-model.

## Architecture — MVVM over feature-driven clean architecture

- Each feature: `lib/features/<feature>/` split into `data / domain / presentation`,
  with its own `di` module wired through the GetX locator (`Get.put`/`find`).
  Features: `auth`, `home`, `bookings`, `profile`, `fitness_directory`,
  `available_slots_listing`, `class_booking`.
- **Presentation = ViewModels** (`ChangeNotifier`-based, see
  `lib/app/core/viewmodel`) that expose UI state and orchestrate domain use cases.
  Keep widgets thin; put logic in ViewModels so it's testable in isolation.
- Shared app infrastructure lives in `lib/app/core/` (API client, viewmodel base,
  theme, etc.).

## Commands

```bash
flutter pub get
flutter run -d android          # see .vscode launch config for dart-defines
flutter analyze
flutter test
dart format .
flutter clean                   # drop generated artifacts
```

## Rules & conventions

- **Feature boundaries.** Directory/listing screens (`fitness_directory`,
  `available_slots_listing`) must NOT shape booking payloads directly — call
  `class_booking` helpers and only do local UI updates. Centralize booking
  requests, loading/error state, and post-booking agenda refresh in
  `class_booking`.
- **DTO contract = snake_case.** `*_dto.dart` read the API's **snake_case** JSON
  keys directly. The old camelCase/legacy fallbacks are dead — don't add them
  back. (`UserDto` and `CapabilityDto` intentionally support multiple contracts;
  that's expected, not a pattern to copy elsewhere.)
- **Auth & networking.** REST over an authenticated client; the Firebase ID token
  is attached transparently to every request — don't attach it manually. Login
  sends `X-Client-Platform: mobile` (members→mobile gating; backend rejects
  otherwise). The API client base lives in `lib/app/core/api/shared/`.
- **Push (FCM).** The app registers its device token with the backend on sign-in,
  then receives push from API events (blog publish, trainer announcements,
  booking status changes) with foreground/local notification handling. Preserve
  the register-on-sign-in flow.

## Theming & cross-frontend cohesion (keep aligned with the web admin)

- Use `AppTheme.brandAccentColor(context)` — **never** a hardcoded `brandBlue`.
  This keeps the mobile accent (`#2c6ba4`) matched to the web admin dark theme.
- Use the shared **12-hour time format**, the shared **status-badge palette**, and
  **theme-aware (dark-mode-safe) colors**. Don't hardcode colors.

## Release

- CI: `.github/workflows/android-release.yml`. Push builds → Firebase App
  Distribution. The dispatch flow with `target=github` **promotes the exact
  already-tested APK** (no rebuild) to GitHub Releases — don't change it to
  rebuild. Tag pushes matching `v*` publish releases.
- Required secrets for full signing + distribution: `ANDROID_KEYSTORE_BASE64`,
  `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD`,
  `FIREBASE_SERVICE_ACCOUNT_JSON`, `FIREBASE_APP_DISTRIBUTION_GROUPS`.

## Do not

- Don't introduce iOS-specific assumptions — this client is Android-only.
- Don't commit `.dart-defines.local.json`, keystores, or Firebase secrets.
- Don't edit generated artifacts (`.dart_tool/`, build output).
