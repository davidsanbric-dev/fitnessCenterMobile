import 'package:fitnesscenter_mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Host app for widget tests.
///
/// Widgets resolve their copy through `AppLocalizations.of(context)`, so a bare
/// [MaterialApp] is not enough: without the delegates the lookup throws. This
/// also zeroes the theme animation, since [MaterialApp] lerps between themes
/// over 200ms and a single pump would otherwise sample a half-interpolated
/// colour.
Widget testApp(
  Widget child, {
  Brightness brightness = Brightness.light,
  Locale locale = const Locale('es'),
}) {
  return MaterialApp(
    locale: locale,
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    theme: ThemeData(brightness: brightness),
    themeAnimationDuration: Duration.zero,
    home: Scaffold(body: Column(children: [child])),
  );
}
