import 'package:firebase_auth/firebase_auth.dart';

abstract class FirebaseAuthExceptionMapper {
  String map(FirebaseAuthException exception);
}

class DefaultFirebaseAuthExceptionMapper
    implements FirebaseAuthExceptionMapper {
  const DefaultFirebaseAuthExceptionMapper();

  @override
  String map(FirebaseAuthException exception) {
    switch (exception.code) {
      case 'user-not-found':
        return 'No account exists with that email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'weak-password':
        return 'The password is too weak.';
      case 'invalid-credential':
      case 'invalid-login-credentials':
        return 'Incorrect email or password.';
      case 'invalid-verification-code':
        return 'Invalid SMS code.';
      case 'invalid-verification-id':
        return 'Verification expired. Request a new code.';
      case 'missing-verification-code':
        return 'Enter the SMS code.';
      case 'missing-verification-id':
        return 'Missing verification identifier.';
      case 'session-expired':
        return 'Verification session expired. Request a new code.';
      case 'invalid-phone-number':
        return 'Invalid phone number.';
      case 'missing-phone-number':
        return 'Phone number is required.';
      case 'quota-exceeded':
        return 'SMS sending limit reached. Try again later.';
      case 'captcha-check-failed':
        return 'Security verification failed. Please try again.';
      case 'invalid-app-credential':
        return 'Could not validate this app for SMS. Check Firebase configuration.';
      case 'app-not-authorized':
        return 'This app is not authorized to use Firebase Auth in this project.';
      case 'missing-client-identifier':
        return 'Missing client configuration for SMS verification.';
      case 'network-request-failed':
        return 'No network connection. Check your internet and try again.';
      case 'requires-recent-login':
        return 'Sign in again to complete this action.';
      case 'operation-requires-verified-email':
        return 'You must verify your email before enabling SMS.';
      case 'invalid-email':
        return 'Invalid email format.';
      case 'user-disabled':
        return 'This account is disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      case 'operation-not-allowed':
        return 'Email/password sign-in is not enabled.';
      case 'expired-action-code':
        return 'The link has expired.';
      case 'invalid-action-code':
        return 'The link is not valid.';
      case 'missing-email':
        return 'Email is required.';
      case 'missing-continue-uri':
        return 'Missing continue URL.';
      case 'unauthorized-continue-uri':
        return 'The continue URL is not authorized.';
      default:
        return exception.message ??
            'Could not sign in. Code: ${exception.code}';
    }
  }
}
