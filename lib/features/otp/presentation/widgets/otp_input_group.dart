import 'package:flutter/material.dart';

/// Staggers its [children] in with a short fade + upward slide, each one
/// starting slightly after the previous (phone-number line, then the OTP
/// digit fields, then whatever follows). Purely a reveal wrapper — it does
/// not know or care what the children are.
class OtpInputGroup extends StatefulWidget {
  const OtpInputGroup({super.key, required this.children, this.spacing = 0});

  final List<Widget> children;
  final double spacing;

  @override
  State<OtpInputGroup> createState() => _OtpInputGroupState();
}

class _OtpInputGroupState extends State<OtpInputGroup>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    // Small head start so the header (its own 650ms entrance) reads first.
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.children.length;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Column(
          children: [
            for (var i = 0; i < count; i++) ...[
              if (i > 0) SizedBox(height: widget.spacing),
              _staggered(i, count, widget.children[i]),
            ],
          ],
        );
      },
    );
  }

  Widget _staggered(int index, int count, Widget child) {
    final start = (index / count) * 0.6;
    final end = start + 0.4;
    final curved = CurvedAnimation(
      parent: _controller,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
    return Opacity(
      opacity: curved.value,
      child: Transform.translate(
        offset: Offset(0, (1 - curved.value) * 14),
        child: child,
      ),
    );
  }
}
