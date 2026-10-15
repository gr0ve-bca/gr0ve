import 'package:flutter/material.dart';
import 'package:gr0ve/config/home_prefs.dart';
import '../../utils/home_typography.dart';

class ScreenHeader extends StatelessWidget {
  const ScreenHeader({
    super.key,
    required this.p,
    required this.subtitle,
    required this.title,
    this.trailing,
    this.center = false,
  });

  final Palette p;
  final String subtitle;
  final String title;
  final Widget? trailing;
  final bool center;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Column(
      crossAxisAlignment: center
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Text(
          subtitle.toUpperCase(),
          style: monoStyle(11, p.sub, w: FontWeight.w600, ls: 3),
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            Expanded(
              child: Text(
                title.toUpperCase(),
                textAlign: center ? TextAlign.center : null,
                style: uiStyle(42, p.ink, w: FontWeight.w900, ls: 2),
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ],
    ),
  );
}
