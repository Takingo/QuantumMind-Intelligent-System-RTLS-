import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/settings_service.dart';
import 'services/localization_service.dart';
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

  // Skip Supabase initialization for demo mode
  // Initialize Supabase only if credentials are configured
  // Uncomment below when Supabase is properly configured:
  /*
  try {
    await SupabaseService.initialize();
  } catch (e) {
    debugPrint('Supabase initialization error: $e');
  }
  */

  runApp(const QuantumMindApp());
}
