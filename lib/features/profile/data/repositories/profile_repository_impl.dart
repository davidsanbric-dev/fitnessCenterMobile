import 'package:fitnesscenter_mobile/app/core/auth/auth.dart';
import 'package:fitnesscenter_mobile/features/profile/domain/domain.dart';
import 'package:get/get.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl({AuthApi? authApi})
    : _authApi = authApi ?? _resolveAuthApi();

  final AuthApi _authApi;

  // Prefer the session-scoped AuthApi already registered at sign-in so cached
  // claims resolve against the live session; fall back to a fresh instance.
  static AuthApi _resolveAuthApi() {
    if (Get.isRegistered<AuthApi>()) {
      return Get.find<AuthApi>();
    }
    return AuthApi();
  }

  @override
  Future<Map<String, dynamic>?> getCachedUser() => _authApi.getCachedUser();

  @override
  bool get hasFirebaseSession => _authApi.hasFirebaseSession;

  @override
  Future<Map<String, dynamic>?> restoreSessionFromFirebase() =>
      _authApi.restoreSessionFromFirebase();
}
