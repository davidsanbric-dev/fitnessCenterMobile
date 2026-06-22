import 'package:fitnesscenter_mobile/app/core/constants/app_assets.dart';

/// Critical startup policies — the timeouts and asset guarantees that define
/// what a healthy app launch means.
///
/// Centralized in the config layer (next to theme, routes and bindings) so
/// these tuning knobs read as named policy instead of magic values scattered
/// across the startup implementation. The startup module owns the behavior;
/// this owns the thresholds.
class StartupPolicy {
  const StartupPolicy._();

  /// Max wait for Firebase to initialize before startup is declared failed.
  static const Duration firebaseInitTimeout = Duration(seconds: 8);

  /// Max wait for each deferred startup step before it is abandoned, so a
  /// single slow service cannot stall the rest of startup.
  static const Duration stepTimeout = Duration(seconds: 8);

  /// Max wait when warming each critical asset into the bundle cache.
  static const Duration assetPreflightTimeout = Duration(seconds: 2);

  /// Assets warmed during startup so the first frame never blocks on disk I/O.
  static const List<String> criticalAssets = <String>[AppAssets.logo];
}
