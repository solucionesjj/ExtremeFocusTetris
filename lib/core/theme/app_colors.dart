import 'package:flutter/material.dart';

/// Color palette — spec.md section 4.2. Each token's rationale lives there;
/// keep this file as the single place literal hex values are written.
abstract final class AppColors {
  static const Color primary = Color(0xFF3FA9F5);
  static const Color secondary = Color(0xFFFFD23F);

  static const Color backgroundDark = Color(0xFF12162B);
  static const Color backgroundLight = Color(0xFFFFF8ED);

  static const Color surfaceDark = Color(0xFF1E2340);
  static const Color surfaceLight = Color(0xFFFFFFFF);

  static const Color blockI = Color(0xFF4FD3E8);
  static const Color blockO = Color(0xFFFFD23F);
  static const Color blockT = Color(0xFFC77DFF);
  static const Color blockS = Color(0xFF4CD97B);
  static const Color blockZ = Color(0xFFFF6B6B);
  static const Color blockJ = Color(0xFF5C7CFA);
  static const Color blockL = Color(0xFFFF9F45);

  static const Color particles = Color(0xFFFFF4D6);

  static const Color hudPanelOnDark = Color(0x14FFFFFF);
  static const Color hudPanelOnLight = Color(0x0F12162B);

  static const Color buttonPrimary = Color(0xFFFF6B6B);
  static const Color buttonConfirm = Color(0xFF4CD97B);

  static const Color textOnDark = Color(0xFFF5F5F5);
  static const Color textOnLight = Color(0xFF1B1F3B);

  static const Color fxSpecialStart = Color(0xFFFFD23F);
  static const Color fxSpecialEnd = Color(0xFFFF6B6B);
}
