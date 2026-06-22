import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fitnesscenter_mobile/app/core/exceptions/startup_exception.dart';
import 'package:fitnesscenter_mobile/app/core/startup/firebase_bootstrap.dart';
import 'package:fitnesscenter_mobile/app/core/startup/startup_manager.dart';
import 'package:fitnesscenter_mobile/app/main_app.dart';

/// Root widget that gates [MainApp] behind critical startup work.
///
/// It blocks on [ensureFirebaseReady] (showing a spinner, or
/// [StartupFailureApp] on failure), then dispatches the non-critical
/// [StartupManager] steps once the first frame is on screen.
class BootstrapApp extends StatefulWidget {
  const BootstrapApp({super.key});

  @override
  State<BootstrapApp> createState() => _BootstrapAppState();
}

class _BootstrapAppState extends State<BootstrapApp> {
  late final Future<void> _bootstrapFuture = _initializeCriticalStartup();
  bool _startupDispatched = false;

  Future<void> _initializeCriticalStartup() async {
    final firebaseReady = await ensureFirebaseReady();
    if (!firebaseReady) {
      throw const FirebaseInitializationException();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _bootstrapFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return StartupFailureApp(error: snapshot.error!);
        }

        if (snapshot.connectionState != ConnectionState.done) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }

        if (!_startupDispatched) {
          _startupDispatched = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            unawaited(const StartupManager().run());
          });
        }

        return const MainApp();
      },
    );
  }
}
