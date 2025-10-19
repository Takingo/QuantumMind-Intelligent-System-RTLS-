import 'package:flutter/material.dart';
import '../theme/theme_config.dart';

/// Dashboard card widget with quantum styling
class DashboardCard extends StatelessWidget {
  final String title;
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final bool showGlow;
  
  const DashboardCard({
    Key? key,
    required this.title,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.onTap,
    this.showGlow = false,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: ThemeConfig.cardGradient,
        borderRadius: ThemeConfig.borderRadiusLarge,
        boxShadow: showGlow ? ThemeConfig.neonGlowBlue : ThemeConfig.cardShadow,
        border: Border.all(
          color: ThemeConfig.quantumBlue.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: ThemeConfig.borderRadiusLarge,
          child: Padding(
            padding: padding ?? const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title with underline accent
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 24,
                      decoration: BoxDecoration(
                        gradient: ThemeConfig.quantumGradient,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Content
                Expanded(child: child),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
