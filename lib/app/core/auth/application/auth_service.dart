import 'dart:async';

import 'package:portfolio_mobile_app/app/core/auth/domain/types.dart';
import 'package:get/get.dart';

import 'package:portfolio_mobile_app/app/core/auth/application/auth_api/auth_api.dart';
import 'package:portfolio_mobile_app/app/core/auth/infrastructure/auth_session_cache.dart';
import 'package:portfolio_mobile_app/app/core/auth/domain/auth_request.dart';
import 'package:portfolio_mobile_app/app/core/exceptions/api_exception.dart';

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

  static const Duration _mfaSendUiTimeout = Duration(seconds: 90);
  static const Duration _startupRestoreTimeout = Duration(seconds: 5);
  static const Duration _cacheIoTimeout = Duration(seconds: 2);

  final AuthApi _authApi;
  final AuthSessionCache _cache;
  final bool Function() _hasFirebaseSession;
  final Future<Map<String, dynamic>?> Function() _restoreSessionFromFirebase;
  final _isLoggedIn = false.obs;
  final RxnString _role = RxnString();
  Map<String, dynamic>? _claims;
  MfaSignInContext? _mfaContext;

  bool get isLoggedIn => _isLoggedIn.value;
  String? get role => _role.value;
  String? get mail => _claimAsString('mail');
  String? get userName => _claimAsString('userName');
  String? get userId => _claimAsString('userId');
  Map<String, dynamic>? get claims => _claims;
  String? get mfaPhoneNumber => _mfaContext?.phoneNumber;
  bool get hasMfaChallenge => _mfaContext != null;

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

  Future<bool> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _authApi.login(
        request: AuthRequest(mail: email, password: password),
      );
      if (result is AuthLoginMfaRequired) {
        _clearMfaContext();
        _mfaContext = MfaSignInContext(
          challengeId: result.challengeId,
          phoneNumber: result.phoneNumber,
        );
        return true;
      }

      final session = (result as AuthLoginSuccess).session;
      final claims = Map<String, dynamic>.from(session.claims);
      await _setSession(claims: claims);
      _clearMfaContext();
      return false;
    } on ApiException {
      await _clearLocalSession();
      rethrow;
    } catch (error) {
      await _clearLocalSession();
      rethrow;
    }
  }

  Future<MfaCodeDelivery> sendMfaSignInCode({bool resend = false}) async {
    final context = _requireMfaContext();
    final delivery =
        await _sendMfaSignInCodeWithFallback(
          context: context,
          resend: resend,
        ).timeout(
          _mfaSendUiTimeout,
          onTimeout: () => throw const ApiException(
            'Timed out while requesting the SMS code. Please try again.',
          ),
        );
    context.verificationId = delivery.verificationId;
    context.resendToken = delivery.resendToken;
    return delivery;
  }

  Future<void> confirmMfaSignIn({required String smsCode}) async {
    final context = _requireMfaContext();
    final verificationId = context.verificationId;
    if (verificationId == null || verificationId.isEmpty) {
      throw const ApiException('Request the SMS code first.');
    }
    final session = await _authApi.resolveMfaSignIn(
      challengeId: context.challengeId,
      verificationId: verificationId,
      smsCode: smsCode,
    );
    final claims = Map<String, dynamic>.from(session.claims);
    await _setSession(claims: claims);
    _clearMfaContext();
  }

  void cancelMfaSignIn() {
    _clearMfaContext();
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
    _clearMfaContext();
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

  MfaSignInContext _requireMfaContext() {
    final context = _mfaContext;
    if (context == null) {
      throw const ApiException('No hay un desafio MFA activo.');
    }
    return context;
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

  Future<MfaCodeDelivery> _sendMfaSignInCodeWithFallback({
    required MfaSignInContext context,
    required bool resend,
  }) async {
    return _authApi.sendMfaSignInCode(challengeId: context.challengeId);
  }

  void _clearMfaContext() {
    final context = _mfaContext;
    if (context != null) {
      _authApi.discardMfaSignInChallenge(challengeId: context.challengeId);
    }
    _mfaContext = null;
  }
}
