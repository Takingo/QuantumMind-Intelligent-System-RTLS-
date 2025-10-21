import 'package:flutter/material.dart';
import '../theme/theme_config.dart';

/// Quantum-style animated background
class QuantumBackground extends StatelessWidget {
  final Widget child;
  final bool showParticles;
  final bool showEnergyLines;

  const QuantumBackground({
    super.key,
    required this.child,
    this.showParticles = true,
    this.showEnergyLines = true,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: ThemeConfig.darkBgGradient,
      ),
      child: child,
    );
  }
}
