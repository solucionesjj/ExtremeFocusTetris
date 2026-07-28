import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../viewmodels/game_controller.dart';

/// On-screen controls — spec.md section 8.4. Left/right use DAS (170ms)
/// then ARR (30ms) auto-repeat while held; soft drop is a plain
/// press-and-hold flag consumed by [GameController.onTick]; rotate, hold
/// and hard drop are single-shot taps.
class TouchControls extends ConsumerWidget {
  const TouchControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(gameControllerProvider.notifier);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _RepeatingButton(icon: Icons.chevron_left, onTrigger: controller.moveLeft),
        _HoldButton(
          icon: Icons.arrow_downward,
          onHeldChanged: controller.setSoftDropHeld,
        ),
        _RepeatingButton(icon: Icons.chevron_right, onTrigger: controller.moveRight),
        _TapButton(icon: Icons.rotate_left, onTap: controller.rotateCounterClockwise),
        _TapButton(icon: Icons.rotate_right, onTap: controller.rotateClockwise),
        _TapButton(icon: Icons.swap_horiz, onTap: controller.hold),
        _TapButton(icon: Icons.vertical_align_bottom, onTap: controller.hardDrop),
      ],
    );
  }
}

class _TapButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _TapButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => _ControlButton(icon: icon, onTap: onTap);
}

class _RepeatingButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTrigger;

  const _RepeatingButton({required this.icon, required this.onTrigger});

  @override
  State<_RepeatingButton> createState() => _RepeatingButtonState();
}

class _RepeatingButtonState extends State<_RepeatingButton> {
  static const _delayedAutoShift = Duration(milliseconds: 170);
  static const _autoRepeatRate = Duration(milliseconds: 30);

  Timer? _dasTimer;
  Timer? _arrTimer;

  void _start() {
    widget.onTrigger();
    _dasTimer = Timer(_delayedAutoShift, () {
      _arrTimer = Timer.periodic(_autoRepeatRate, (_) => widget.onTrigger());
    });
  }

  void _stop() {
    _dasTimer?.cancel();
    _arrTimer?.cancel();
    _dasTimer = null;
    _arrTimer = null;
  }

  @override
  void dispose() {
    _stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _ControlButton(
      icon: widget.icon,
      onTapDown: (_) => _start(),
      onTapUp: (_) => _stop(),
      onTapCancel: _stop,
    );
  }
}

class _HoldButton extends StatelessWidget {
  final IconData icon;
  final ValueChanged<bool> onHeldChanged;

  const _HoldButton({required this.icon, required this.onHeldChanged});

  @override
  Widget build(BuildContext context) {
    return _ControlButton(
      icon: icon,
      onTapDown: (_) => onHeldChanged(true),
      onTapUp: (_) => onHeldChanged(false),
      onTapCancel: () => onHeldChanged(false),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final GestureTapDownCallback? onTapDown;
  final GestureTapUpCallback? onTapUp;
  final VoidCallback? onTapCancel;

  const _ControlButton({
    required this.icon,
    this.onTap,
    this.onTapDown,
    this.onTapUp,
    this.onTapCancel,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onTapDown: onTapDown,
      onTapUp: onTapUp,
      onTapCancel: onTapCancel,
      child: Container(
        width: 48,
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(icon, color: Theme.of(context).colorScheme.onSurface),
      ),
    );
  }
}
