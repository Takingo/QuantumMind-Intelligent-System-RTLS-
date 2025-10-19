import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Custom animation utilities for quantum effects
class QuantumAnimations {
  // ========== Fade Animations ==========
  
  /// Fade in animation
  static Widget fadeIn({
    required Widget child,
    Duration duration = const Duration(milliseconds: 300),
    Duration delay = Duration.zero,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: child,
      ),
      child: child,
    );
  }
  
  /// Fade in from bottom
  static Widget fadeInUp({
    required Widget child,
    Duration duration = const Duration(milliseconds: 500),
    double offset = 50,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      curve: Curves.easeOut,
      builder: (context, value, child) => Transform.translate(
        offset: Offset(0, offset * (1 - value)),
        child: Opacity(
          opacity: value,
          child: child,
        ),
      ),
      child: child,
    );
  }
  
  // ========== Glow Animations ==========
  
  /// Pulsing glow effect
  static Widget pulseGlow({
    required Widget child,
    Color color = const Color(0xFF007AFF),
    Duration duration = const Duration(seconds: 2),
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        final glowValue = (math.sin(value * 2 * math.pi) + 1) / 2;
        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(glowValue * 0.5),
                blurRadius: 20 + glowValue * 10,
                spreadRadius: 2 + glowValue * 3,
              ),
            ],
          ),
          child: child,
        );
      },
      child: child,
      onEnd: () {
        // Repeat animation
      },
    );
  }
  
  // ========== Particle Effects ==========
  
  /// Floating particles background
  static Widget particleBackground({
    int particleCount = 50,
    Color particleColor = const Color(0xFF007AFF),
  }) {
    return CustomPaint(
      painter: ParticlePainter(
        particleCount: particleCount,
        particleColor: particleColor,
      ),
      size: Size.infinite,
    );
  }
  
  // ========== Energy Lines ==========
  
  /// Animated energy lines
  static Widget energyLines({
    Color color = const Color(0xFF00FFC6),
    int lineCount = 5,
  }) {
    return CustomPaint(
      painter: EnergyLinePainter(
        color: color,
        lineCount: lineCount,
      ),
      size: Size.infinite,
    );
  }
  
  // ========== Scale Animations ==========
  
  /// Scale on hover/tap
  static Widget scaleOnTap({
    required Widget child,
    required VoidCallback onTap,
    double scale = 0.95,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.0, end: 1.0),
      duration: const Duration(milliseconds: 100),
      builder: (context, value, child) => Transform.scale(
        scale: value,
        child: GestureDetector(
          onTapDown: (_) {
            // Trigger scale down
          },
          onTapUp: (_) {
            onTap();
          },
          onTapCancel: () {
            // Trigger scale up
          },
          child: child,
        ),
      ),
      child: child,
    );
  }
}

// ========== Custom Painters ==========

/// Particle painter for background effect
class ParticlePainter extends CustomPainter {
  final int particleCount;
  final Color particleColor;
  final List<Particle> particles = [];
  
  ParticlePainter({
    required this.particleCount,
    required this.particleColor,
  }) {
    // Initialize particles
    for (int i = 0; i < particleCount; i++) {
      particles.add(Particle(
        x: math.Random().nextDouble(),
        y: math.Random().nextDouble(),
        size: math.Random().nextDouble() * 3 + 1,
        speed: math.Random().nextDouble() * 0.5 + 0.1,
      ));
    }
  }
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = particleColor.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    
    for (final particle in particles) {
      canvas.drawCircle(
        Offset(particle.x * size.width, particle.y * size.height),
        particle.size,
        paint,
      );
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class Particle {
  double x;
  double y;
  double size;
  double speed;
  
  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
  });
}

/// Energy line painter
class EnergyLinePainter extends CustomPainter {
  final Color color;
  final int lineCount;
  
  EnergyLinePainter({
    required this.color,
    required this.lineCount,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.2)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
    for (int i = 0; i < lineCount; i++) {
      final path = Path();
      final y = (size.height / (lineCount + 1)) * (i + 1);
      
      path.moveTo(0, y);
      
      for (double x = 0; x < size.width; x += 20) {
        final wave = math.sin((x / size.width) * 2 * math.pi + i) * 10;
        path.lineTo(x, y + wave);
      }
      
      canvas.drawPath(path, paint);
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Shimmer loading effect
class ShimmerLoading extends StatefulWidget {
  final Widget child;
  final Duration duration;
  
  const ShimmerLoading({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
  }) : super(key: key);
  
  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
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
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: const [
                Colors.grey,
                Colors.white,
                Colors.grey,
              ],
              stops: [
                _controller.value - 0.3,
                _controller.value,
                _controller.value + 0.3,
              ],
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
