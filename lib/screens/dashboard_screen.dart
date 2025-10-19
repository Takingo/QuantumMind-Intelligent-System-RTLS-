import 'package:flutter/material.dart';
import '../theme/theme_config.dart';
import '../widgets/header_bar.dart';
import '../widgets/quantum_background.dart';
import '../widgets/dashboard_card.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import 'login_screen.dart';

/// Main Dashboard Screen
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);
  
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _authService = AuthService();
  UserModel? _currentUser;
  bool _isDarkMode = true;
  String _currentLanguage = 'EN';
  
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  
  Future<void> _loadUserData() async {
    final user = await _authService.getCurrentUserData();
    if (mounted) {
      setState(() => _currentUser = user);
    }
  }
  
  void _handleLogout() async {
    await _authService.signOut();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: QuantumBackground(
        child: Column(
          children: [
            // Header
            HeaderBar(
              user: _currentUser,
              currentLanguage: _currentLanguage,
              isDarkMode: _isDarkMode,
              onThemeToggle: () {
                setState(() => _isDarkMode = !_isDarkMode);
              },
              onLanguageChange: () {
                setState(() {
                  _currentLanguage = _currentLanguage == 'EN' ? 'DE' : 'EN';
                });
              },
              onProfileTap: () {
                // TODO: Navigate to profile
              },
            ),
            
            // Main content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome header
                    Text(
                      'Welcome back, ${_currentUser?.name ?? 'User'}!',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Real-time monitoring and control system',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: ThemeConfig.textSecondary,
                          ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Stats row
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Active Tags',
                            '24',
                            Icons.sensors,
                            ThemeConfig.energyGreen,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                            'Online Doors',
                            '8',
                            Icons.door_front_door,
                            ThemeConfig.quantumBlue,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                            'Sensors',
                            '12',
                            Icons.thermostat,
                            ThemeConfig.neonPurple,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Main grid
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: constraints.maxWidth > 1200 ? 2 : 1,
                          mainAxisSpacing: 24,
                          crossAxisSpacing: 24,
                          childAspectRatio: constraints.maxWidth > 1200 ? 1.5 : 1.2,
                          children: [
                            DashboardCard(
                              title: 'RTLS Live Map',
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.map,
                                      size: 64,
                                      color: ThemeConfig.quantumBlue,
                                    ),
                                    const SizedBox(height: 16),
                                    const Text('Live tracking map coming soon...'),
                                  ],
                                ),
                              ),
                            ),
                            DashboardCard(
                              title: 'Analytics',
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.bar_chart,
                                      size: 64,
                                      color: ThemeConfig.energyGreen,
                                    ),
                                    const SizedBox(height: 16),
                                    const Text('Charts and analytics coming soon...'),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Quick actions
                    DashboardCard(
                      title: 'Quick Actions',
                      child: Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          _buildActionButton(
                            'Door Control',
                            Icons.door_front_door,
                            () {},
                          ),
                          _buildActionButton(
                            'Tag Management',
                            Icons.sensors,
                            () {},
                          ),
                          _buildActionButton(
                            'Sensors',
                            Icons.thermostat,
                            () {},
                          ),
                          _buildActionButton(
                            'Settings',
                            Icons.settings,
                            () {},
                          ),
                          _buildActionButton(
                            'Logout',
                            Icons.logout,
                            _handleLogout,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: ThemeConfig.cardGradient,
        borderRadius: ThemeConfig.borderRadiusMedium,
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionButton(String label, IconData icon, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),
    );
  }
}
