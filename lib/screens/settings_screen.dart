import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/theme_provider.dart';
import '../services/auth_service.dart';
import '../services/settings_service.dart';
import '../services/localization_service.dart';
import 'login_screen.dart';

/// Settings Screen
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _settingsService = SettingsService.instance;
  bool _notifications = true;
  bool _autoBackup = false;
  double _refreshRate = 2.0;
  DateTime? _lastBackupTime;
  bool _isBackingUp = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _notifications = _settingsService.notificationsEnabled;
      _autoBackup = _settingsService.autoBackupEnabled;
      _refreshRate = _settingsService.refreshRate;
      _lastBackupTime = _settingsService.lastBackupTime;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0C10),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F2937),
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Appearance Section
            _buildSectionHeader('Appearance'),
            _buildSettingCard(
              child: Consumer<ThemeProvider>(
                builder: (context, themeProvider, _) {
                  return SwitchListTile(
                    title: const Text(
                      'Dark Mode',
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: const Text(
                      'Use dark theme',
                      style: TextStyle(color: Colors.grey),
                    ),
                    value: themeProvider.isDarkMode,
                    activeThumbColor: const Color(0xFF007AFF),
                    onChanged: (value) {
                      themeProvider.setDarkMode(value);
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Notifications Section
            _buildSectionHeader('Notifications'),
            _buildSettingCard(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text(
                      'Enable Notifications',
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: const Text(
                      'Receive alerts and updates',
                      style: TextStyle(color: Colors.grey),
                    ),
                    value: _notifications,
                    activeThumbColor: const Color(0xFF007AFF),
                    onChanged: (value) async {
                      await _settingsService.setNotificationsEnabled(value);
                      setState(() => _notifications = value);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Notifications ${value ? 'enabled' : 'disabled'}',
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  const Divider(color: Colors.grey),
                  ListTile(
                    title: const Text(
                      'Notification Sound',
                      style: TextStyle(color: Colors.white),
                    ),
                    trailing:
                        const Icon(Icons.chevron_right, color: Colors.grey),
                    onTap: () {
                      // TODO: Show sound picker
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // System Section
            _buildSectionHeader('System'),
            _buildSettingCard(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text(
                      'Auto Backup',
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      _lastBackupTime != null
                          ? 'Last backup: ${DateFormat('dd MMM yyyy, HH:mm').format(_lastBackupTime!)}'
                          : 'Never backed up',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    value: _autoBackup,
                    activeThumbColor: const Color(0xFF007AFF),
                    onChanged: (value) async {
                      await _settingsService.setAutoBackupEnabled(value);
                      setState(() => _autoBackup = value);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Auto backup ${value ? 'enabled' : 'disabled'}',
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  const Divider(color: Colors.grey),
                  ListTile(
                    title: const Text(
                      'Backup Now',
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: const Text(
                      'Create manual backup',
                      style: TextStyle(color: Colors.grey),
                    ),
                    trailing: _isBackingUp
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.backup, color: Color(0xFF00FFC6)),
                    onTap: _isBackingUp ? null : _performBackup,
                  ),
                  const Divider(color: Colors.grey),
                  Consumer<LocalizationService>(
                    builder: (context, localizationService, _) {
                      return ListTile(
                        title: const Text(
                          'Language',
                          style: TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          localizationService.isGerman ? 'Deutsch' : 'English',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        trailing:
                            const Icon(Icons.chevron_right, color: Colors.grey),
                        onTap: () => _showLanguagePicker(localizationService),
                      );
                    },
                  ),
                  const Divider(color: Colors.grey),
                  ListTile(
                    title: const Text(
                      'Refresh Rate',
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      '${_refreshRate.toInt()} seconds',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Slider(
                      value: _refreshRate,
                      min: 1,
                      max: 10,
                      divisions: 9,
                      activeColor: const Color(0xFF007AFF),
                      onChanged: (value) {
                        setState(() => _refreshRate = value);
                      },
                      onChangeEnd: (value) async {
                        await _settingsService.setRefreshRate(value);
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Account Section
            _buildSectionHeader('Account'),
            _buildSettingCard(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.person, color: Color(0xFF007AFF)),
                    title: const Text(
                      'Profile',
                      style: TextStyle(color: Colors.white),
                    ),
                    trailing:
                        const Icon(Icons.chevron_right, color: Colors.grey),
                    onTap: () {
                      // TODO: Navigate to profile
                    },
                  ),
                  const Divider(color: Colors.grey),
                  ListTile(
                    leading: const Icon(Icons.lock, color: Color(0xFF007AFF)),
                    title: const Text(
                      'Change Password',
                      style: TextStyle(color: Colors.white),
                    ),
                    trailing:
                        const Icon(Icons.chevron_right, color: Colors.grey),
                    onTap: () {
                      // TODO: Navigate to change password
                    },
                  ),
                  const Divider(color: Colors.grey),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.redAccent),
                    title: const Text(
                      'Logout',
                      style: TextStyle(color: Colors.redAccent),
                    ),
                    onTap: _handleLogout,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // About Section
            _buildSectionHeader('About'),
            _buildSettingCard(
              child: Column(
                children: [
                  const ListTile(
                    title: Text(
                      'Version',
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      '1.0.0',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  const Divider(color: Colors.grey),
                  ListTile(
                    title: const Text(
                      'Privacy Policy',
                      style: TextStyle(color: Colors.white),
                    ),
                    trailing:
                        const Icon(Icons.chevron_right, color: Colors.grey),
                    onTap: () {
                      // TODO: Show privacy policy
                    },
                  ),
                  const Divider(color: Colors.grey),
                  ListTile(
                    title: const Text(
                      'Terms of Service',
                      style: TextStyle(color: Colors.white),
                    ),
                    trailing:
                        const Icon(Icons.chevron_right, color: Colors.grey),
                    onTap: () {
                      // TODO: Show terms
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Color(0xFF00FFC6),
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildSettingCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF007AFF).withOpacity(0.2),
        ),
      ),
      child: child,
    );
  }

  Future<void> _performBackup() async {
    setState(() => _isBackingUp = true);

    final success = await _settingsService.performBackup();

    if (mounted) {
      setState(() {
        _isBackingUp = false;
        _lastBackupTime = _settingsService.lastBackupTime;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Backup completed successfully'
                : 'Backup failed. Please try again.',
          ),
          backgroundColor: success ? const Color(0xFF00FFC6) : Colors.redAccent,
        ),
      );
    }
  }

  void _showLanguagePicker(LocalizationService localizationService) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1F2937),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return ListView(
          shrinkWrap: true,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Select Language',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            ...[
              {'code': 'en', 'name': 'English'},
              {'code': 'de', 'name': 'Deutsch'},
            ].map((lang) {
              final isSelected =
                  localizationService.currentLanguage == lang['code'];
              return ListTile(
                title: Text(
                  lang['name']!,
                  style: const TextStyle(color: Colors.white),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check, color: Color(0xFF007AFF))
                    : null,
                onTap: () async {
                  await localizationService.setLanguage(lang['code']!);
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Language changed to ${lang['name']}'),
                      ),
                    );
                  }
                },
              );
            }),
          ],
        );
      },
    );
  }

  void _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F2937),
        title: const Text(
          'Logout',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await AuthService().signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }
}
