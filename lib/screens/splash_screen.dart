import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'dashboard_screen.dart';

/// SIMPLE Splash Screen - GUARANTEED TO WORK
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    // Wait 2 seconds
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Check auth
    final authService = AuthService();
    final isLoggedIn = authService.isLoggedIn;

    // Navigate
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) =>
              isLoggedIn ? const DashboardScreen() : const LoginScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0C10),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0B0C10),
              Color(0xFF1B2735),
              Color(0xFF0B0C10),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Quantum Door Intelligent Logo
              Container(
                width: 250,
                height: 250,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00FFC6).withOpacity(0.3),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/logo/quantum_door_logo.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback: Custom icon representing the logo
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Door with headphones and waveform
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            // Circular background
                            Container(
                              width: 180,
                              height: 180,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF00756F),
                                  width: 8,
                                ),
                              ),
                            ),
                            // Door icon
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: const Color(0xFF00756F),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: const Icon(
                                Icons.sensor_door,
                                size: 80,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Network connection icon below
                        const Icon(
                          Icons.hub,
                          size: 40,
                          color: Color(0xFF00756F),
                        ),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: 40),

              // Text - Quantum Door Intelligent
              const Text(
                'QUANTUM DOOR',
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 3,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'INTELLIGENT',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 8,
                ),
              ),

              const SizedBox(height: 16),

              Container(
                height: 2,
                width: 200,
                color: Color(0xFF00756F),
              ),

              const SizedBox(height: 16),

              const Text(
                'QUANTUM MIND INNOVATION',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF00FFC6),
                  letterSpacing: 2,
                  fontWeight: FontWeight.w300,
                ),
              ),

              const SizedBox(height: 60),

              // Loading
              const CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00FFC6)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
