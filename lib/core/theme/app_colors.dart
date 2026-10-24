import 'package:flutter/material.dart';

abstract final class AppColors {
  // Cor principal
  static const Color primary = Color(0xFF8B6BB1);
  static const Color primaryLight = Color(0xFFEDE4F5);
  static const Color primaryDark = Color(0xFF60447E);

  // Tokens do protótipo oficial: Primary/700, Primary/900 e Primary/100.
  static const Color primaryStrong = Color(0xFF684C96);
  static const Color primaryInk = Color(0xFF49336F);
  static const Color primarySoft = Color(0xFFEEE8F6);
  static const Color secondarySoft = Color(0xFFE4F5F2);
  static const Color secondaryInk = Color(0xFF35766F);

  // Cor secundária
  static const Color secondary = Color(0xFF94BFA7);
  static const Color secondaryLight = Color(0xFFE6F1EA);

  // Fundos
  static const Color background = Color(0xFFFAF9FC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSoft = Color(0xFFF5EFF8);

  // Textos
  static const Color textPrimary = Color(0xFF25232A);
  static const Color textSecondary = Color(0xFF55515D);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Interface
  static const Color border = Color(0xFFCBC7D0);
  static const Color disabled = Color(0xFFC9C1CD);
  static const Color success = Color(0xFF5E9E78);
  static const Color warning = Color(0xFFE3A853);
  static const Color error = Color(0xFFC95C6A);
}
