import 'package:flutter/widgets.dart';

class PressDetector extends StatefulWidget {
  const PressDetector({super.key, required this.onTap, required this.builder});

  final VoidCallback onTap;
  final Widget Function(bool pressed) builder;

  @override
  State<PressDetector> createState() => _PressDetectorState();
}

class _PressDetectorState extends State<PressDetector> {
  bool _d = false;

  @override
  Widget build(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: widget.onTap,
    onTapDown: (_) => setState(() => _d = true),
    onTapUp: (_) => setState(() => _d = false),
    onTapCancel: () => setState(() => _d = false),
    child: widget.builder(_d),
  );
}
