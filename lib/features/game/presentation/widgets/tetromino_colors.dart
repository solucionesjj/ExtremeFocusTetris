import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/tetromino_type.dart';

/// Single source of truth mapping a piece type to its display color —
/// spec.md section 4.2. Pass [focusMode] to get Focus Mode's slightly
/// desaturated variant (spec.md section 9.2: -10% saturation, to reinforce
/// the calmer feel), and [colorblindMode] to swap in the alternate palette
/// of spec.md section 14 (see `_colorblindPalette` for the rationale) —
/// pair it with `textureForTetromino` (`cell_texture.dart`) so pieces stay
/// distinguishable by shape too, not just hue.
Color colorForTetromino(TetrominoType type, {bool focusMode = false, bool colorblindMode = false}) {
  final base = colorblindMode ? _colorblindPalette(type) : _standardPalette(type);
  if (!focusMode) return base;
  final hsl = HSLColor.fromColor(base);
  return hsl.withSaturation((hsl.saturation - 0.1).clamp(0.0, 1.0)).toColor();
}

Color _standardPalette(TetrominoType type) => switch (type) {
  TetrominoType.i => AppColors.blockI,
  TetrominoType.o => AppColors.blockO,
  TetrominoType.t => AppColors.blockT,
  TetrominoType.s => AppColors.blockS,
  TetrominoType.z => AppColors.blockZ,
  TetrominoType.j => AppColors.blockJ,
  TetrominoType.l => AppColors.blockL,
};

/// The Okabe-Ito colorblind-safe qualitative palette (Okabe & Ito, 2008),
/// widely recommended because its 8 colors stay distinguishable under
/// protanopia, deuteranopia, and tritanopia simulations alike — spec.md
/// section 14 asks for one palette validated across all three, not a
/// per-condition variant.
Color _colorblindPalette(TetrominoType type) => switch (type) {
  TetrominoType.i => const Color(0xFF56B4E9), // Sky Blue
  TetrominoType.o => const Color(0xFFF0E442), // Yellow
  TetrominoType.t => const Color(0xFFCC79A7), // Reddish Purple
  TetrominoType.s => const Color(0xFF009E73), // Bluish Green
  TetrominoType.z => const Color(0xFFD55E00), // Vermillion
  TetrominoType.j => const Color(0xFF0072B2), // Blue
  TetrominoType.l => const Color(0xFFE69F00), // Orange
};
