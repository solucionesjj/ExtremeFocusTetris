import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/tetromino_type.dart';

/// Single source of truth mapping a piece type to its display color —
/// spec.md section 4.2. Pass [focusMode] to get Focus Mode's slightly
/// desaturated variant (spec.md section 9.2: -10% saturation, to reinforce
/// the calmer feel).
Color colorForTetromino(TetrominoType type, {bool focusMode = false}) {
  final base = switch (type) {
    TetrominoType.i => AppColors.blockI,
    TetrominoType.o => AppColors.blockO,
    TetrominoType.t => AppColors.blockT,
    TetrominoType.s => AppColors.blockS,
    TetrominoType.z => AppColors.blockZ,
    TetrominoType.j => AppColors.blockJ,
    TetrominoType.l => AppColors.blockL,
  };
  if (!focusMode) return base;
  final hsl = HSLColor.fromColor(base);
  return hsl.withSaturation((hsl.saturation - 0.1).clamp(0.0, 1.0)).toColor();
}
