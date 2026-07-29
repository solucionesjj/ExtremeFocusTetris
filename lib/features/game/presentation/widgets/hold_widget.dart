import 'package:flutter/material.dart';

import '../../domain/entities/tetromino_type.dart';
import 'cell_texture.dart';
import 'tetromino_colors.dart';

/// The held piece slot — spec.md section 8.4. Dimmed while [isUsed] is true
/// (already swapped for the current piece, unavailable until it locks).
class HoldWidget extends StatelessWidget {
  final TetrominoType? holdPiece;
  final bool isUsed;
  final bool colorblindMode;

  const HoldWidget({
    super.key,
    required this.holdPiece,
    required this.isUsed,
    this.colorblindMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final piece = holdPiece;
    return Opacity(
      opacity: isUsed ? 0.4 : 1,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: piece == null ? Colors.transparent : colorForTetromino(piece, colorblindMode: colorblindMode),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black.withValues(alpha: 0.18), width: 2),
        ),
        child: (colorblindMode && piece != null)
            ? CustomPaint(painter: CellTexturePainter(textureForTetromino(piece)), size: const Size(40, 40))
            : null,
      ),
    );
  }
}
