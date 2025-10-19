import 'package:flutter/material.dart';
import '../theme/theme_config.dart';
import '../utils/animations.dart';

/// Quantum-style animated background
class QuantumBackground extends StatelessWidget {
  final Widget child;
  final bool showParticles;
  final bool showEnergyLines;
  
  const QuantumBackground({
    Key? key,
    required this.child,
    this.showParticles = true,
    this.showEnergyLines = true,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: ThemeConfig.darkBgGradient,
      ),
      child: Stack(
        children: [
          // Energy lines background
          if (showEnergyLines)
            Positioned.fill(
              child: QuantumAnimations.energyLines(
                color: ThemeConfig.quantumBlue,
                lineCount: 5,
              ),
            ),
          
          // Particle effect
          if (showParticles)
            Positioned.fill(
              child: QuantumAnimations.particleBackground(
                particleCount: 30,
                particleColor: ThemeConfig.energyGreen,
              ),
            ),
          
          // Content
          child,
        ],
      ),
    );
  }
}
