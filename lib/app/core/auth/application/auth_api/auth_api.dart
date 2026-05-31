import 'dart:async';
import 'dart:math';

import 'package:portfolio_mobile_app/app/core/api/user_api.dart';
import 'package:portfolio_mobile_app/app/core/auth/application/auth_session_claims_mapper.dart';
import 'package:portfolio_mobile_app/app/core/auth/infrastructure/auth_exceptions/firebase_auth_exception_mapper.dart';
import 'package:portfolio_mobile_app/app/core/auth/infrastructure/auth_dependencies.dart';
import 'package:portfolio_mobile_app/app/core/auth/domain/types.dart';
import 'package:portfolio_mobile_app/app/core/auth/infrastructure/auth_session_cache.dart';
import 'package:portfolio_mobile_app/app/core/exceptions/api_exception.dart';
import 'package:portfolio_mobile_app/app/core/auth/domain/auth_request.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

part 'auth_api_extensions/auth_api_mfa_api.dart';
part 'auth_api_extensions/auth_api_password_api.dart';
part 'auth_api_extensions/auth_api_register_api.dart';
part 'auth_api_extensions/auth_api_session_api.dart';

class AuthApi {
  AuthApi({
    http.Client? client,
    FirebaseAuth? firebaseAuth,
    AuthSessionCache? cache,
    UserApi? userApi,
    AuthSessionClaimsMapper? sessionClaimsMapper,
    UserAccessGateway? userAccessGateway,
    FirebaseAuthGateway? firebaseAuthGateway,
    FirebaseAuthExceptionMapper? firebaseErrorMapper,
  }) : _userAccessGateway =
           userAccessGateway ??
           HttpUserAccessGateway(client: client ?? http.Client()),
       _userApi = userApi ?? UserApi(),
       _sessionClaimsMapper =
           sessionClaimsMapper ?? const AuthSessionClaimsMapper(),
       _firebaseAuthGateway =
           firebaseAuthGateway ??
           DefaultFirebaseAuthGateway(firebaseAuth: firebaseAuth),
       _cache = cache ?? AuthSessionCache(),
       _firebaseErrorMapper =
           firebaseErrorMapper ?? const DefaultFirebaseAuthExceptionMapper();

  static const Duration _mfaCallbackHardTimeout = Duration(seconds: 25);
  static const Duration _mfaChallengeTtl = Duration(minutes: 10);

  final UserAccessGateway _userAccessGateway;
  final UserApi _userApi;
  final AuthSessionClaimsMapper _sessionClaimsMapper;
  final FirebaseAuthGateway _firebaseAuthGateway;
  final AuthSessionCache _cache;
  final FirebaseAuthExceptionMapper _firebaseErrorMapper;
  final Map<String, PendingMfaChallenge> _pendingMfaChallenges = {};

  bool get hasFirebaseSession => _firebaseAuthGateway.hasSession;

  /// Validates Firebase credentials and returns a JWT token.
  Future<AuthLoginResult> login({required AuthRequest request}) async {
    try {
      final email = request.mail.trim();
      final password = request.password;
      final credential = await _firebaseAuthGateway.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw const ApiException('Could not sign in with Firebase.');
      }

      try {
        final session = await _cacheSessionForUser(user);
        return AuthLoginSuccess(session);
      } on FirebaseAuthException catch (error) {
        await _safeSignOut();
        throw ApiException(_firebaseErrorMapper.map(error));
      } on ApiException {
        await _safeSignOut();
        rethrow;
      } catch (error) {
        await _safeSignOut();
        throw ApiException('Internal error: $error');
      }
    } on FirebaseAuthMultiFactorException catch (error) {
      return _buildMfaRequiredResult(error);
    } on FirebaseAuthException catch (error) {
      throw ApiException(_firebaseErrorMapper.map(error));
    } on ApiException {
      rethrow;
    } catch (error) {
      throw ApiException('Internal error: $error');
    }
  }
}
