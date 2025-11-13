import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:food_safe/utils/platform_environment.dart'
    if (dart.library.io) 'package:food_safe/utils/platform_environment_io.dart';

class EnvUtils {
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY');

  static bool get isDebugMode => kDebugMode;
  static bool get isWeb => kIsWeb;
}
