import 'package:food_safe/utils/env_utils.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static Future<SupabaseClient> getInstance() async {
    await Supabase.initialize(
      url: EnvUtils.supabaseUrl,
      anonKey: EnvUtils.supabaseAnonKey,
    );
    return Supabase.instance.client;
  }
}
