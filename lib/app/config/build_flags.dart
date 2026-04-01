import 'package:flutter/foundation.dart';

const bool kEnableDevicePreview = bool.fromEnvironment(
  'ENABLE_DEVICE_PREVIEW',
  defaultValue: kDebugMode,
);
