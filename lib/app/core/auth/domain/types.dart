// import 'package:portfolio_mobile_app/app/core/utils/parse.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SessionData {
  const SessionData({required this.claims, required this.token});

  final Map<String, dynamic> claims;
  final String token;
}

abstract class AuthLoginResult {
  const AuthLoginResult();
}

class AuthLoginSuccess extends AuthLoginResult {
  const AuthLoginSuccess(this.session);

  final SessionData session;
}

class AuthLoginMfaRequired extends AuthLoginResult {
  const AuthLoginMfaRequired({required this.challengeId, this.phoneNumber});

  final String challengeId;
  final String? phoneNumber;
}

class MfaCodeDelivery {
  const MfaCodeDelivery({
    required this.verificationId,
    this.resendToken,
    required this.isCodeSentConfirmed,
  });

  final String verificationId;
  final int? resendToken;
  final bool isCodeSentConfirmed;
}

class PendingMfaChallenge {
  const PendingMfaChallenge({
    required this.resolver,
    required this.phoneFactor,
    required this.createdAt,
  });

  final MultiFactorResolver resolver;
  final PhoneMultiFactorInfo phoneFactor;
  final DateTime createdAt;
}

class MfaSignInContext {
  MfaSignInContext({required this.challengeId, this.phoneNumber});

  final String challengeId;
  final String? phoneNumber;
  String? verificationId;
  int? resendToken;
}

// Map<String, dynamic>? extractNestedUserMap(dynamic data) =>
//     asMap(asMap(data)?['value']);
