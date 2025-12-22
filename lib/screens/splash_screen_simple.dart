import 'package:flutter/material.dart';
import 'dart:async';
import 'login_screen.dart';

/// Splash Screen with WORKING Animations
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _opacity = 0.0;
  double _scale = 0.8;
  final bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    // Start fade-in and scale animation
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _opacity = 1.0;
          _scale = 1.0;
        });
      }
    });

    // Navigate to login after 3 seconds (Demo mode - no auth check)
    Timer(const Duration(seconds: 3), () {
      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          child: AnimatedOpacity(
            opacity: _opacity,
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeIn,
            child: AnimatedScale(
              scale: _scale,
              duration: const Duration(milliseconds: 1200),
              curve: Curves.elasticOut,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo with glow
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(35),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00FFC6).withOpacity(0.6),
                          blurRadius: 50,
                          spreadRadius: 15,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(35),
                      child: Image.asset(
                        'assets/logo/Quantum Mind Logo 2.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFF007AFF), Color(0xFF00FFC6)],
                              ),
                              borderRadius: BorderRadius.circular(35),
                            ),
                            child: const Icon(
                              Icons.hub_rounded,
                              size: 120,
                              color: Colors.white,
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 50),

                  // Gradient Text
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFF007AFF), Color(0xFF00FFC6)],
                    ).createShader(bounds),
                    child: const Text(
                      'QuantumMind',
                      style: TextStyle(
                        fontSize: 52,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'Intelligent UWB System',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFF00FFC6),
                      letterSpacing: 4,
                      fontWeight: FontWeight.w300,
                    ),
                  ),

                  const SizedBox(height: 70),

                  // Pulsing Circle Animation
                  _PulsingCircle(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Pulsing Circle Widget
class _PulsingCircle extends StatefulWidget {
  @override
  State<_PulsingCircle> createState() => _PulsingCircleState();
}

class _PulsingCircleState extends State<_PulsingCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_controller.value * 0.3),
          child: Opacity(
            opacity: 1.0 - (_controller.value * 0.5),
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF00FFC6),
                  width: 3,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
