part of 'auth_api/auth_api.dart';

class EnsureRegisterEmailSessionUseCase {
  EnsureRegisterEmailSessionUseCase({required AuthApi authApi})
    : _authApi = authApi;

  final AuthApi _authApi;

  Future<void> call({required String email}) async {
    final normalizedEmail = _authApi._requireEmail(email);
    final normalizedKey = normalizedEmail.toLowerCase();
    final currentUser = _authApi._firebaseAuthGateway.currentUser;

    if (currentUser != null) {
      final currentEmail = currentUser.email?.trim().toLowerCase();
      if (currentEmail == normalizedKey) {
        try {
          await currentUser.reload();
          final refreshedUser = _authApi._firebaseAuthGateway.currentUser;
          final refreshedEmail = refreshedUser?.email?.trim().toLowerCase();
          if (refreshedUser != null && refreshedEmail == normalizedKey) {
            await _authApi._cacheSessionForUserWithFallback(refreshedUser);
            return;
          }
        } on FirebaseAuthException catch (error) {
          if (!_canRecoverRegisterSession(error.code)) {
            throw ApiException(_authApi._firebaseErrorMapper.map(error));
          }
        } catch (error) {
          throw ApiException('Internal error: $error');
        }
      }
      await _authApi._safeSignOut();
    }

    final bootstrapPassword = _getOrCreateRegisterBootstrapPassword(
      normalizedKey,
    );

    Future<void> signInWithBootstrapPassword() async {
      final credential = await _authApi._firebaseAuthGateway
          .signInWithEmailAndPassword(
            email: normalizedEmail,
            password: bootstrapPassword,
          );
      final signedInUser = credential.user;
      if (signedInUser == null) {
        throw const ApiException(
          'Could not establish the registration session in Firebase.',
        );
      }
      await _authApi._cacheSessionForUserWithFallback(signedInUser);
    }

    try {
      await signInWithBootstrapPassword();
      return;
    } on FirebaseAuthException catch (error) {
      if (!_canBootstrapFromSignInError(error.code)) {
        throw ApiException(_authApi._firebaseErrorMapper.map(error));
      }
    } catch (error) {
      throw ApiException('Internal error: $error');
    }

    try {
      await _authApi.createFirebaseUser(
        email: normalizedEmail,
        password: bootstrapPassword,
      );
      await signInWithBootstrapPassword();
    } on FirebaseAuthException catch (error) {
      if (_canBootstrapFromSignInError(error.code)) {
        try {
          await Future<void>.delayed(const Duration(milliseconds: 350));
          await signInWithBootstrapPassword();
          return;
        } on FirebaseAuthException catch (retryError) {
          throw ApiException(_authApi._firebaseErrorMapper.map(retryError));
        } catch (retryError) {
          throw ApiException('Internal error: $retryError');
        }
      }
      throw ApiException(_authApi._firebaseErrorMapper.map(error));
    } on ApiException catch (error) {
      final lower = error.message.toLowerCase();
      if (lower.contains('already registered') ||
          lower.contains('ya está registrado') ||
          lower.contains('already-in-use')) {
        throw const ApiException(
          'This email is already registered. Sign in or recover your password.',
        );
      }
      rethrow;
    } catch (error) {
      throw ApiException('Internal error: $error');
    }
  }

  bool _canBootstrapFromSignInError(String code) {
    final normalized = normalizeAuthCode(code);
    return normalized == 'user-not-found' ||
        normalized == 'invalid-credential' ||
        normalized == 'invalid-login-credentials';
  }

  bool _canRecoverRegisterSession(String code) {
    final normalized = normalizeAuthCode(code);
    return normalized == 'user-not-found' ||
        normalized == 'invalid-user-token' ||
        normalized == 'user-token-expired' ||
        normalized == 'user-disabled' ||
        normalized == 'invalid-credential' ||
        normalized == 'invalid-login-credentials';
  }
}

