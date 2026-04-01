part of '../auth_api.dart';

extension AuthApiPasswordApi on AuthApi {
  Future<void> sendPasswordResetEmail({
    required String email,
    ActionCodeSettings? actionCodeSettings,
  }) async {
    try {
      await _firebaseAuthGateway.sendPasswordResetEmail(
        email: _requireEmail(email),
        actionCodeSettings: actionCodeSettings,
      );
    } on FirebaseAuthException catch (error) {
      throw ApiException(_firebaseErrorMapper.map(error));
    } catch (error) {
      throw ApiException('Internal error: $error');
    }
  }

  Future<String> verifyPasswordResetCode({required String code}) async {
    final trimmed = code.trim();
    if (trimmed.isEmpty) {
      throw const ApiException('Invalid password reset link.');
    }
    try {
      return await _firebaseAuthGateway.verifyPasswordResetCode(code: trimmed);
    } on FirebaseAuthException catch (error) {
      throw ApiException(_firebaseErrorMapper.map(error));
    } catch (error) {
      throw ApiException('Internal error: $error');
    }
  }

  Future<void> confirmPasswordReset({
    required String code,
    required String newPassword,
  }) async {
    final trimmedCode = code.trim();
    if (trimmedCode.isEmpty) {
      throw const ApiException('Invalid password reset link.');
    }
    try {
      await _firebaseAuthGateway.confirmPasswordReset(
        code: trimmedCode,
        newPassword: _requirePassword(newPassword),
      );
    } on FirebaseAuthException catch (error) {
      throw ApiException(_firebaseErrorMapper.map(error));
    } catch (error) {
      throw ApiException('Internal error: $error');
    }
  }
}
