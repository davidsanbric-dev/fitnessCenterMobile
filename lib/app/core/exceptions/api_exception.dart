class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => 'ApiException: $message';
}

/// Raised when a Firebase user signs in but has not verified their email.
///
/// The Firebase-only backend rejects unverified ID tokens with `403`, so the
/// client blocks the session before calling protected endpoints and offers a
/// "resend verification email" path (spec §5.2 / §6).
class EmailNotVerifiedException extends ApiException {
  const EmailNotVerifiedException({required this.email})
    : super('Email not verified');

  final String email;
}
