import 'dart:async';

import 'package:get/get.dart';

import 'package:portfolio_mobile_app/app/core/auth/application/auth_api/auth_api.dart';
import 'package:portfolio_mobile_app/app/core/auth/infrastructure/auth_session_cache.dart';
import 'package:portfolio_mobile_app/app/core/auth/domain/auth_request.dart';
import 'package:portfolio_mobile_app/app/core/exceptions/api_exception.dart';
import 'package:portfolio_mobile_app/app/core/services/push_notification_service.dart';
import 'package:portfolio_mobile_app/app/core/shared/services/location_code_registry.dart';

class AuthService extends GetxService {
  AuthService({
    required AuthApi authApi,
    AuthSessionCache? cache,
    bool Function()? hasFirebaseSession,
    Future<Map<String, dynamic>?> Function()? restoreSessionFromFirebase,
  }) : _authApi = authApi,
       _cache = cache ?? AuthSessionCache(),
       _hasFirebaseSession =
           hasFirebaseSession ?? (() => authApi.hasFirebaseSession),
       _restoreSessionFromFirebase =
           restoreSessionFromFirebase ?? authApi.restoreSessionFromFirebase;

  // Keep cache + restore comfortably under the StartupManager's 8s per-step cap
  // so a slow/unreachable backend at startup falls back to login gracefully
  // instead of tripping the startup timeout (worst case here: 2s + 4s = 6s).
  static const Duration _startupRestoreTimeout = Duration(seconds: 4);
  static const Duration _cacheIoTimeout = Duration(seconds: 2);

  final AuthApi _authApi;
  final AuthSessionCache _cache;
  final bool Function() _hasFirebaseSession;
  final Future<Map<String, dynamic>?> Function() _restoreSessionFromFirebase;
  final _isLoggedIn = false.obs;
  final RxnString _role = RxnString();
  Map<String, dynamic>? _claims;

  bool get isLoggedIn => _isLoggedIn.value;
  RxBool get isLoggedInRx => _isLoggedIn;
  String? get role => _role.value;
  String? get mail => _claimAsString('mail');
  String? get userName => _claimAsString('userName');
  String? get userId => _claimAsString('userId');
  Map<String, dynamic>? get claims => _claims;

  Future<void> init() async {
    try {
      if (!_hasFirebaseSession()) {
        await _clearLocalSession();
        return;
      }

      final cachedUser = await _getCachedUserSafely();
      if (cachedUser != null && cachedUser.isNotEmpty) {
        final needsProfileRefresh = !_hasMemberDataInSession(cachedUser);
        if (needsProfileRefresh && _hasFirebaseSession()) {
          final refreshedClaims = await _restoreSessionFromFirebaseSafely();
          if (refreshedClaims != null && refreshedClaims.isNotEmpty) {
            await _setSession(claims: refreshedClaims);
            return;
          }
        }
        await _setSession(claims: cachedUser);
        return;
      }

      final claims = await _restoreSessionFromFirebaseSafely();
      if (claims != null && claims.isNotEmpty) {
        await _setSession(claims: claims);
        return;
      }

      await _clearLocalSession(clearCache: false);
    } catch (_) {
      await _clearLocalSession();
    }
  }

  Future<Map<String, dynamic>?> _restoreSessionFromFirebaseSafely() async {
    try {
      return await _restoreSessionFromFirebase().timeout(
        _startupRestoreTimeout,
        onTimeout: () => null,
      );
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> _getCachedUserSafely() async {
    try {
      return await _cache.getUser().timeout(
        _cacheIoTimeout,
        onTimeout: () => null,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final session = await _authApi.login(
        request: AuthRequest(mail: email, password: password),
      );
      final claims = Map<String, dynamic>.from(session.claims);
      await _setSession(claims: claims);
    } on ApiException {
      await _clearLocalSession();
      rethrow;
    } catch (error) {
      await _clearLocalSession();
      rethrow;
    }
  }

  /// Sends another verification email to the signed-in (but unverified) user.
  Future<void> resendEmailVerification() {
    return _authApi.resendEmailVerification();
  }

  /// Re-checks email verification; on success completes the app session and
  /// returns `true`. Returns `false` while the email remains unverified.
  Future<bool> retryEmailVerification() async {
    final verified = await _authApi.refreshEmailVerified();
    if (!verified) {
      return false;
    }
    final claims = await _authApi.completeSessionForCurrentUser();
    await _setSession(claims: Map<String, dynamic>.from(claims));
    return true;
  }

  /// Abandons a paused email-verification login and clears the session.
  Future<void> cancelEmailVerification() {
    return logout();
  }

  Future<void> logout() async {
    try {
      await _authApi.logout();
    } catch (_) {
      // Ignore backend logout errors and always clear locally.
    }
    await _clearLocalSession(clearCache: false);
  }

  Future<void> _setSession({required Map<String, dynamic> claims}) async {
    _claims = claims;
    _updateRole();
    _isLoggedIn.value = true;
    // Register this device's push token now that a session exists, so the user
    // receives company-scoped notifications (e.g. new blog posts).
    if (Get.isRegistered<PushNotificationService>()) {
      unawaited(Get.find<PushNotificationService>().registerCurrentToken());
    }
  }

  Future<void> _clearLocalSession({bool clearCache = true}) async {
    if (clearCache) {
      try {
        await _cache.clearSession().timeout(_cacheIoTimeout);
      } catch (_) {
        // Ignore secure storage cleanup failures during startup recovery.
      }
    }
    _claims = null;
    _role.value = null;
    _isLoggedIn.value = false;
    // Drop the previous company's /statics location codes on session teardown.
    LocationCodeRegistry.instance.clear();
    // Stop receiving the previous session's company push notifications.
    if (Get.isRegistered<PushNotificationService>()) {
      unawaited(Get.find<PushNotificationService>().clearToken());
    }
  }

  void _updateRole() {
    _role.value = _claimAsString('roleName')?.trim();
  }

  String? _claimAsString(String key) {
    final value = _claims?[key];

    if (value == null) return null;
    if (value is String) return value;

    return value.toString();
  }

  bool _hasMemberDataInSession(Map<String, dynamic> claims) {
    final details = claims['details'];
    if (details is Map && details.isNotEmpty) {
      return true;
    }

    final memberId = claims['memberId']?.toString().trim();
    if (memberId != null && memberId.isNotEmpty) {
      return true;
    }

    final firstName = claims['firstName']?.toString().trim();
    return firstName != null && firstName.isNotEmpty;
  }
}
