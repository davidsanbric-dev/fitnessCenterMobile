class StartupException implements Exception {
  const StartupException(this.message);

  final String message;

  /// Heading shown on the startup failure screen.
  static const String title = 'Startup failed';

  /// Supporting copy shown beneath the heading on the startup failure screen.
  static const String description =
      'The app could not finish startup configuration.';

  @override
  String toString() => 'StartupException: $message';
}

/// Raised when Firebase cannot be initialized during critical startup.
///
/// `BootstrapApp` blocks the app from rendering until Firebase is ready; if it
/// times out or fails, this surfaces on the `StartupFailureApp` screen.
class FirebaseInitializationException extends StartupException {
  const FirebaseInitializationException()
    : super('Firebase initialization failed during startup');
}
