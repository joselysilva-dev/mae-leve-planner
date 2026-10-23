import 'package:flutter/material.dart';

abstract final class AppColors {
  // Cor principal
  static const Color primary = Color(0xFF8B6BB1);
  static const Color primaryLight = Color(0xFFEDE4F5);
  static const Color primaryDark = Color(0xFF60447E);

  // Cor secundária
  static const Color secondary = Color(0xFF94BFA7);
  static const Color secondaryLight = Color(0xFFE6F1EA);

  // Fundos
  static const Color background = Color(0xFFFCF9FD);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSoft = Color(0xFFF5EFF8);

  // Textos
  static const Color textPrimary = Color(0xFF302A35);
  static const Color textSecondary = Color(0xFF756C7A);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Interface
  static const Color border = Color(0xFFE5DCE9);
  static const Color disabled = Color(0xFFC9C1CD);
  static const Color success = Color(0xFF5E9E78);
  static const Color warning = Color(0xFFE3A853);
  static const Color error = Color(0xFFC95C6A);
}
