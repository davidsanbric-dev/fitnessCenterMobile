import 'package:fitnesscenter_mobile/app/config/app_theme.dart';
import 'package:fitnesscenter_mobile/app/core/shared/widgets/ui/error_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host({required Brightness brightness}) {
  // Deliberately not const: a const subtree is canonicalized, so pumping the
  // same tree twice would reuse the element and never rebuild under the new
  // theme, making the comparison below pass vacuously.
  //
  // themeAnimationDuration is zeroed because MaterialApp wraps the theme in an
  // AnimatedTheme: with the default 200ms lerp, reading colours on the frame
  // right after pumpWidget would sample a half-interpolated theme.
  return MaterialApp(
    theme: ThemeData(brightness: brightness),
    themeAnimationDuration: Duration.zero,
    home: Scaffold(body: ErrorBanner(message: 'No hay cupos')),
  );
}

Color _bannerBackground(WidgetTester tester) {
  final container = tester.widget<Container>(
    find.descendant(
      of: find.byType(ErrorBanner),
      matching: find.byType(Container),
    ),
  );
  return ((container.decoration as BoxDecoration).color)!;
}

void main() {
  testWidgets('shows the message', (tester) async {
    await tester.pumpWidget(_host(brightness: Brightness.light));

    expect(find.text('No hay cupos'), findsOneWidget);
  });

  testWidgets('uses a different danger tone per theme', (tester) async {
    await tester.pumpWidget(_host(brightness: Brightness.light));
    final light = _bannerBackground(tester);

    await tester.pumpWidget(_host(brightness: Brightness.dark));
    final dark = _bannerBackground(tester);

    // Regression guard: the banner used to paint a fixed Colors.red.shade50
    // block, which washed out light text in dark mode.
    expect(light, isNot(equals(dark)));
    expect(light.a, lessThan(1.0), reason: 'tint should be translucent');
    expect(dark.a, lessThan(1.0), reason: 'tint should be translucent');
  });

  testWidgets('derives its tone from the theme-aware danger colour', (
    tester,
  ) async {
    await tester.pumpWidget(_host(brightness: Brightness.dark));

    final context = tester.element(find.byType(ErrorBanner));
    final icon = tester.widget<Icon>(
      find.descendant(
        of: find.byType(ErrorBanner),
        matching: find.byType(Icon),
      ),
    );

    expect(icon.color, AppTheme.dangerColor(context));
  });

  testWidgets('announces itself to screen readers as a live region', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_host(brightness: Brightness.light));

    final semantics = tester.widget<Semantics>(
      find
          .descendant(
            of: find.byType(ErrorBanner),
            matching: find.byType(Semantics),
          )
          .first,
    );

    expect(semantics.properties.label, 'Error');
    expect(semantics.properties.liveRegion, isTrue);
    handle.dispose();
  });
}
