# portfolio_mobile_app

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

