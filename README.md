# fitnesscenter_mobile

Flutter (**Android-only**) member client of the **FitnessCenter Suite**, alongside the FastAPI backend and the Nuxt.js admin web. Members browse the catalog, check live slot availability, book/cancel classes, manage their profile, and receive real-time push.

## Architecture

**MVVM on top of a feature-driven, clean architecture.** Each feature lives in `lib/features/<feature>` and is split into `data / domain / presentation`, with its own `di` (dependency injection) module wired through the GetX service locator:

- `auth`, `home`, `profile`
- `fitness_directory` — browsing entry point (disciplines, trainers, class types, memberships); owns directory flow state and delegates availability/booking.
- `available_slots_listing` — availability consultation (filters + slots by discipline/trainer or class type); owns listing/filter state and local availability sync.
- `class_booking` — reservation execution for standard and class-type bookings; centralizes booking requests, loading/error state, and post-booking agenda refresh.

The **presentation layer is built on ViewModels** (`ChangeNotifier`-based, see `lib/app/core/viewmodel`) that expose UI state and orchestrate domain use cases, keeping widgets thin and logic testable in isolation. Cross-feature rule: directory/listing screens never shape booking payloads directly — they call `class_booking` helpers and only do local UI updates.

### Backend & push integration

- REST over an authenticated client; the Firebase ID token is attached transparently to all requests.
- **Firebase Cloud Messaging**: the app registers its device token with the backend on sign-in, then receives push triggered by API events (blog publish, trainer announcements, booking status changes) with foreground/local notification handling.

## Tech stack

**Flutter · Dart · Firebase (Auth + Cloud Messaging)**

### State management

Three tools, each with one job:

| Concern | Tool |
| --- | --- |
| Routing, service location, navigation | GetX (`package:get`) |
| Feature state (MVVM) | `ChangeNotifier` view-models over `ViewModelBase` |
| Scoped, auto-disposing UI filter state | Riverpod |

Most feature state is a plain `ChangeNotifier` view-model read by a
`ListenableBuilder`, which keeps the logic testable without a framework and is
why the booking and cancel flows can be unit tested with simple fakes. GetX
covers routing and the service locator that wires each feature's `di` module.

Riverpod is used in exactly one place, the availability listing filters, where
`StateNotifierProvider.autoDispose.family` keyed by a scope id gives each
screen instance its own state that disposes with it. A single shared
`ChangeNotifier` in the locator would have to hand-roll that lifecycle.

Mixing three is a trade-off rather than a rule: the alternative was either
hand-rolling scoped disposal or pulling the whole app onto Riverpod for one
screen's benefit.

## Tests

```bash
flutter test
```

Unit tests cover the view-model logic behind the member booking flow: the
re-entrancy guard that prevents a double tap creating two reservations, the
cancel/confirm state machine and its guards, the local-status fallback when a
post-update refresh fails, and the rule that hides admin-only statuses from the
member picker. DTO tests cover the snake_case API contract mapping.

## Run on Android

```bash
flutter pub get
flutter run -d android
```

Optional cleanup of generated artifacts: `flutter clean`.

## Release workflow

CI lives at [.github/workflows/android-release.yml](.github/workflows/android-release.yml). It can:

- build the Android release APK once
- publish to GitHub Releases on tag pushes matching `v*`
- upload the same APK to Firebase App Distribution when Firebase secrets are present
- fall back to debug signing when no release keystore secrets are provided

Required secrets (full signing + distribution): `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD`, `FIREBASE_SERVICE_ACCOUNT_JSON`, `FIREBASE_APP_DISTRIBUTION_GROUPS`.

For manual runs: choose `firebase` to publish only to App Distribution, or `both` for Firebase + GitHub Releases (provide `release_tag` when `github` is included).
