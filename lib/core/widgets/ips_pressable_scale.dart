import 'package:flutter/material.dart';

/// Wraps any tappable child with a small, refined press-down scale — the
/// shared "physical button" micro-interaction used across the app's
/// branded screens (Welcome's entry actions, Registration's action
/// button) instead of Material's default ink splash alone. Purely visual:
/// it doesn't intercept taps, so the wrapped widget's own [onPressed] (or
/// equivalent) still fires normally through the [Listener] passthrough.
class IpsPressableScale extends StatefulWidget {
  const IpsPressableScale({super.key, required this.child});

  final Widget child;

  @override
  State<IpsPressableScale> createState() => _IpsPressableScaleState();
}

class _IpsPressableScaleState extends State<IpsPressableScale> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _setPressed(true),
      onPointerUp: (_) => _setPressed(false),
      onPointerCancel: (_) => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
