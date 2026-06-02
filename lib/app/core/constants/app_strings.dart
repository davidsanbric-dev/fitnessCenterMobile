import 'package:flutter/foundation.dart';

mixin AppStrings {
  static const String brandName = 'FitnessCenter';
  static const String slogan = 'now even closer to you';
  static const String loadWelcomeTitle = 'Welcome!';
  static const String loadWelcomeSubtitle = 'Enter your email to continue';
  static const String _baseUrlRaw = String.fromEnvironment('BASE_URL');

  static String get baseUrl {
    final trimmed = _baseUrlRaw.trim();
    if (trimmed.isEmpty) {
      if (kReleaseMode) {
        throw StateError(
          'BASE_URL is not configured. Pass --dart-define=BASE_URL=<value>.',
        );
      }
      return _defaultDebugBaseUrl();
    }
    final normalized = _normalizeConfiguredBaseUrl(trimmed);
    return _mapAndroidLoopback(normalized);
  }

  static String _defaultDebugBaseUrl() {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000';
    }
    return 'http://127.0.0.1:8000';
  }

  static String _normalizeConfiguredBaseUrl(String value) {
    if (value.endsWith('/')) {
      return value.substring(0, value.length - 1);
    }
    return value;
  }

  static String _mapAndroidLoopback(String url) {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return url;
    }

    final uri = Uri.tryParse(url);
    if (uri == null) {
      return url;
    }

    final host = uri.host.toLowerCase();
    if (host != '127.0.0.1' && host != 'localhost') {
      return url;
    }

    return uri.replace(host: '10.0.2.2').toString();
  }
}
