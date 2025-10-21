import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Settings Service - Manages app preferences
class SettingsService {
  static SettingsService? _instance;
  SharedPreferences? _prefs;

  SettingsService._();

  static SettingsService get instance {
    _instance ??= SettingsService._();
    return _instance!;
  }

  /// Initialize settings
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ========== Notification Settings ==========

  /// Check if notifications are enabled
  bool get notificationsEnabled {
    return _prefs?.getBool('notifications_enabled') ?? true;
  }

  /// Set notifications enabled
  Future<void> setNotificationsEnabled(bool enabled) async {
    await _prefs?.setBool('notifications_enabled', enabled);
    debugPrint('Notifications ${enabled ? 'enabled' : 'disabled'}');
  }

  /// Get notification sound
  String get notificationSound {
    return _prefs?.getString('notification_sound') ?? 'default';
  }

  /// Set notification sound
  Future<void> setNotificationSound(String sound) async {
    await _prefs?.setString('notification_sound', sound);
  }

  // ========== Backup Settings ==========

  /// Check if auto backup is enabled
  bool get autoBackupEnabled {
    return _prefs?.getBool('auto_backup_enabled') ?? false;
  }

  /// Set auto backup enabled
  Future<void> setAutoBackupEnabled(bool enabled) async {
    await _prefs?.setBool('auto_backup_enabled', enabled);

    if (enabled) {
      // Schedule backup
      await _scheduleBackup();
      debugPrint('Auto backup enabled - scheduled daily backups');
    } else {
      debugPrint('Auto backup disabled');
    }
  }

  /// Get last backup time
  DateTime? get lastBackupTime {
    final timestamp = _prefs?.getInt('last_backup_timestamp');
    return timestamp != null
        ? DateTime.fromMillisecondsSinceEpoch(timestamp)
        : null;
  }

  /// Perform manual backup
  Future<bool> performBackup() async {
    try {
      // Simulate backup process
      await Future.delayed(const Duration(seconds: 2));

      // Save backup timestamp
      await _prefs?.setInt(
          'last_backup_timestamp', DateTime.now().millisecondsSinceEpoch);

      debugPrint('Backup completed successfully at ${DateTime.now()}');
      return true;
    } catch (e) {
      debugPrint('Backup failed: $e');
      return false;
    }
  }

  /// Schedule automatic backup
  Future<void> _scheduleBackup() async {
    // In a real app, you would use a background task scheduler
    // For demo purposes, we'll just log it
    debugPrint('Background backup task scheduled');
  }

  // ========== General Settings ==========

  /// Get refresh rate (in seconds)
  double get refreshRate {
    return _prefs?.getDouble('refresh_rate') ?? 2.0;
  }

  /// Set refresh rate
  Future<void> setRefreshRate(double rate) async {
    await _prefs?.setDouble('refresh_rate', rate);
  }

  /// Get language
  String get language {
    return _prefs?.getString('language') ?? 'English';
  }

  /// Set language
  Future<void> setLanguage(String language) async {
    await _prefs?.setString('language', language);
  }

  /// Clear all settings (factory reset)
  Future<void> clearAllSettings() async {
    await _prefs?.clear();
    debugPrint('All settings cleared');
  }
}
