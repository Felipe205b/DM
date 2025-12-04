import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:food_safe/utils/platform_environment.dart'
    if (dart.library.io) 'package:food_safe/utils/platform_environment_io.dart';

class EnvUtils {
  static String supabaseUrl = dotenv.env['SUPABASE_URL']!;
  static String supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY']!;

  static bool get isDebugMode => kDebugMode;
  static bool get isWeb => kIsWeb;
}
