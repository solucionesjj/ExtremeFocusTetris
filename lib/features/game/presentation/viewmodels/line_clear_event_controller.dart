import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'line_clear_event.dart';

part 'line_clear_event_controller.g.dart';

/// A one-shot event stream (spec.md section 18): [GameController] emits
/// here whenever a lock clears at least one line, and `GameScreen` listens
/// via `ref.listen` to trigger particles/flash/shake without any of that
/// visual bookkeeping leaking into [GameState] itself.
@riverpod
class LineClearEventController extends _$LineClearEventController {
  int _sequence = 0;

  @override
  LineClearEvent? build() => null;

  void emit(List<int> clearedRowIndices) {
    _sequence++;
    state = LineClearEvent(
      clearedRowIndices: clearedRowIndices,
      linesCleared: clearedRowIndices.length,
      sequence: _sequence,
    );
  }
}
