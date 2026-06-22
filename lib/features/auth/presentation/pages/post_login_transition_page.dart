import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fitnesscenter_mobile/app/config/app_routes.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || _hasNavigated) {
        return;
      }
      await WidgetsBinding.instance.endOfFrame;
      await Future<void>.delayed(const Duration(milliseconds: 260));
      if (!mounted || _hasNavigated) {
        return;
      }
      _hasNavigated = true;
      await Get.offAllNamed(AppRoutes.home);
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
