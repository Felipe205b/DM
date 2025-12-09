import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/shared_preferences_services.dart';

// O provedor que a UI irá consumir. Ele gerencia o ThemeControllerNotifier.
final themeControllerProvider =
    StateNotifierProvider<ThemeControllerNotifier, AsyncValue<ThemeMode>>(
  (ref) {
    return ThemeControllerNotifier();
  },
);

// O Notifier que gerencia o estado do tema.
class ThemeControllerNotifier extends StateNotifier<AsyncValue<ThemeMode>> {
  // Inicia no estado de carregamento e chama o método de inicialização.
  ThemeControllerNotifier() : super(const AsyncValue.loading()) {
    _init();
  }

  // Método de inicialização privado.
  Future<void> _init() async {
    try {
      final savedModeStr = await SharedPreferencesService.getThemeMode();
      state = AsyncValue.data(_stringToThemeMode(savedModeStr));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // Altera o tema, salva a preferência e atualiza o estado.
  Future<void> toggle(Brightness currentBrightness) async {
    // Pega o estado atual de sucesso. Se não for sucesso, não faz nada.
    if (state is! AsyncData<ThemeMode>) return;
    final currentMode = state.value!;

    ThemeMode newMode;
    if (currentMode == ThemeMode.system) {
      newMode = currentBrightness == Brightness.dark
          ? ThemeMode.light
          : ThemeMode.dark;
    } else {
      newMode = currentMode == ThemeMode.dark
          ? ThemeMode.light
          : ThemeMode.dark;
    }

    // Salva a nova preferência
    await SharedPreferencesService.setThemeMode(_themeModeToString(newMode));
    // Atualiza o estado na UI
    state = AsyncValue.data(newMode);
  }

  ThemeMode _stringToThemeMode(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}
