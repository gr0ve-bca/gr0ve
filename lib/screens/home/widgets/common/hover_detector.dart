import 'package:flutter/material.dart';

class HoverDetector extends StatefulWidget {
  const HoverDetector({
    super.key,
    required this.onTap,
    required this.builder,
    this.pressAsHover = false,
  });

  final VoidCallback onTap;
  final Widget Function(bool hover) builder;
  final bool pressAsHover;

  @override
  State<HoverDetector> createState() => _HoverDetectorState();
}

class _HoverDetectorState extends State<HoverDetector> {
  bool _h = false;
  bool _p = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
    cursor: SystemMouseCursors.click,
    onEnter: (_) => setState(() => _h = true),
    onExit: (_) => setState(() => _h = false),
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onTapDown: widget.pressAsHover ? (_) => setState(() => _p = true) : null,
      onTapUp: widget.pressAsHover ? (_) => setState(() => _p = false) : null,
      onTapCancel: widget.pressAsHover
          ? () => setState(() => _p = false)
          : null,
      child: widget.builder(_h || _p),
    ),
  );
}
