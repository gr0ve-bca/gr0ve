import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

const starOutlineSvg =
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" '
    'stroke="black" stroke-width="2" stroke-linecap="round" '
    'stroke-linejoin="round"><path d="M11.525 2.295a.53.53 0 0 1 .95 0l2.31 '
    '4.679a2.123 2.123 0 0 0 1.595 1.16l5.166.756a.53.53 0 0 1 .294.904l-3.736 '
    '3.638a2.123 2.123 0 0 0-.611 1.878l.882 5.14a.53.53 0 0 1-.771.56l-4.618-'
    '2.428a2.122 2.122 0 0 0-1.973 0L6.396 21.01a.53.53 0 0 1-.77-.56l.881-'
    '5.139a2.122 2.122 0 0 0-.611-1.879L2.16 9.795a.53.53 0 0 1 .294-.906l'
    '5.165-.755a2.122 2.122 0 0 0 1.597-1.16z"/></svg>';

final starFilledSvg = starOutlineSvg.replaceFirst('fill="none"', 'fill="black"');

class StarButton extends StatefulWidget {
  const StarButton({
    super.key,
    required this.on,
    required this.idle,
    required this.hover,
    required this.pressed,
    required this.onTap,
  });

  final bool on;
  final Color idle;
  final Color hover;
  final Color pressed;
  final VoidCallback onTap;

  @override
  State<StarButton> createState() => _StarButtonState();
}

class _StarButtonState extends State<StarButton> {
  bool _hover = false;
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final lit = widget.on || _down;
    final color = lit ? widget.pressed : (_hover ? widget.hover : widget.idle);
    return Tooltip(
      message: widget.on ? 'Unstar' : 'Star',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() {
          _hover = false;
          _down = false;
        }),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => setState(() => _down = true),
          onTapUp: (_) => setState(() => _down = false),
          onTapCancel: () => setState(() => _down = false),
          onTap: widget.onTap,
          child: SizedBox(
            width: 34,
            height: 34,
            child: Center(
              child: SvgPicture.string(
                lit || _hover ? starFilledSvg : starOutlineSvg,
                width: 20,
                height: 20,
                colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
