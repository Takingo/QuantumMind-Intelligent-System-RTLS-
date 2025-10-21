import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'services/localization_service.dart';
import 'screens/splash_screen_simple.dart';

/// Main application widget
class QuantumMindApp extends StatelessWidget {
  const QuantumMindApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocalizationService.instance),
      ],
      child: Consumer2<ThemeProvider, LocalizationService>(
        builder: (context, themeProvider, localizationService, _) {
          return MaterialApp(
            title: 'QuantumMind RTLS',
            debugShowCheckedModeBanner: false,
            theme: ThemeProvider.lightTheme,
            darkTheme: ThemeProvider.darkTheme,
            themeMode: themeProvider.themeMode,
            locale: localizationService.locale,
            supportedLocales: const [
              Locale('en'),
              Locale('de'),
            ],
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
