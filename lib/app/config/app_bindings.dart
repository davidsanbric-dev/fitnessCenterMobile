import 'package:portfolio_mobile_app/app/core/auth/auth.dart';
import 'package:portfolio_mobile_app/app/core/api/user_api.dart';
import 'package:portfolio_mobile_app/app/core/auth/infrastructure/auth_dependencies.dart';
import 'package:portfolio_mobile_app/app/core/auth/infrastructure/auth_exceptions/firebase_auth_exception_mapper.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class AppBindings {
  const AppBindings._();

  static void ensureAuthDependencies() {
    if (!Get.isRegistered<http.Client>()) {
      Get.put<http.Client>(http.Client(), permanent: true);
    }

    if (!Get.isRegistered<AuthSessionCache>()) {
      Get.put<AuthSessionCache>(AuthSessionCache(), permanent: true);
    }

    if (!Get.isRegistered<FirebaseAuthGateway>()) {
      Get.put<FirebaseAuthGateway>(
        DefaultFirebaseAuthGateway(),
        permanent: true,
      );
    }

    if (!Get.isRegistered<FirebaseAuthExceptionMapper>()) {
      Get.put<FirebaseAuthExceptionMapper>(
        const DefaultFirebaseAuthExceptionMapper(),
        permanent: true,
      );
    }

    if (!Get.isRegistered<UserApi>()) {
      Get.put<UserApi>(UserApi(), permanent: true);
    }

    if (!Get.isRegistered<AuthApi>()) {
      Get.put<AuthApi>(
        AuthApi(
          userApi: Get.find<UserApi>(),
          firebaseAuthGateway: Get.find<FirebaseAuthGateway>(),
          cache: Get.find<AuthSessionCache>(),
          firebaseErrorMapper: Get.find<FirebaseAuthExceptionMapper>(),
        ),
        permanent: true,
      );
    }
  }
}
