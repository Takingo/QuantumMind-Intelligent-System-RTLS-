import 'package:flutter/material.dart';
import '../theme/theme_config.dart';
import '../models/user_model.dart';

/// Application header bar
class HeaderBar extends StatelessWidget {
  final UserModel? user;
  final VoidCallback? onProfileTap;
  final VoidCallback? onLanguageChange;
  final VoidCallback? onThemeToggle;
  final String currentLanguage;
  final bool isDarkMode;
  
  const HeaderBar({
    Key? key,
    this.user,
    this.onProfileTap,
    this.onLanguageChange,
    this.onThemeToggle,
    this.currentLanguage = 'EN',
    this.isDarkMode = true,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: isDarkMode 
            ? ThemeConfig.cardDark.withOpacity(0.8)
            : Colors.white.withOpacity(0.9),
        boxShadow: ThemeConfig.cardShadow,
      ),
      child: Row(
        children: [
          // Logo
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: ThemeConfig.quantumGradient,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: ThemeConfig.neonGlowBlue,
                ),
                child: const Icon(
                  Icons.hub,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'QuantumMind',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDarkMode 
                              ? ThemeConfig.textPrimary 
                              : ThemeConfig.textLight,
                        ),
                  ),
                  Text(
                    'Innovation',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: ThemeConfig.energyGreen,
                        ),
                  ),
                ],
              ),
            ],
          ),
          
          const Spacer(),
          
          // Right side controls
          Row(
            children: [
              // Language selector
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.language,
                  color: isDarkMode 
                      ? ThemeConfig.textPrimary 
                      : ThemeConfig.textLight,
                ),
                onSelected: (value) {
                  onLanguageChange?.call();
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'en', child: Text('🇬🇧 English')),
                  const PopupMenuItem(value: 'de', child: Text('🇩🇪 Deutsch')),
                  const PopupMenuItem(value: 'tr', child: Text('🇹🇷 Türkçe')),
                ],
              ),
              
              const SizedBox(width: 16),
              
              // Theme toggle
              IconButton(
                icon: Icon(
                  isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  color: isDarkMode 
                      ? ThemeConfig.textPrimary 
                      : ThemeConfig.textLight,
                ),
                onPressed: onThemeToggle,
              ),
              
              const SizedBox(width: 16),
              
              // User profile
              if (user != null)
                InkWell(
                  onTap: onProfileTap,
                  borderRadius: BorderRadius.circular(25),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: ThemeConfig.quantumBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: ThemeConfig.quantumBlue.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: ThemeConfig.quantumBlue,
                          backgroundImage: user!.avatarUrl != null
                              ? NetworkImage(user!.avatarUrl!)
                              : null,
                          child: user!.avatarUrl == null
                              ? Text(
                                  user!.name[0].toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              user!.name,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: isDarkMode 
                                        ? ThemeConfig.textPrimary 
                                        : ThemeConfig.textLight,
                                  ),
                            ),
                            Text(
                              user!.role,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: ThemeConfig.energyGreen,
                                    fontSize: 10,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
