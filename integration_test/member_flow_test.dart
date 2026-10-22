// End-to-end walkthrough of the member flow, doubling as the script for the
// demo recording (see tool/record_demo.sh).
//
// Credentials are never hardcoded: pass them at run time.
//
//   flutter test integration_test/member_flow_test.dart \
//     --dart-define-from-file=.dart-defines.local.json \
//     --dart-define=DEMO_EMAIL=... --dart-define=DEMO_PASSWORD=...
//
// The deliberate pauses exist so the recording is followable at normal speed.
// Set --dart-define=DEMO_PACING=0 to run it as a fast CI check instead.
//
// The flow drives real controls by key (see `booking-mode-*`, `catalog-option-*`
// and `reserve-slot-*`) rather than by label, so it survives both copy changes
// and a change of locale. It books a real class against the demo tenant and
// cancels it again, leaving the tenant as it found it.

import 'package:fitnesscenter_mobile/app/core/startup/bootstrap_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

const String _email = String.fromEnvironment('DEMO_EMAIL');
const String _password = String.fromEnvironment('DEMO_PASSWORD');

/// Milliseconds held at each step so a viewer can follow along. Zeroed in CI.
const int _pacingMs = int.fromEnvironment('DEMO_PACING', defaultValue: 1200);

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  /// Pumps for [ms], tolerating the app's always-running animations.
  ///
  /// `pumpAndSettle` is unsafe here: the brand header and page transitions keep
  /// a ticker alive, so settling can time out rather than return. Pumping a
  /// bounded number of frames is both adequate and deterministic.
  Future<void> settle(WidgetTester tester, {int ms = 1500}) async {
    final deadline = DateTime.now().add(Duration(milliseconds: ms));
    while (DateTime.now().isBefore(deadline)) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  Future<void> beat(WidgetTester tester) => settle(tester, ms: _pacingMs);

  /// Taps the first match of [finder] once it appears, polling up to [timeout].
  ///
  /// Every step here waits on a network round trip, so a fixed sleep would
  /// either be flaky or needlessly slow.
  Future<void> tapWhenReady(
    WidgetTester tester,
    Finder finder, {
    required String describe,
    int timeoutMs = 20000,
  }) async {
    final deadline = DateTime.now().add(Duration(milliseconds: timeoutMs));
    while (DateTime.now().isBefore(deadline)) {
      if (finder.evaluate().isNotEmpty) {
        await beat(tester);
        await tester.tap(finder.first);
        await settle(tester, ms: 1200);
        return;
      }
      await tester.pump(const Duration(milliseconds: 200));
    }
    fail('timed out waiting for $describe');
  }

  Future<bool> appears(
    WidgetTester tester,
    Finder finder, {
    int timeoutMs = 20000,
  }) async {
    final deadline = DateTime.now().add(Duration(milliseconds: timeoutMs));
    while (DateTime.now().isBefore(deadline)) {
      if (finder.evaluate().isNotEmpty) return true;
      await tester.pump(const Duration(milliseconds: 200));
    }
    return false;
  }

  testWidgets('member signs in, books a class, then cancels it', (
    tester,
  ) async {
    expect(
      _email.isNotEmpty && _password.isNotEmpty,
      isTrue,
      reason:
          'Pass --dart-define=DEMO_EMAIL and --dart-define=DEMO_PASSWORD. '
          'Credentials are deliberately not committed.',
    );

    await tester.pumpWidget(const ProviderScope(child: BootstrapApp()));
    await settle(tester, ms: 6000); // Firebase init + session restore.

    // ---------------------------------------------------------------- sign in
    final fields = find.byType(TextFormField);
    expect(
      fields,
      findsNWidgets(2),
      reason: 'expected the email and password fields on the login screen',
    );

    await tester.enterText(fields.at(0), _email);
    await beat(tester);
    await tester.enterText(fields.at(1), _password);
    await beat(tester);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await settle(tester, ms: 500);

    await tapWhenReady(
      tester,
      find.text('Iniciar sesión'),
      describe: 'the sign-in button',
    );

    // Firebase sign-in, then the backend profile/bootstrap calls.
    await settle(tester, ms: 12000);
    expect(
      find.text('Iniciar sesión'),
      findsNothing,
      reason:
          'still on the login screen: check the credentials and that the API '
          'is reachable',
    );
    await beat(tester);

    // ------------------------------------------------------- open My Bookings
    await tapWhenReady(
      tester,
      find.text('Reservas'),
      describe: 'the bookings tab',
    );
    expect(find.text('Mis reservas'), findsWidgets);
    await beat(tester);

    // --------------------------------------------------------- book a class
    await tapWhenReady(
      tester,
      find.text('Reservar una clase'),
      describe: 'the book-a-session call to action',
    );

    // Pick the class-type route: fewer steps and it exercises the capability
    // endpoints rather than the trainer search field.
    await tapWhenReady(
      tester,
      find.byKey(const Key('booking-mode-class-type')),
      describe: 'the "by class type" option',
    );

    // Category, then subcategory, then the class type: each stage renders the
    // same keyed card grid, one at a time. Driven as a loop rather than a fixed
    // count because a stage with a single option can resolve itself, and the
    // depth differs between catalogs.
    final reserve = find.byWidgetPredicate(
      (w) =>
          w.key is ValueKey<String> &&
          (w.key as ValueKey<String>).value.startsWith('reserve-slot-'),
    );
    final catalogOption = find.byKey(const ValueKey('catalog-option-0'));

    for (var depth = 0; depth < 5; depth++) {
      if (await appears(tester, reserve, timeoutMs: 2500)) break;
      if (!await appears(tester, catalogOption, timeoutMs: 15000)) {
        fail('stage $depth offered neither a catalog option nor a slot');
      }
      await beat(tester);
      await tester.tap(catalogOption.first);
      await settle(tester, ms: 2500);
    }
    expect(
      await appears(tester, reserve, timeoutMs: 25000),
      isTrue,
      reason:
          'no bookable slot appeared. The demo timetable is seeded relative to '
          'the seed date; run reset_demo_tenant.py if it has aged out.',
    );
    await beat(tester);
    await tester.tap(reserve.first);

    // The booking POST, then the agenda refresh it triggers.
    await settle(tester, ms: 8000);
    await beat(tester);

    // ------------------------------------------------- confirm it is listed
    // The booking flow runs *inside* the Bookings tab, so tapping the tab again
    // does nothing; the flow is left via the header's back control, one stage
    // at a time, until the bookings table is showing.
    final back = find.byKey(const Key('page-header-back'));
    final bookingRow = find.byTooltip('Acciones de la fila');
    for (var i = 0; i < 6 && back.evaluate().isNotEmpty; i++) {
      await tester.tap(back.first);
      await settle(tester, ms: 1500);
      if (bookingRow.evaluate().isNotEmpty) break;
    }
    await settle(tester, ms: 4000);

    expect(
      find.text('Aún no tienes reservas.'),
      findsNothing,
      reason: 'the new booking should have replaced the empty state',
    );
    await beat(tester);

    // ------------------------------------------------------------- cancel it
    final rowActions = bookingRow;
    expect(
      await appears(tester, rowActions),
      isTrue,
      reason: 'the row action menu was not found on the bookings table',
    );

    // Cancel is only offered for a pending or confirmed booking, so walk the
    // rows until one offers it rather than assuming the first does. A demo
    // tenant accumulates already-cancelled rows from earlier runs.
    final cancelEntry = find.text('ANULAR RESERVA');
    var cancelled = false;
    for (var row = 0; row < rowActions.evaluate().length; row++) {
      await beat(tester);
      await tester.tap(rowActions.at(row));
      await settle(tester, ms: 1500);
      if (cancelEntry.evaluate().isNotEmpty) {
        await beat(tester);
        await tester.tap(cancelEntry.first);
        await settle(tester, ms: 1500);
        cancelled = true;
        break;
      }
      // Not cancellable: dismiss the menu and try the next row.
      await tester.tapAt(const Offset(10, 10));
      await settle(tester, ms: 800);
    }
    expect(
      cancelled,
      isTrue,
      reason:
          'no booking offered a cancel action. Every row was already cancelled '
          'or completed; run reset_demo_tenant.py to clear the tenant.',
    );

    // The status update, then the list refresh.
    await settle(tester, ms: 6000);
    await beat(tester);

    // The row's status badge is the durable signal: the snackbar may have
    // dismissed itself by the time the list has refreshed.
    expect(
      await appears(tester, find.text('Anulada'), timeoutMs: 15000),
      isTrue,
      reason: 'expected the booking to read as cancelled in the list',
    );
    await beat(tester);
  });
}
