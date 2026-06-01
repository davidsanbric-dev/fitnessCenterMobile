import 'package:portfolio_mobile_app/app/core/api/user_api.dart';
import 'package:portfolio_mobile_app/app/core/auth/application/auth_session_claims_mapper.dart';
import 'package:portfolio_mobile_app/app/core/auth/infrastructure/auth_exceptions/firebase_auth_exception_mapper.dart';
import 'package:portfolio_mobile_app/app/core/auth/infrastructure/auth_dependencies.dart';
import 'package:portfolio_mobile_app/app/core/auth/domain/types.dart';
import 'package:portfolio_mobile_app/app/core/auth/infrastructure/auth_session_cache.dart';
import 'package:portfolio_mobile_app/app/core/exceptions/api_exception.dart';
import 'package:portfolio_mobile_app/app/core/auth/domain/auth_request.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'auth_api_extensions/auth_api_password_api.dart';
part 'auth_api_extensions/auth_api_register_api.dart';
part 'auth_api_extensions/auth_api_session_api.dart';

class AuthApi {
  AuthApi({
    FirebaseAuth? firebaseAuth,
    AuthSessionCache? cache,
    UserApi? userApi,
    AuthSessionClaimsMapper? sessionClaimsMapper,
    FirebaseAuthGateway? firebaseAuthGateway,
    FirebaseAuthExceptionMapper? firebaseErrorMapper,
  }) : _userApi = userApi ?? UserApi(),
       _sessionClaimsMapper =
           sessionClaimsMapper ?? const AuthSessionClaimsMapper(),
       _firebaseAuthGateway =
           firebaseAuthGateway ??
           DefaultFirebaseAuthGateway(firebaseAuth: firebaseAuth),
       _cache = cache ?? AuthSessionCache(),
       _firebaseErrorMapper =
           firebaseErrorMapper ?? const DefaultFirebaseAuthExceptionMapper();

  final UserApi _userApi;
  final AuthSessionClaimsMapper _sessionClaimsMapper;
  final FirebaseAuthGateway _firebaseAuthGateway;
  final AuthSessionCache _cache;
  final FirebaseAuthExceptionMapper _firebaseErrorMapper;

  bool get hasFirebaseSession => _firebaseAuthGateway.hasSession;

  Future<SessionData> login({required AuthRequest request}) async {
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
        return await _cacheSessionForUser(user);
      } on EmailNotVerifiedException {
        // Keep the Firebase session so the user can resend / re-check.
        rethrow;
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
    } on FirebaseAuthException catch (error) {
      throw ApiException(_firebaseErrorMapper.map(error));
    } on ApiException {
      rethrow;
    } catch (error) {
      throw ApiException('Internal error: $error');
    }
  }
}
