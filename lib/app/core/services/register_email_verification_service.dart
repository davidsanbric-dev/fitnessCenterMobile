import 'dart:async';

import 'package:get/get.dart';

class RegisterEmailVerificationService extends GetxService {
  final StreamController<String> _controller =
      StreamController<String>.broadcast();
  String? _pendingCode;

  Stream<String> get codeStream => _controller.stream;

  void pushCode(String code) {
    final trimmed = code.trim();
    if (trimmed.isEmpty) {
      return;
    }
    _pendingCode = trimmed;
    _controller.add(trimmed);
  }

  String? takePendingCode() {
    final code = _pendingCode;
    _pendingCode = null;
    return code;
  }

  @override
  void onClose() {
    _controller.close();
    super.onClose();
  }
}
