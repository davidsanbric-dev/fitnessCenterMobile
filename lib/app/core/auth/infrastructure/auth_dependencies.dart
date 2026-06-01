import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

typedef SecondaryAuthAction = Future<void> Function(FirebaseAuth auth);
typedef FirebaseAppProvider = FirebaseApp Function();
typedef SecondaryAppInitializer =
    Future<FirebaseApp> Function({
      required String name,
      required FirebaseOptions options,
    });
typedef FirebaseAuthForApp = FirebaseAuth Function(FirebaseApp app);
typedef SecondaryAppSuffixBuilder = String Function();

abstract class FirebaseAuthGateway {
  bool get hasSession;
  User? get currentUser;

  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<void> signOut();
  Future<void> withSecondaryAuth(SecondaryAuthAction action);
  Future<void> sendPasswordResetEmail({
    required String email,
    ActionCodeSettings? actionCodeSettings,
  });
  Future<String> verifyPasswordResetCode({required String code});
  Future<void> confirmPasswordReset({
    required String code,
    required String newPassword,
  });
  Future<ActionCodeInfo> checkActionCode({required String code});
  Future<void> applyActionCode({required String code});

}

class DefaultFirebaseAuthGateway implements FirebaseAuthGateway {
  DefaultFirebaseAuthGateway({
    FirebaseAuth? firebaseAuth,
    FirebaseAppProvider? appProvider,
    SecondaryAppInitializer? appInitializer,
    FirebaseAuthForApp? authForApp,
    SecondaryAppSuffixBuilder? secondaryAppSuffixBuilder,
  }) : _auth = firebaseAuth ?? FirebaseAuth.instance,
       _appProvider = appProvider ?? Firebase.app,
       _appInitializer = appInitializer ?? _initializeApp,
       _authForApp = authForApp ?? _authFromApp,
       _secondaryAppSuffixBuilder =
           secondaryAppSuffixBuilder ?? _defaultSecondaryAppSuffix;

  final FirebaseAuth _auth;
  final FirebaseAppProvider _appProvider;
  final SecondaryAppInitializer _appInitializer;
  final FirebaseAuthForApp _authForApp;
  final SecondaryAppSuffixBuilder _secondaryAppSuffixBuilder;

  static Future<FirebaseApp> _initializeApp({
    required String name,
    required FirebaseOptions options,
  }) {
    return Firebase.initializeApp(name: name, options: options);
  }

  static FirebaseAuth _authFromApp(FirebaseApp app) {
    return FirebaseAuth.instanceFor(app: app);
  }

  static String _defaultSecondaryAppSuffix() {
    return DateTime.now().microsecondsSinceEpoch.toString();
  }

  @override
  bool get hasSession => _auth.currentUser != null;

  @override
  User? get currentUser => _auth.currentUser;

  @override
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  @override
  Future<void> signOut() {
    return _auth.signOut();
  }

  @override
  Future<void> withSecondaryAuth(SecondaryAuthAction action) async {
    FirebaseApp? secondaryApp;
    FirebaseAuth? secondaryAuth;
    try {
      final baseApp = _appProvider();
      final appName = 'auth-${_secondaryAppSuffixBuilder()}';
      secondaryApp = await _appInitializer(
        name: appName,
        options: baseApp.options,
      );
      secondaryAuth = _authForApp(secondaryApp);
      await action(secondaryAuth);
    } finally {
      if (secondaryAuth != null) {
        try {
          await secondaryAuth.signOut();
        } catch (_) {
          // Ignore cleanup errors to preserve the original failure.
        }
      }
      if (secondaryApp != null) {
        try {
          await secondaryApp.delete();
        } catch (_) {
          // Ignore cleanup errors to preserve the original failure.
        }
      }
    }
  }

  @override
  Future<void> sendPasswordResetEmail({
    required String email,
    ActionCodeSettings? actionCodeSettings,
  }) {
    return _auth.sendPasswordResetEmail(
      email: email,
      actionCodeSettings: actionCodeSettings,
    );
  }

  @override
  Future<String> verifyPasswordResetCode({required String code}) {
    return _auth.verifyPasswordResetCode(code);
  }

  @override
  Future<void> confirmPasswordReset({
    required String code,
    required String newPassword,
  }) {
    return _auth.confirmPasswordReset(code: code, newPassword: newPassword);
  }

  @override
  Future<ActionCodeInfo> checkActionCode({required String code}) {
    return _auth.checkActionCode(code);
  }

  @override
  Future<void> applyActionCode({required String code}) {
    return _auth.applyActionCode(code);
  }

}
