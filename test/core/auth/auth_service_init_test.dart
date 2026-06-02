import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio_mobile_app/app/core/auth/application/auth_api/auth_api.dart';
import 'package:portfolio_mobile_app/app/core/auth/application/auth_service.dart';
import 'package:portfolio_mobile_app/app/core/auth/infrastructure/auth_dependencies.dart';
import 'package:portfolio_mobile_app/app/core/auth/infrastructure/auth_session_cache.dart';

void main() {
  group('AuthService.init', () {
    test(
      'falls back to cached session when remote restore hangs',
      () async {
        final cache = _FakeAuthSessionCache(
          user: <String, dynamic>{
            'mail': 'cached@example.com',
            'roleName': 'patient',
          },
        );
        final service = AuthService(
          authApi: _unusedAuthApi(),
          cache: cache,
          hasFirebaseSession: () => true,
          restoreSessionFromFirebase: () =>
              Completer<Map<String, dynamic>?>().future,
        );

        final stopwatch = Stopwatch()..start();
        await service.init();
        stopwatch.stop();

        expect(service.isLoggedIn, isTrue);
        expect(service.mail, 'cached@example.com');
        expect(service.role, 'patient');
        expect(stopwatch.elapsed, lessThan(const Duration(seconds: 7)));
      },
      timeout: const Timeout(Duration(seconds: 10)),
    );

    test(
      'completes and stays logged out when no cache and restore hangs',
      () async {
        final cache = _FakeAuthSessionCache(user: null);
        final service = AuthService(
          authApi: _unusedAuthApi(),
          cache: cache,
          hasFirebaseSession: () => true,
          restoreSessionFromFirebase: () =>
              Completer<Map<String, dynamic>?>().future,
        );

        final stopwatch = Stopwatch()..start();
        await service.init();
        stopwatch.stop();

        expect(service.isLoggedIn, isFalse);
        expect(service.claims, isNull);
        expect(cache.clearSessionCalls, 0);
        expect(stopwatch.elapsed, lessThan(const Duration(seconds: 7)));
      },
      timeout: const Timeout(Duration(seconds: 10)),
    );
  });
}

AuthApi _unusedAuthApi() {
  return AuthApi(firebaseAuthGateway: _TestFirebaseAuthGateway());
}

class _FakeAuthSessionCache extends AuthSessionCache {
  _FakeAuthSessionCache({required Map<String, dynamic>? user}) : _user = user;

  Map<String, dynamic>? _user;
  int clearSessionCalls = 0;

  @override
  Future<Map<String, dynamic>?> getUser() async => _user;

  @override
  Future<void> clearSession() async {
    clearSessionCalls += 1;
    _user = null;
  }
}

class _TestFirebaseAuthGateway implements FirebaseAuthGateway {
  @override
  User? get currentUser => null;

  @override
  bool get hasSession => false;

  @override
  Future<void> applyActionCode({required String code}) {
    throw UnimplementedError();
  }

  @override
  Future<ActionCodeInfo> checkActionCode({required String code}) {
    throw UnimplementedError();
  }

  @override
  Future<void> confirmPasswordReset({
    required String code,
    required String newPassword,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> sendPasswordResetEmail({
    required String email,
    ActionCodeSettings? actionCodeSettings,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() {
    throw UnimplementedError();
  }

  @override
  Future<String> verifyPasswordResetCode({required String code}) {
    throw UnimplementedError();
  }

  @override
  Future<void> withSecondaryAuth(SecondaryAuthAction action) {
    throw UnimplementedError();
  }
}
