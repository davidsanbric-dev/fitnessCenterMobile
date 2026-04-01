import 'package:flutter/material.dart';

class AppSnackBar extends SnackBar {
  AppSnackBar({
    super.key,
    required String message,
    super.duration = const Duration(seconds: 3),
    super.action,
  }) : super(content: Text(message));
}

void showAppSnackBar(
  BuildContext context,
  String message, {
  Duration duration = const Duration(seconds: 3),
  SnackBarAction? action,
  bool clearPrevious = true,
}) {
  final messenger = ScaffoldMessenger.of(context);
  if (clearPrevious) {
    messenger.clearSnackBars();
  }
  messenger.showSnackBar(
    AppSnackBar(message: message, duration: duration, action: action),
  );
}
