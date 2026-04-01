// import 'package:portfolio_mobile_app/app/core/utils/parse.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SessionData {
  const SessionData({required this.claims, required this.token});

  final Map<String, dynamic> claims;
  final String token;
}

class CachedCredentials {
  const CachedCredentials({required this.mail, required this.token});

  final String mail;
  final String token;
}

class AuthEnrolledPhoneFactor {
  const AuthEnrolledPhoneFactor({
    required this.uid,
    this.displayName,
    this.phoneNumber,
  });

  final String uid;
  final String? displayName;
  final String? phoneNumber;
}

class AuthActionCodeSettings {
  const AuthActionCodeSettings({
    required this.url,
    this.handleCodeInApp = false,
    this.androidPackageName,
    this.androidInstallApp = false,
    this.androidMinimumVersion,
    this.iOSBundleId,
    this.linkDomain,
  });

  final String url;
  final bool handleCodeInApp;
  final String? androidPackageName;
  final bool androidInstallApp;
  final String? androidMinimumVersion;
  final String? iOSBundleId;
  final String? linkDomain;
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
