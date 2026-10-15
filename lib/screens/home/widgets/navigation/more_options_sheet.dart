import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:gr0ve/config/home_prefs.dart';
import '../../utils/home_helpers.dart';
import '../../utils/home_typography.dart';
import '../common/hover_detector.dart';

class MoreOptionsSheet extends StatelessWidget {
  const MoreOptionsSheet({
    super.key,
    required this.p,
    required this.currentTab,
    required this.onSelectTab,
  });

  final Palette p;
  final int currentTab;
  final ValueChanged<int> onSelectTab;

  static void show(
    BuildContext context, {
    required Palette p,
    required int currentTab,
    required ValueChanged<int> onSelectTab,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => MoreOptionsSheet(
        p: p,
        currentTab: currentTab,
        onSelectTab: onSelectTab,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: p.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      border: Border.all(color: edgeColor(p, true), width: borderWidth(true)),
    ),
    padding: const EdgeInsets.fromLTRB(20, 14, 20, 36),
    child: SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: p.line,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 26),
          Center(
            child: Text(
              'MORE',
              style: uiStyle(26, p.ink, w: FontWeight.w900, ls: 3),
            ),
          ),
          const SizedBox(height: 22),
          _moreMenuItem(
            p,
            icon: HugeIcons.strokeRoundedRestaurant01,
            title: 'Lunch Menu',
            isSelected: currentTab == 4,
            onTap: () {
              Navigator.pop(context);
              onSelectTab(4);
            },
          ),
          _moreMenuItem(
            p,
            icon: HugeIcons.strokeRoundedSettings01,
            title: 'Settings',
            isSelected: currentTab == 5,
            onTap: () {
              Navigator.pop(context);
              onSelectTab(5);
            },
          ),
        ],
      ),
    ),
  );

  Widget _moreMenuItem(
    Palette p, {
    required dynamic icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) => HoverDetector(
    onTap: onTap,
    pressAsHover: true,
    builder: (h) {
      final on = isSelected || h;
      const d = Duration(milliseconds: 160);
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
        child: Row(
          children: [
            _tweenIcon(icon, 26, on ? p.accent : p.sub),
            const SizedBox(width: 20),
            Expanded(
              child: AnimatedDefaultTextStyle(
                duration: d,
                style: sansStyle(
                  17,
                  on ? p.accent : p.text,
                  w: FontWeight.w600,
                ),
                child: Text(title),
              ),
            ),
            const SizedBox(width: 12),
            AnimatedSlide(
              duration: d,
              curve: Curves.easeOut,
              offset: h ? const Offset(0.3, 0) : Offset.zero,
              child: _tweenIcon(
                HugeIcons.strokeRoundedArrowRight01,
                20,
                h ? p.accent : p.sub,
              ),
            ),
          ],
        ),
      );
    },
  );

  Widget _tweenIcon(dynamic icon, double size, Color color) =>
      TweenAnimationBuilder<Color?>(
        tween: ColorTween(end: color),
        duration: const Duration(milliseconds: 180),
        builder: (_, c, __) =>
            HugeIcon(icon: icon, size: size, color: c ?? color),
      );
}
