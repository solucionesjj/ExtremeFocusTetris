import 'package:flutter/material.dart';

/// Typography roles — spec.md section 5. Fredoka (display/titles) and Nunito
/// (body/HUD) are referenced by family name even though the .ttf assets are
/// not bundled yet: Flutter falls back to the platform default font when a
/// named family isn't registered, so text renders correctly today and will
/// pick up the real typeface automatically once the font assets and the
/// `fonts:` entry in pubspec.yaml are added.
abstract final class AppTextStyles {
  static const String fredoka = 'Fredoka';
  static const String nunito = 'Nunito';

  static const TextStyle displayLarge = TextStyle(
    fontFamily: fredoka,
    fontSize: 34,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: fredoka,
    fontSize: 24,
    fontWeight: FontWeight.w500,
    height: 1.25,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: fredoka,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: nunito,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: nunito,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: nunito,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );
}
