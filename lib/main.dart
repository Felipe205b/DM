import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/app/read_sprint_app.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'features/home/home_provider.dart';
import 'services/data_service.dart';
import 'services/supabase_service.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Carrega as variáveis de ambiente
  await dotenv.load(fileName: ".env");
  await SupabaseService.initialize();

  DataService? dataService;
  bool initSuccess = false;

  try {
    // Garante que o usuário anônimo esteja logado
    final supabase = Supabase.instance.client;
    // Espera o primeiro evento de autenticação para garantir que a sessão foi carregada
    await supabase.auth.onAuthStateChange.first;

    if (supabase.auth.currentUser == null) {
      await supabase.auth.signInAnonymously();
    }

    final supabaseInstance = SupabaseService();

    // Garante que o usuário exista na tabela 'users'
    if (supabase.auth.currentUser != null) {
      await supabaseInstance.upsertUser(supabase.auth.currentUser!);
    }

    dataService = await DataService.getInstance(supabaseInstance);
    await dataService.syncQueue();
    initSuccess = true;
  } catch (e) {
    // Lidar com o erro de inicialização, se necessário
    print('Erro durante a inicialização: $e');
    initSuccess = false;
  } finally {
    // Remove a tela de splash
    FlutterNativeSplash.remove();
  }

  if (initSuccess && dataService != null) {
    // Executa o aplicativo com o serviço inicializado
    runApp(
      ProviderScope(
        overrides: [
          dataServiceProvider.overrideWithValue(dataService!),
        ],
        child: const ReadSprintApp(),
      ),
    );
  } else {
    // Exibe uma tela de erro se a inicialização falhar
    runApp(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text(
              'Erro na inicialização. Por favor, reinicie o aplicativo.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
