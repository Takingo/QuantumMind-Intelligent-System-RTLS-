import 'package:flutter/material.dart';
import '../theme/theme_config.dart';
import '../widgets/header_bar.dart';
import '../widgets/quantum_background.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

/// Settings Screen
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);
  
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _authService = AuthService();
  UserModel? _currentUser;
  
  @override
  void initState() {
    super.initState();
    _loadUser();
  }
  
  Future<void> _loadUser() async {
    final user = await _authService.getCurrentUserData();
    setState(() => _currentUser = user);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: QuantumBackground(
        child: Column(
          children: [
            HeaderBar(user: _currentUser),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.settings,
                      size: 100,
                      color: ThemeConfig.quantumBlue,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Settings',
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    const SizedBox(height: 16),
                    const Text('Settings screen coming soon...'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
