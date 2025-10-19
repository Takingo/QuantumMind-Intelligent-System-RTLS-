import 'package:flutter/material.dart';
import 'theme/theme_config.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'services/auth_service.dart';

/// Main application widget
class QuantumMindApp extends StatelessWidget {
  const QuantumMindApp({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuantumMind RTLS',
      debugShowCheckedModeBanner: false,
      theme: ThemeConfig.lightTheme,
      darkTheme: ThemeConfig.darkTheme,
      themeMode: ThemeMode.dark,
      home: const AuthWrapper(),
    );
  }
}

/// Authentication wrapper to decide initial screen
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);
  
  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final _authService = AuthService();
  bool _isLoading = true;
  bool _isLoggedIn = false;
  
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }
  
  Future<void> _checkAuthStatus() async {
    await Future.delayed(const Duration(seconds: 1)); // Splash delay
    
    if (mounted) {
      setState(() {
        _isLoggedIn = _authService.isLoggedIn;
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SplashScreen();
    }
    
    return _isLoggedIn ? const DashboardScreen() : const LoginScreen();
  }
}

/// Splash screen
class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: ThemeConfig.darkBgGradient,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: ThemeConfig.quantumGradient,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: ThemeConfig.neonGlowBlue,
                ),
                child: const Icon(
                  Icons.hub,
                  size: 70,
                  color: Colors.white,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Title
              Text(
                'QuantumMind',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: ThemeConfig.textPrimary,
                    ),
              ),
              
              const SizedBox(height: 8),
              
              Text(
                'Innovation',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: ThemeConfig.energyGreen,
                    ),
              ),
              
              const SizedBox(height: 48),
              
              // Loading indicator
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  ThemeConfig.quantumBlue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
