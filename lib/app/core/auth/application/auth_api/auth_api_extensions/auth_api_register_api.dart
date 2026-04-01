part of '../auth_api.dart';

extension AuthApiRegisterApi on AuthApi {
  Future<void> sendCurrentUserEmailVerification({
    AuthActionCodeSettings? actionCodeSettings,
  }) async {
    final user = _requireUser();
    try {
      await user.sendEmailVerification(
        _toFirebaseActionCodeSettings(actionCodeSettings),
      );
    } on FirebaseAuthException catch (error) {
      throw ApiException(_firebaseErrorMapper.map(error));
    } catch (error) {
      throw ApiException('Internal error: $error');
    }
  }

  Future<void> ensureRegisterEmailSession({required String email}) {
    return _ensureRegisterEmailSessionUseCase(email: email);
  }

  Future<String?> applyEmailVerificationActionCode({
    required String code,
  }) async {
    final trimmed = code.trim();
    if (trimmed.isEmpty) {
      throw const ApiException('Invalid verification link.');
    }

    try {
      final info = await _firebaseAuthGateway.checkActionCode(code: trimmed);
      if (info.operation != ActionCodeInfoOperation.verifyEmail) {
        throw const ApiException(
          'This link does not correspond to an email verification.',
        );
      }
      await _firebaseAuthGateway.applyActionCode(code: trimmed);
      final actionData = info.data;
      final rawEmail = actionData['email'] ?? actionData['mail'];
      final email = rawEmail is String ? rawEmail.trim() : null;
      if (email == null || email.isEmpty) {
        return null;
      }
      return email;
    } on FirebaseAuthException catch (error) {
      throw ApiException(_firebaseErrorMapper.map(error));
    } on ApiException {
      rethrow;
    } catch (error) {
      throw ApiException('Internal error: $error');
    }
  }

  Future<void> updateCurrentUserPassword({required String newPassword}) async {
    final user = _requireUser();
    try {
      await user.updatePassword(_requirePassword(newPassword));
    } on FirebaseAuthException catch (error) {
      throw ApiException(_firebaseErrorMapper.map(error));
    } catch (error) {
      throw ApiException('Internal error: $error');
    }
  }

  Future<void> ensureRegisterUserCredentials({
    required String email,
    required String password,
  }) {
    return _ensureRegisterUserCredentialsUseCase(
      email: email,
      password: password,
    );
  }

  Future<bool> reloadAndCheckEmailVerified() async {
    final user = _requireUser();
    try {
      await user.reload();
      final refreshed = _firebaseAuthGateway.currentUser;
      if (refreshed == null) {
        throw const ApiException('There is no active session.');
      }
      return refreshed.emailVerified;
    } on FirebaseAuthException catch (error) {
      throw ApiException(_firebaseErrorMapper.map(error));
    } catch (error) {
      throw ApiException('Internal error: $error');
    }
  }

  bool isCurrentUserEmailVerified() {
    final user = _firebaseAuthGateway.currentUser;
    return user?.emailVerified ?? false;
  }

  Future<void> createFirebaseUser({
    required String email,
    required String password,
  }) async {
    await _runWithSecondaryAuth((auth) async {
      await auth.createUserWithEmailAndPassword(
        email: _requireEmail(email),
        password: _requirePassword(password),
      );
    });
  }

  Future<void> deleteFirebaseUser({
    required String email,
    required String password,
  }) async {
    await _runWithSecondaryAuth((auth) async {
      final credential = await auth.signInWithEmailAndPassword(
        email: _requireEmail(email),
        password: _requirePassword(password),
      );
      await credential.user?.delete();
    });
  }

  Future<void> updateFirebaseUserEmail({
    required String currentEmail,
    required String newEmail,
    required String password,
  }) async {
    final trimmedCurrentEmail = _requireEmail(currentEmail);
    final trimmedNewEmail = _requireEmail(newEmail);
    _requirePassword(password);
    if (trimmedCurrentEmail.toLowerCase() == trimmedNewEmail.toLowerCase()) {
      return;
    }

    await _runWithSecondaryAuth((auth) async {
      final credential = await auth.signInWithEmailAndPassword(
        email: trimmedCurrentEmail,
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw const ApiException(
          'No se pudo actualizar el correo en Firebase.',
        );
      }
      await user.verifyBeforeUpdateEmail(trimmedNewEmail);
    });
  }

  Future<void> _runWithSecondaryAuth(SecondaryAuthAction action) async {
    try {
      await _firebaseAuthGateway.withSecondaryAuth(action);
    } on FirebaseAuthException catch (error) {
      throw ApiException(_firebaseErrorMapper.map(error));
    }
  }

  ActionCodeSettings? _toFirebaseActionCodeSettings(
    AuthActionCodeSettings? settings,
  ) {
    if (settings == null) {
      return null;
    }
    return ActionCodeSettings(
      url: settings.url,
      handleCodeInApp: settings.handleCodeInApp,
      androidPackageName: settings.androidPackageName,
      androidInstallApp: settings.androidInstallApp,
      androidMinimumVersion: settings.androidMinimumVersion,
      iOSBundleId: settings.iOSBundleId,
      linkDomain: settings.linkDomain,
    );
  }
}
