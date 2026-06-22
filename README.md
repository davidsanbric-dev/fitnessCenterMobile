# fitnesscenter_mobile

Flutter app configured for **Android-only** mobile support.

## Run on Android

```bash
flutter pub get
flutter run -d android
```

## Cleanup generated files (optional)

To reduce local project size, you can remove generated artifacts:

```bash
flutter clean
```

## Release workflow

The repository includes a GitHub Actions workflow at [.github/workflows/android-release.yml](.github/workflows/android-release.yml).

It can:

- build the Android release APK once
- publish the APK to GitHub Releases on tag pushes that match `v*`
- upload the same APK to Firebase App Distribution when the Firebase secrets are present
- fall back to debug signing when no release keystore secrets are provided

Required secrets for full release signing and Firebase distribution:

- `ANDROID_KEYSTORE_BASE64`
- `ANDROID_KEYSTORE_PASSWORD`
- `ANDROID_KEY_ALIAS`
- `ANDROID_KEY_PASSWORD`
- `FIREBASE_SERVICE_ACCOUNT_JSON`
- `FIREBASE_APP_DISTRIBUTION_GROUPS`

For manual runs, choose `firebase` to publish only to App Distribution, or `both` to publish to Firebase and GitHub Releases. When `github` is included, provide `release_tag`.

## Appointment/Class Booking Architecture (Fitness scope)

Current fitness booking-related features are separated by responsibility:

- `lib/features/fitness_directory`
	- Browsing entry point (disciplines, trainers, class types, memberships).
	- Handles directory flow state and delegates availability/booking behavior.

- `lib/features/available_slots_listing`
	- Availability consultation feature (filters + slots by discipline/trainer, class type, online).
	- Owns listing/filter state and local availability table synchronization.

- `lib/features/class_booking`
	- Reservation execution feature for both standard and class-type bookings.
	- Centralizes booking requests, booking error/loading state, and post-booking agenda refresh.

Integration rule used by the app:

- Directory/listing screens do not shape booking API payloads directly.
- Screens call booking flow helpers from `class_booking` and only perform local UI updates (for example, removing the booked slot from current in-memory results).

Notes about scope:

- This architecture keeps the current fitness center behavior unchanged.
- No incremental date-window pagination or extra availability expansion logic was added.