class EnsureRegisterUserCredentialsUseCase {
  EnsureRegisterUserCredentialsUseCase({
    required AuthApi authApi,
    EnsureRegisterEmailSessionUseCase? ensureRegisterEmailSessionUseCase,
  }) : _authApi = authApi,
       _ensureRegisterEmailSessionUseCase =
           ensureRegisterEmailSessionUseCase ??
           EnsureRegisterEmailSessionUseCase(authApi: authApi);

  final AuthApi _authApi;
  final EnsureRegisterEmailSessionUseCase _ensureRegisterEmailSessionUseCase;

  Future<void> call({required String email, required String password}) async {
    final normalizedEmail = _authApi._requireEmail(email);
    final normalizedPassword = _authApi._requirePassword(password);
    final normalizedKey = normalizedEmail.toLowerCase();
    final currentUser = _authApi._firebaseAuthGateway.currentUser;
    final currentEmail = currentUser?.email?.trim().toLowerCase();

    if (currentUser != null && currentEmail == normalizedKey) {
      await _authApi.updateCurrentUserPassword(newPassword: normalizedPassword);
      await _authApi._cacheSessionForUserWithFallback(currentUser);
      _clearRegisterBootstrapPassword(normalizedKey);
      return;
    }

    bool wasCreatedNow = false;
    try {
      await _authApi.createFirebaseUser(
        email: normalizedEmail,
        password: normalizedPassword,
      );
      wasCreatedNow = true;
    } on ApiException catch (error) {
      if (!_isEmailAlreadyInUseMessage(error.message)) {
        rethrow;
      }
    }

    try {
      final credential = await _authApi._firebaseAuthGateway
          .signInWithEmailAndPassword(
            email: normalizedEmail,
            password: normalizedPassword,
          );
      final signedInUser = credential.user;
      if (signedInUser == null) {
        throw const ApiException('Could not sign in with Firebase.');
      }
      await _authApi._cacheSessionForUserWithFallback(signedInUser);
      _clearRegisterBootstrapPassword(normalizedKey);
      return;
    } on FirebaseAuthException catch (error) {
      if (wasCreatedNow) {
        throw ApiException(_authApi._firebaseErrorMapper.map(error));
      }
    } catch (error) {
      if (wasCreatedNow) {
        throw ApiException('Internal error: $error');
      }
    }

    await _ensureRegisterEmailSessionUseCase(email: normalizedEmail);
    await _authApi.updateCurrentUserPassword(newPassword: normalizedPassword);

    final refreshedUser = _authApi._firebaseAuthGateway.currentUser;
    if (refreshedUser != null) {
      await _authApi._cacheSessionForUserWithFallback(refreshedUser);
    }
    _clearRegisterBootstrapPassword(normalizedKey);
  }

  bool _isEmailAlreadyInUseMessage(String message) {
    final normalized = message.trim().toLowerCase();
    return normalized.contains('already') ||
        normalized.contains('registered') ||
        normalized.contains('registrado') ||
        normalized.contains('ya está') ||
        normalized.contains('ya esta') ||
        normalized.contains('in use') ||
        normalized.contains('en uso');
  }
}

class ApplyEmailVerificationActionCodeUseCase {
  ApplyEmailVerificationActionCodeUseCase({required AuthApi authApi})
    : _authApi = authApi;

  final AuthApi _authApi;

  Future<String?> call({required String code}) {
    return _authApi.applyEmailVerificationActionCode(code: code);
  }
}

final Map<String, String> _registerBootstrapPasswords = {};

String _getOrCreateRegisterBootstrapPassword(String normalizedEmailKey) {
  return _registerBootstrapPasswords.putIfAbsent(
    normalizedEmailKey,
    _generateRegisterBootstrapPassword,
  );
}

void _clearRegisterBootstrapPassword(String normalizedEmailKey) {
  _registerBootstrapPasswords.remove(normalizedEmailKey);
}

String _generateRegisterBootstrapPassword() {
  const chars =
      'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789!@#\$%^&*';
  final random = Random.secure();
  final buffer = StringBuffer('Rg#');
  for (int i = 0; i < 20; i++) {
    buffer.write(chars[random.nextInt(chars.length)]);
  }
  buffer.write('9aA');
  return buffer.toString();
}
