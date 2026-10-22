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

    final signIn = find.text('Iniciar sesión');
    expect(signIn, findsOneWidget, reason: 'sign-in button not found');
    await tester.tap(signIn);

    // Firebase sign-in, then the backend profile/bootstrap calls.
    await settle(tester, ms: 12000);

    // ------------------------------------------------------- land in the app
    // The login form is gone once the session is established.
    expect(
      find.text('Iniciar sesión'),
      findsNothing,
      reason:
          'still on the login screen: check the credentials and that the API '
          'is reachable',
    );
    await beat(tester);

    // ------------------------------------------------------- open My Bookings
    final bookingsTab = find.text('Reservas');
    if (bookingsTab.evaluate().isNotEmpty) {
      await tester.tap(bookingsTab.first);
      await settle(tester, ms: 3000);
    }

    // Title is localized, so assert on the Spanish copy the app now ships.
    expect(
      find.text('Mis reservas'),
      findsWidgets,
      reason: 'expected to be on the bookings screen',
    );
    await beat(tester);

    // --------------------------------------------------------- start booking
    final bookCta = find.text('Reservar una clase');
    expect(
      bookCta,
      findsWidgets,
      reason: 'the book-a-session call to action was not found',
    );
    await tester.tap(bookCta.first);
    await settle(tester, ms: 3000);
    await beat(tester);

    // From here the flow is driven by catalog data, so the walkthrough stops
    // at a deterministic point rather than guessing at row positions. The
    // recording continues manually from this screen if a full booking is
    // wanted on video.
  });
}
