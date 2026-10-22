import 'package:fitnesscenter_mobile/app/core/shared/widgets/ui/error_banner.dart';
import 'package:fitnesscenter_mobile/app/core/shared/widgets/ui/state_placeholder.dart';
import 'package:fitnesscenter_mobile/features/bookings/presentation/widgets/bookings_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fakes.dart';
import '../support/test_app.dart';

/// Accessibility guardrails for the screens in the member demo flow.
///
/// These use Flutter's own guideline matchers, so they fail the build when a
/// tap target shrinks below the platform minimum or an interactive control
/// loses its label, rather than relying on anyone remembering to check.

void main() {
  testWidgets('bookings list meets tap target and label guidelines', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();

    await tester.pumpWidget(
      testApp(
        Expanded(
          child: BookingsTable(
            bookings: [
              buildBooking(bookingId: 'bk-1', state: 'RESERVADA'),
              buildBooking(bookingId: 'bk-2', state: 'CONFIRMADA'),
            ],
            isLoading: false,
            errorMessage: null,
            onViewDetails: (_, __) async {},
            onCancelReservation: (_, __) async {},
            onBookSession: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));

    handle.dispose();
  });

  testWidgets('empty bookings state keeps its call to action reachable', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();

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

    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));

    handle.dispose();
  });

  testWidgets('failed load offers a retry that meets tap target guidelines', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();

    await tester.pumpWidget(
      testApp(
        Expanded(
          child: StatePlaceholder.error(
            message: 'Sin conexion',
            onRetry: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));

    handle.dispose();
  });

  testWidgets('error banner text meets contrast guidelines in both themes', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();

    for (final brightness in Brightness.values) {
      await tester.pumpWidget(
        testApp(ErrorBanner(message: 'No hay cupos'), brightness: brightness),
      );
      await tester.pumpAndSettle();

      await expectLater(tester, meetsGuideline(textContrastGuideline));
    }

    handle.dispose();
  });
}
