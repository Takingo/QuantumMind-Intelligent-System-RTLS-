import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/settings_service.dart';
import 'services/localization_service.dart';
import 'services/supabase_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize Settings Service
  await SettingsService.instance.initialize();

  // Initialize Localization Service
  await LocalizationService.instance.initialize();

  // Initialize Supabase
  try {
    await SupabaseService.initialize();
    debugPrint('✅ Supabase initialized successfully!');
  } catch (e) {
    debugPrint('❌ Supabase initialization error: $e');
  }

  runApp(const QuantumMindApp());
}
