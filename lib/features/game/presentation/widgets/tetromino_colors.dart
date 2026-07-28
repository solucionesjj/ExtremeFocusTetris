import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/tetromino_type.dart';

/// Single source of truth mapping a piece type to its display color —
/// spec.md section 4.2.
Color colorForTetromino(TetrominoType type) => switch (type) {
  TetrominoType.i => AppColors.blockI,
  TetrominoType.o => AppColors.blockO,
  TetrominoType.t => AppColors.blockT,
  TetrominoType.s => AppColors.blockS,
  TetrominoType.z => AppColors.blockZ,
  TetrominoType.j => AppColors.blockJ,
  TetrominoType.l => AppColors.blockL,
};
