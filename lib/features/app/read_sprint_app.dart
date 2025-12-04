import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_safe/theme/theme.dart';

import '../home/home_page.dart';
import '../home/profile_page.dart';
import '../onboarding/onboarding_page.dart';

class ReadSprintApp extends ConsumerWidget {
  const ReadSprintApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'ReadSprint',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'),
      ],
      home: const HomePage(title: 'Food Safe'),
      routes: {
        OnboardingPage.routeName: (context) => const OnboardingPage(),
        HomePage.routeName: (context) => const HomePage(title: 'Food Safe'),
        ProfilePage.routeName: (context) => const ProfilePage(),
      },
    );
  }
}
