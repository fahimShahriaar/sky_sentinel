import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary dark background gradient
  static const Color backgroundDark = Color(0xFF0A0E21);
  static const Color backgroundMedium = Color(0xFF0F1A2E);
  static const Color backgroundCard = Color(0xFF111B30);
  static const Color backgroundCardLight = Color(0xFF152038);

  // Accent
  static const Color accentCyan = Color(0xFF00D4FF);
  static const Color accentCyanDim = Color(0xFF0098B8);
  static const Color accentBlue = Color(0xFF1E88E5);
  static const Color accentTeal = Color(0xFF00BFA5);

  // Alert
  static const Color alertOrange = Color(0xFFFF9800);
  static const Color alertRed = Color(0xFFEF5350);
  static const Color alertYellow = Color(0xFFFFEB3B);

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8899AA);
  static const Color textTertiary = Color(0xFF556677);
  static const Color textAccent = Color(0xFF00D4FF);

  // UI
  static const Color cardBorder = Color(0xFF1A2A42);
  static const Color divider = Color(0xFF1A2540);
  static const Color shimmer = Color(0xFF1A2A42);

  // Gradient for cards
  static const LinearGradient cardGradient = LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF111B30), Color(0xFF0F1628)]);

  static const LinearGradient alertBannerGradient = LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: [Color(0xFF0A2840), Color(0xFF0F1A2E)]);
}
