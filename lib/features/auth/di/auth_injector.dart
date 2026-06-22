import 'package:fitnesscenter_mobile/app/core/di/locator.dart';
import 'package:fitnesscenter_mobile/features/auth/feature.dart';

class AuthInjector {
  /// Returns the shared login view-model, registering it on first use.
  /// Idempotent so the login form (via [SharedViewModelHost]) binds to one
  /// instance and tears it down on dispose.
  static AuthViewModel getAuthViewModel() => getOrPut(AuthViewModel.new);
}
