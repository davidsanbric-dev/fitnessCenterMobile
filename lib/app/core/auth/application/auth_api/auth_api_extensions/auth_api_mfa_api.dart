part of '../auth_api.dart';

extension AuthApiMfaApi on AuthApi {
  Future<MfaCodeDelivery> sendMfaSignInCode({
    required String challengeId,
    int? forceResendingToken,
  }) async {
    final challenge = _requirePendingMfaChallenge(challengeId);
    final completer = Completer<MfaCodeDelivery>();

    try {
      await _firebaseAuthGateway.verifyPhoneNumber(
        multiFactorSession: challenge.resolver.session,
        multiFactorInfo: challenge.phoneFactor,
        forceResendingToken: forceResendingToken,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (_) {},
        verificationFailed: (error) {
          if (!completer.isCompleted) {
            completer.completeError(
              ApiException(_firebaseErrorMapper.map(error)),
            );
          }
        },
        codeSent: (verificationId, resendToken) {
          if (!completer.isCompleted) {
            completer.complete(
              MfaCodeDelivery(
                verificationId: verificationId,
                resendToken: resendToken,
                isCodeSentConfirmed: true,
              ),
            );
          }
        },
        codeAutoRetrievalTimeout: (verificationId) {
          if (!completer.isCompleted) {
            completer.complete(
              MfaCodeDelivery(
                verificationId: verificationId,
                resendToken: forceResendingToken,
                isCodeSentConfirmed: false,
              ),
            );
          }
        },
      );
    } on FirebaseAuthException catch (error) {
      if (!completer.isCompleted) {
        completer.completeError(ApiException(_firebaseErrorMapper.map(error)));
      }
    } catch (error) {
      if (!completer.isCompleted) {
        completer.completeError(ApiException('Internal error: $error'));
      }
    }

    return completer.future.timeout(
      AuthApi._mfaCallbackHardTimeout,
      onTimeout: () {
        throw const ApiException(
          'Firebase did not respond to the SMS send request. Please try resending.',
        );
      },
    );
  }

  Future<SessionData> resolveMfaSignIn({
    required String challengeId,
    required String verificationId,
    required String smsCode,
  }) async {
    final challenge = _requirePendingMfaChallenge(challengeId);
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      final assertion = PhoneMultiFactorGenerator.getAssertion(credential);
      final userCredential = await challenge.resolver.resolveSignIn(assertion);
      final user = userCredential.user;
      if (user == null) {
        throw const ApiException('Could not validate the second factor.');
      }
      final session = await _cacheSessionForUser(user);
      _discardPendingMfaChallenge(challengeId);
      return session;
    } on FirebaseAuthException catch (error) {
      throw ApiException(_firebaseErrorMapper.map(error));
    } on ApiException {
      rethrow;
    } catch (error) {
      throw ApiException('Internal error: $error');
    }
  }

  void discardMfaSignInChallenge({required String challengeId}) {
    _discardPendingMfaChallenge(challengeId);
  }

  AuthLoginMfaRequired _buildMfaRequiredResult(
    FirebaseAuthMultiFactorException error,
  ) {
    final resolver = error.resolver;
    PhoneMultiFactorInfo? phoneFactor;
    for (final hint in resolver.hints) {
      if (hint is PhoneMultiFactorInfo) {
        phoneFactor = hint;
        break;
      }
    }
    if (phoneFactor == null) {
      throw const ApiException('No SMS factor is configured for this user.');
    }
    final challengeId = _storePendingMfaChallenge(
      resolver: resolver,
      phoneFactor: phoneFactor,
    );
    return AuthLoginMfaRequired(
      challengeId: challengeId,
      phoneNumber: phoneFactor.phoneNumber,
    );
  }

  String _storePendingMfaChallenge({
    required MultiFactorResolver resolver,
    required PhoneMultiFactorInfo phoneFactor,
  }) {
    _purgeExpiredPendingMfaChallenges();
    final challengeId = _generateMfaChallengeId();
    _pendingMfaChallenges[challengeId] = PendingMfaChallenge(
      resolver: resolver,
      phoneFactor: phoneFactor,
      createdAt: DateTime.now(),
    );
    return challengeId;
  }

  PendingMfaChallenge _requirePendingMfaChallenge(String challengeId) {
    _purgeExpiredPendingMfaChallenges();
    final normalizedChallengeId = challengeId.trim();
    if (normalizedChallengeId.isEmpty) {
      throw const ApiException('Invalid MFA challenge.');
    }
    final challenge = _pendingMfaChallenges[normalizedChallengeId];
    if (challenge == null) {
      throw const ApiException('MFA challenge expired. Please sign in again.');
    }
    return challenge;
  }

  void _discardPendingMfaChallenge(String challengeId) {
    final normalizedChallengeId = challengeId.trim();
    if (normalizedChallengeId.isEmpty) {
      return;
    }
    _pendingMfaChallenges.remove(normalizedChallengeId);
  }

  void _purgeExpiredPendingMfaChallenges() {
    final now = DateTime.now();
    final expiredKeys = <String>[];
    _pendingMfaChallenges.forEach((key, challenge) {
      if (now.difference(challenge.createdAt) > AuthApi._mfaChallengeTtl) {
        expiredKeys.add(key);
      }
    });
    for (final key in expiredKeys) {
      _pendingMfaChallenges.remove(key);
    }
  }

  String _generateMfaChallengeId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random.secure();
    final buffer = StringBuffer();
    for (int i = 0; i < 32; i++) {
      buffer.write(chars[random.nextInt(chars.length)]);
    }
    return buffer.toString();
  }
}
