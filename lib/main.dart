import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/app/read_sprint_app.dart';
import 'services/supabase_service.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await SupabaseService.getInstance();

  FlutterNativeSplash.remove();

  runApp(
    const ProviderScope(
      child: ReadSprintApp(),
    ),
  );
}
