import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:gr0ve/config/home_prefs.dart';
import '../../utils/home_helpers.dart';
import '../common/press_detector.dart';
import 'more_options_sheet.dart';

class FloatingNavBar extends StatelessWidget {
  const FloatingNavBar({
    super.key,
    required this.p,
    required this.currentTab,
    required this.onSelectTab,
  });

  final Palette p;
  final int currentTab;
  final ValueChanged<int> onSelectTab;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
    decoration: BoxDecoration(
      color: p.surface,
      borderRadius: BorderRadius.circular(36),
      border: Border.all(color: edgeColor(p, true), width: borderWidth(true)),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _navItem(p, 0, HugeIcons.strokeRoundedHome01, 'Home'),
        _navItem(p, 1, HugeIcons.strokeRoundedUserRemove01, 'Teachers'),
        _navItem(p, 2, HugeIcons.strokeRoundedBus01, 'Buses'),
        _navItem(p, 3, HugeIcons.strokeRoundedCalendar01, 'Events'),
        _moreNavItem(context, p),
      ],
    ),
  );

  Widget _navItem(Palette p, int index, dynamic icon, String tooltip) =>
      _navButton(
        p,
        active: currentTab == index,
        icon: icon,
        tooltip: tooltip,
        onTap: () => onSelectTab(index),
      );

  Widget _moreNavItem(BuildContext context, Palette p) => _navButton(
    p,
    active: currentTab == 4 || currentTab == 5,
    icon: HugeIcons.strokeRoundedMoreHorizontal,
    tooltip: 'More',
    onTap: () => MoreOptionsSheet.show(
      context,
      p: p,
      currentTab: currentTab,
      onSelectTab: onSelectTab,
    ),
  );

  Widget _navButton(
    Palette p, {
    required bool active,
    required dynamic icon,
    required String tooltip,
    required VoidCallback onTap,
  }) => PressDetector(
    onTap: onTap,
    builder: (down) => Tooltip(
      message: tooltip,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        child: AnimatedScale(
          scale: down ? 0.86 : (active ? 1.12 : 1.0),
          duration: Duration(milliseconds: down ? 90 : 200),
          curve: down ? Curves.easeOut : Curves.easeOutBack,
          child: _tweenIcon(icon, 24, active ? p.ink : p.sub),
        ),
      ),
    ),
  );

  Widget _tweenIcon(dynamic icon, double size, Color color) =>
      TweenAnimationBuilder<Color?>(
        tween: ColorTween(end: color),
        duration: const Duration(milliseconds: 180),
        builder: (_, c, __) =>
            HugeIcon(icon: icon, size: size, color: c ?? color),
      );
}
