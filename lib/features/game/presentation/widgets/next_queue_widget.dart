import 'package:flutter/material.dart';

import '../../domain/entities/tetromino_type.dart';
import 'tetromino_colors.dart';

/// Preview of the upcoming pieces — spec.md section 8.4 (3 pieces in
/// Classic mode, 1 in Focus mode).
class NextQueueWidget extends StatelessWidget {
  final List<TetrominoType> upcoming;
  final int visibleCount;
  final bool focusMode;

  const NextQueueWidget({
    super.key,
    required this.upcoming,
    this.visibleCount = 3,
    this.focusMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final type in upcoming.take(visibleCount))
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: _PieceSwatch(type: type, focusMode: focusMode),
          ),
      ],
    );
  }
}

class _PieceSwatch extends StatelessWidget {
  final TetrominoType type;
  final bool focusMode;

  const _PieceSwatch({required this.type, required this.focusMode});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: colorForTetromino(type, focusMode: focusMode),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black.withValues(alpha: 0.18), width: 2),
      ),
    );
  }
}
