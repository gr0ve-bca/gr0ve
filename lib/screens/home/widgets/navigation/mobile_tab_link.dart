import 'package:flutter/material.dart';
import 'package:gr0ve/config/home_prefs.dart';
import '../../utils/home_helpers.dart';
import '../../utils/home_typography.dart';
import '../common/hover_detector.dart';

class MobileTabLink extends StatelessWidget {
  const MobileTabLink({
    super.key,
    required this.p,
    required this.label,
    required this.onTap,
  });

  final Palette p;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => HoverDetector(
    onTap: onTap,
    builder: (h) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: h ? p.tint : p.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: h ? p.accent : edgeColor(p, true),
          width: borderWidth(true),
        ),
      ),
      child: Text(label, style: uiStyle(11, h ? p.ink : p.text)),
    ),
  );
}
