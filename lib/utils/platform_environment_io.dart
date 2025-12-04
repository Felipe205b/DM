// File: lib/utils/platform_environment_io.dart
// This file is for IO platforms (Android, iOS, etc.).

import 'dart:io' show Platform;

const bool kIsWeb = false;

bool get isMobile {
  return Platform.isIOS || Platform.isAndroid;
}
