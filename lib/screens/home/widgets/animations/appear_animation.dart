import 'package:flutter/material.dart';
import 'motion_utils.dart';

class AppearAnimation extends StatefulWidget {
  const AppearAnimation({
    super.key,
    required this.index,
    required this.child,
    this.step = 45,
    this.dy = 0.12,
  });

  final int index;
  final int step;
  final double dy;
  final Widget child;

  @override
  State<AppearAnimation> createState() => _AppearAnimationState();
}

class _AppearAnimationState extends State<AppearAnimation>
    with SingleTickerProviderStateMixin {
  static const _dur = 380;
  late final AnimationController _c;
  late final Animation<double> _a;

  @override
  void initState() {
    super.initState();
    final delay = (widget.index > 7 ? 7 : widget.index) * widget.step;
    _c = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: _dur + delay),
    );
    _a = CurvedAnimation(
      parent: _c,
      curve: Interval(delay / (_dur + delay), 1, curve: Curves.easeOutCubic),
    );
    if (widget.index >= 12 || reduceMotion()) {
      _c.value = 1;
    } else {
      _c.forward();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _a,
    child: SlideTransition(
      position: Tween(
        begin: Offset(0, widget.dy),
        end: Offset.zero,
      ).animate(_a),
      child: widget.child,
    ),
  );
}
