import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:gr0ve/config/home_prefs.dart';
import '../../utils/home_typography.dart';
import '../common/hover_detector.dart';

class DayCell extends StatelessWidget {
  const DayCell({
    super.key,
    required this.p,
    required this.date,
    required this.isSel,
    required this.isToday,
    required this.hasDot,
    required this.onTap,
  });

  final Palette p;
  final DateTime date;
  final bool isSel;
  final bool isToday;
  final bool hasDot;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => HoverDetector(
    onTap: onTap,
    builder: (h) => AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: isSel ? p.accent : (h ? p.line : Colors.transparent),
        borderRadius: BorderRadius.circular(12),
        border: isToday && !isSel
            ? Border.all(color: p.accent, width: 1.5)
            : null,
      ),
      child: LayoutBuilder(
        builder: (context, c) {
          final top = math.min(c.maxHeight / 2 + 11, c.maxHeight - 6);
          return Stack(
            alignment: Alignment.center,
            children: [
              Text(
                '${date.day}',
                style: uiStyle(13, isSel ? p.onAccent : p.text),
              ),
              if (hasDot)
                Positioned(
                  top: top,
                  child: Container(
                    width: 3,
                    height: 3,
                    decoration: BoxDecoration(
                      color: isSel ? p.onAccent : p.accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    ),
  );
}
