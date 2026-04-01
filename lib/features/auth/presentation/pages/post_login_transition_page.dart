import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:portfolio_mobile_app/app/config/app_routes.dart';
import 'package:portfolio_mobile_app/app/core/diagnostics/runtime_diagnostics.dart';

class PostLoginTransitionPage extends StatefulWidget {
  const PostLoginTransitionPage({super.key});

  @override
  State<PostLoginTransitionPage> createState() =>
      _PostLoginTransitionPageState();
}

class _PostLoginTransitionPageState extends State<PostLoginTransitionPage> {
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    RuntimeDiagnostics.breadcrumb('post-login-init');
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      RuntimeDiagnostics.breadcrumb('post-login-frame-ready');
      if (!mounted || _hasNavigated) {
        RuntimeDiagnostics.breadcrumb('post-login-cancelled-before-delay');
        return;
      }
      await WidgetsBinding.instance.endOfFrame;
      RuntimeDiagnostics.breadcrumb('post-login-end-of-frame');
      await Future<void>.delayed(const Duration(milliseconds: 260));
      if (!mounted || _hasNavigated) {
        RuntimeDiagnostics.breadcrumb('post-login-cancelled-after-delay');
        return;
      }
      _hasNavigated = true;
      RuntimeDiagnostics.breadcrumb('post-login-go-home');
      final result = await Get.offAllNamed(AppRoutes.home);
      RuntimeDiagnostics.breadcrumb(
        'post-login-home-nav-complete',
        data: 'result=${result ?? '-'}',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(strokeWidth: 2.8),
        ),
      ),
    );
  }
}
