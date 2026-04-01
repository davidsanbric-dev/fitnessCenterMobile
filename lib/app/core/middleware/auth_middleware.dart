import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:portfolio_mobile_app/app/core/constants/route_paths.dart';
import 'package:portfolio_mobile_app/app/core/auth/auth.dart';

class AuthMiddleware extends GetMiddleware {
  final String? requiredRole;
  AuthMiddleware({this.requiredRole});

  @override
  RouteSettings? redirect(String? route) {
    final authService = Get.find<AuthService>();
    // If the user isn't authenticated, redirect to the login page
    if (!authService.isLoggedIn) {
      return const RouteSettings(name: RoutePaths.login);
    }

    // If a specific role is required and the user doesn't have it, redirect to the unauthorized page
    final required = requiredRole?.toLowerCase();
    final currentRole = authService.role?.toLowerCase();
    if (required != null && currentRole != required) {
      return const RouteSettings(name: RoutePaths.unauthorized);
    }

    // If everything is OK, don't redirect
    return null; // Allow access to the route
  }
}
