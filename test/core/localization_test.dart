import 'package:fitnesscenter_mobile/features/bookings/presentation/widgets/bookings_table.dart';
import 'package:fitnesscenter_mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fakes.dart';
import '../support/test_app.dart';

void main() {
  test('both locales are supported', () {
    expect(
      AppLocalizations.supportedLocales.map((l) => l.languageCode),
      containsAll(<String>['es', 'en']),
    );
  });

  testWidgets('bookings list renders in Spanish by default', (tester) async {
    await tester.pumpWidget(
      testApp(
        Expanded(
          child: BookingsTable(
            bookings: const [],
            isLoading: false,
            errorMessage: null,
            onBookSession: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Aún no tienes reservas.'), findsOneWidget);
    expect(find.text('Reservar una clase'), findsWidgets);
    expect(find.text('Horario'), findsOneWidget);
  });

  testWidgets('the same list renders in English under an en locale', (
    tester,
  ) async {
    await tester.pumpWidget(
      testApp(
        Expanded(
          child: BookingsTable(
            bookings: const [],
            isLoading: false,
            errorMessage: null,
            onBookSession: () {},
          ),
        ),
        locale: const Locale('en'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('You have no bookings yet.'), findsOneWidget);
    expect(find.text('Book a Session'), findsWidgets);
    expect(find.text('Time'), findsOneWidget);
  });

  testWidgets('row fallbacks are localized too', (tester) async {
    await tester.pumpWidget(
      testApp(
        Expanded(
          child: BookingsTable(
            bookings: [buildBooking(bookingId: 'bk-1', serviceName: null)],
            isLoading: false,
            errorMessage: null,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Used to read 'Not specified' regardless of locale.
    expect(find.text('Sin especificar'), findsOneWidget);
  });
}
