import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/app/read_sprint_app.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'features/home/home_provider.dart';
import 'services/data_service.dart';
import 'services/shared_preferences_services.dart';
import 'services/supabase_service.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  DataService? dataService;
  bool initSuccess = false;
  String? errorMessage; // Variável para armazenar a mensagem de erro

  try {
    // Carrega as variáveis de ambiente e inicializa serviços
    await dotenv.load(fileName: ".env");
    await SupabaseService.initialize();
    await SharedPreferencesService.getInstance();

    final supabase = Supabase.instance.client;
    await supabase.auth.onAuthStateChange.first;

    if (supabase.auth.currentUser == null) {
      await supabase.auth.signInAnonymously();
    }

    final supabaseInstance = SupabaseService();
    final currentUser = supabase.auth.currentUser;

    // Garante que o usuário exista na tabela 'users'. A opção ignoreDuplicates agora lida com o conflito.
    if (currentUser != null) {
      await supabaseInstance.upsertUser(currentUser);
    }

    dataService = await DataService.getInstance(supabaseInstance);
    await dataService.syncQueue();

    initSuccess = true;
  } catch (e) {
    debugPrint('Erro durante a inicialização: $e');
    errorMessage = e.toString(); // Captura o erro específico
    initSuccess = false;
  } finally {
    FlutterNativeSplash.remove();
  }

  if (initSuccess && dataService != null) {
    runApp(
      ProviderScope(
        overrides: [
          dataServiceProvider.overrideWithValue(dataService),
        ],
        child: const ReadSprintApp(),
      ),
    );
  } else {
    // Exibe a tela de erro com a mensagem específica, conforme solicitado.
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Erro na inicialização:\n\n$errorMessage\n\nPor favor, reinicie o aplicativo.',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
