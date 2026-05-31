part of '../auth_api.dart';

extension AuthApiRegisterApi on AuthApi {
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
}
