import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Localization Service - DE/EN only
class LocalizationService extends ChangeNotifier {
  static LocalizationService? _instance;
  SharedPreferences? _prefs;

  String _currentLanguage = 'en';

  LocalizationService._();

  static LocalizationService get instance {
    _instance ??= LocalizationService._();
    return _instance!;
  }

  /// Initialize localization
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _currentLanguage = _prefs?.getString('language') ?? 'en';
    notifyListeners();
  }

  /// Get current language
  String get currentLanguage => _currentLanguage;

  /// Check if German
  bool get isGerman => _currentLanguage == 'de';

  /// Get locale
  Locale get locale => Locale(_currentLanguage);

  /// Set language
  Future<void> setLanguage(String languageCode) async {
    if (languageCode != 'en' && languageCode != 'de') {
      languageCode = 'en'; // Default to English
    }

    _currentLanguage = languageCode;
    await _prefs?.setString('language', languageCode);
    notifyListeners();

    debugPrint('Language changed to: $languageCode');
  }

  /// Get translated string
  String translate(String key) {
    return _translations[_currentLanguage]?[key] ?? key;
  }

  /// Shorthand for translate
  String t(String key) => translate(key);

  // ========== Translations ==========

  static final Map<String, Map<String, String>> _translations = {
    'en': {
      // App
      'app_name': 'QuantumMind RTLS',
      'welcome': 'Welcome to QuantumMind!',
      'subtitle': 'Real-time monitoring and control system',

      // Auth
      'login': 'Login',
      'logout': 'Logout',
      'email': 'Email',
      'password': 'Password',
      'login_button': 'Login',

      // Dashboard
      'dashboard': 'Dashboard',
      'active_tags': 'Active Tags',
      'doors': 'Doors',
      'sensors': 'Sensors',
      'alerts': 'Alerts',
      'quick_actions': 'Quick Actions',

      // Access Logs
      'access_logs': 'Access Logs',
      'entry': 'Entry',
      'exit': 'Exit',
      'all': 'All',
      'total_today': 'Total Today',
      'entries': 'Entries',
      'exits': 'Exits',
      'export_logs': 'Export Logs',

      // RTLS Map
      'rtls_map': 'RTLS Live Map',
      'edit_map': 'Edit Map',
      'done': 'Done',
      'add_tag': 'Add Tag',
      'delete_tag': 'Delete Tag',
      'import_floor_plan': 'Import Floor Plan',
      'export_pdf': 'Export to PDF',
      'drawing_tools': 'Drawing Tools',
      'zone': 'Zone',
      'wall': 'Wall',
      'door': 'Door',
      'map_elements': 'Map Elements',
      'tags': 'Tags',
      'zones': 'Zones',
      'walls': 'Walls',

      // Settings
      'settings': 'Settings',
      'appearance': 'Appearance',
      'dark_mode': 'Dark Mode',
      'use_dark_theme': 'Use dark theme',
      'notifications': 'Notifications',
      'enable_notifications': 'Enable Notifications',
      'receive_alerts': 'Receive alerts and updates',
      'notification_sound': 'Notification Sound',
      'system': 'System',
      'auto_backup': 'Auto Backup',
      'automatically_backup': 'Automatically backup data',
      'backup_now': 'Backup Now',
      'create_manual_backup': 'Create manual backup',
      'language': 'Language',
      'refresh_rate': 'Refresh Rate',
      'account': 'Account',
      'profile': 'Profile',
      'change_password': 'Change Password',
      'about': 'About',
      'version': 'Version',
      'privacy_policy': 'Privacy Policy',
      'terms_of_service': 'Terms of Service',

      // Messages
      'success': 'Success',
      'error': 'Error',
      'confirm': 'Confirm',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'save': 'Save',
      'close': 'Close',
      'refresh': 'Refresh',

      // Worker types
      'worker': 'Worker',
      'vehicle': 'Vehicle',
      'equipment': 'Equipment',
      'asset': 'Asset',
    },
    'de': {
      // App
      'app_name': 'QuantumMind RTLS',
      'welcome': 'Willkommen bei QuantumMind!',
      'subtitle': 'Echtzeit-Überwachungs- und Kontrollsystem',

      // Auth
      'login': 'Anmelden',
      'logout': 'Abmelden',
      'email': 'E-Mail',
      'password': 'Passwort',
      'login_button': 'Anmelden',

      // Dashboard
      'dashboard': 'Dashboard',
      'active_tags': 'Aktive Tags',
      'doors': 'Türen',
      'sensors': 'Sensoren',
      'alerts': 'Warnungen',
      'quick_actions': 'Schnellaktionen',

      // Access Logs
      'access_logs': 'Zugriffsprotokolle',
      'entry': 'Eingang',
      'exit': 'Ausgang',
      'all': 'Alle',
      'total_today': 'Gesamt Heute',
      'entries': 'Eingänge',
      'exits': 'Ausgänge',
      'export_logs': 'Protokolle exportieren',

      // RTLS Map
      'rtls_map': 'RTLS Live-Karte',
      'edit_map': 'Karte bearbeiten',
      'done': 'Fertig',
      'add_tag': 'Tag hinzufügen',
      'delete_tag': 'Tag löschen',
      'import_floor_plan': 'Grundriss importieren',
      'export_pdf': 'Als PDF exportieren',
      'drawing_tools': 'Zeichenwerkzeuge',
      'zone': 'Zone',
      'wall': 'Wand',
      'door': 'Tür',
      'map_elements': 'Kartenelemente',
      'tags': 'Tags',
      'zones': 'Zonen',
      'walls': 'Wände',

      // Settings
      'settings': 'Einstellungen',
      'appearance': 'Erscheinungsbild',
      'dark_mode': 'Dunkelmodus',
      'use_dark_theme': 'Dunkles Thema verwenden',
      'notifications': 'Benachrichtigungen',
      'enable_notifications': 'Benachrichtigungen aktivieren',
      'receive_alerts': 'Warnungen und Updates erhalten',
      'notification_sound': 'Benachrichtigungston',
      'system': 'System',
      'auto_backup': 'Automatische Sicherung',
      'automatically_backup': 'Daten automatisch sichern',
      'backup_now': 'Jetzt sichern',
      'create_manual_backup': 'Manuelle Sicherung erstellen',
      'language': 'Sprache',
      'refresh_rate': 'Aktualisierungsrate',
      'account': 'Konto',
      'profile': 'Profil',
      'change_password': 'Passwort ändern',
      'about': 'Über',
      'version': 'Version',
      'privacy_policy': 'Datenschutzrichtlinie',
      'terms_of_service': 'Nutzungsbedingungen',

      // Messages
      'success': 'Erfolg',
      'error': 'Fehler',
      'confirm': 'Bestätigen',
      'cancel': 'Abbrechen',
      'delete': 'Löschen',
      'save': 'Speichern',
      'close': 'Schließen',
      'refresh': 'Aktualisieren',

      // Worker types
      'worker': 'Arbeiter',
      'vehicle': 'Fahrzeug',
      'equipment': 'Ausrüstung',
      'asset': 'Vermögen',
    },
  };
}

/// Extension for easy access in widgets
extension LocalizationExtension on String {
  String get tr => LocalizationService.instance.translate(this);
}
