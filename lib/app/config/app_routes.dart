import 'package:portfolio_mobile_app/app/core/middleware/auth_middleware.dart';
import 'package:portfolio_mobile_app/app/core/constants/route_paths.dart';
import 'package:portfolio_mobile_app/features/auth/presentation/pages/login_page.dart';
import 'package:portfolio_mobile_app/features/auth/presentation/pages/post_login_transition_page.dart';
import 'package:portfolio_mobile_app/features/auth/presentation/pages/unauthorized_page.dart';
import 'package:portfolio_mobile_app/features/home/presentation/widgets/home_wrapper.dart';
import 'package:portfolio_mobile_app/features/available_slots_listing/presentation/pages/available_slots_page.dart';
import 'package:portfolio_mobile_app/features/password_recovery/presentation/pages/password_recovery_page.dart';
import 'package:portfolio_mobile_app/features/register/presentation/pages/register_page.dart';
import 'package:get/get.dart';

mixin AppRoutes {
  static const login = RoutePaths.login;
  static const postLogin = RoutePaths.postLogin;
  static const register = RoutePaths.register;
  static const passwordRecovery = RoutePaths.passwordRecovery;
  static const home = RoutePaths.home;
  static const adminBookings = RoutePaths.adminBookings;
  static const memberBookings = RoutePaths.memberBookings;
  static const users = RoutePaths.users;
  static const unauthorized = RoutePaths.unauthorized;

  static final pages = [
    GetPage(name: login, page: () => const LoginPage()),
    GetPage(name: postLogin, page: () => const PostLoginTransitionPage()),
    GetPage(
      name: register,
      page: () {
        final args = Get.arguments as Map<String, dynamic>?;
        return RegisterPage(
          emailVerificationOobCode: args?['oobCode'] as String?,
        );
      },
    ),
    GetPage(
      name: passwordRecovery,
      page: () {
        final args = Get.arguments as Map<String, dynamic>?;
        return PasswordRecoveryPage(oobCode: args?['oobCode'] as String?);
      },
    ),
    GetPage(
      name: home,
      page: () => const HomeWrapper(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: memberBookings,
      page: () => const AvailableSlotsPage(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(name: unauthorized, page: () => const UnauthorizedPage()),
  ];
}
