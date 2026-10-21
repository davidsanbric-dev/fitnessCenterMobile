import 'package:fitnesscenter_mobile/app/core/shared/widgets/ui/state_placeholder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_app.dart';

void main() {
  group('empty', () {
    testWidgets('shows the message and no retry', (tester) async {
      await tester.pumpWidget(
        testApp(
          const StatePlaceholder.empty(message: 'Aun no tienes reservas'),
        ),
      );

      expect(find.text('Aun no tienes reservas'), findsOneWidget);
      expect(find.byType(TextButton), findsNothing);
    });

    testWidgets('renders the offered next step', (tester) async {
      await tester.pumpWidget(
        testApp(
          StatePlaceholder.empty(
            message: 'Aun no tienes reservas',
            action: FilledButton(
              onPressed: () {},
              child: const Text('Reservar'),
            ),
          ),
        ),
      );

      expect(find.text('Reservar'), findsOneWidget);
    });
  });

  group('error', () {
    testWidgets('invokes onRetry when the retry button is tapped', (
      tester,
    ) async {
      var retries = 0;
      await tester.pumpWidget(
        testApp(
          StatePlaceholder.error(
            message: 'Sin conexion',
            onRetry: () => retries++,
          ),
        ),
      );

      // The host renders in es, the app's default locale.
      await tester.tap(find.text('Reintentar'));
      await tester.pump();

      expect(retries, 1);
    });

    testWidgets('omits the retry button when no handler is given', (
      tester,
    ) async {
      await tester.pumpWidget(
        testApp(const StatePlaceholder.error(message: 'Sin conexion')),
      );

      expect(find.text('Sin conexion'), findsOneWidget);
      expect(find.text('Reintentar'), findsNothing);
    });

    testWidgets('is announced as a live region, unlike the empty state', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(
        testApp(const StatePlaceholder.error(message: 'Sin conexion')),
      );
      final error = tester.widget<Semantics>(
        find
            .descendant(
              of: find.byType(StatePlaceholder),
              matching: find.byType(Semantics),
            )
            .first,
      );
      expect(error.properties.liveRegion, isTrue);

      await tester.pumpWidget(
        testApp(const StatePlaceholder.empty(message: 'Nada por aqui')),
      );
      final empty = tester.widget<Semantics>(
        find
            .descendant(
              of: find.byType(StatePlaceholder),
              matching: find.byType(Semantics),
            )
            .first,
      );
      // An empty list is not an event worth interrupting a screen reader for.
      expect(empty.properties.liveRegion, isFalse);

      handle.dispose();
    });
  });
}
