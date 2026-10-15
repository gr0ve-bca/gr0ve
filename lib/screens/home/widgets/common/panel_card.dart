import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:gr0ve/config/home_prefs.dart';
import '../../utils/home_helpers.dart';
import '../../utils/home_typography.dart';
import '../animations/appear_animation.dart';
import '../animations/motion_utils.dart';

Widget panelCard(
  Palette p,
  String title,
  IconData icon,
  Widget body, {
  Widget? trailing,
  bool fill = false,
  int enter = 0,
  required bool mobile,
}) {
  if (!(mobile && fill)) {
    return panelBoxContainer(
      p,
      title,
      icon,
      body,
      trailing: trailing,
      fill: fill,
      enter: enter,
      mobile: mobile,
    );
  }
  return AppearAnimation(
    index: enter,
    step: 90,
    dy: 0.04,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (trailing != null) ...[
          Center(child: trailing),
          const SizedBox(height: 14),
        ],
        Expanded(child: body),
      ],
    ),
  );
}

Widget panelBoxContainer(
  Palette p,
  String title,
  IconData icon,
  Widget body, {
  Widget? trailing,
  bool fill = false,
  int enter = 0,
  required bool mobile,
}) => AppearAnimation(
  index: enter,
  step: 90,
  dy: 0.04,
  child: LayoutBuilder(
    builder: (context, c) {
      final narrow = c.maxWidth < 340;
      return Container(
        padding: EdgeInsets.all(narrow ? 16 : 24),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(mobile ? 12 : 20),
          border: Border.all(
            color: edgeColor(p, mobile),
            width: borderWidth(mobile),
          ),
        ),
        child: Column(
          mainAxisSize: fill ? MainAxisSize.max : MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                if (!narrow) ...[
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: p.tint,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, size: 22, color: p.ink),
                  ),
                  const SizedBox(width: 14),
                ],
                Expanded(
                  child: Text(
                    title.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: uiStyle(12, p.text, ls: 1.5),
                  ),
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutCubic,
                  alignment: Alignment.centerRight,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 260),
                    transitionBuilder: popInTransition,
                    child: trailing == null
                        ? const SizedBox.shrink(key: ValueKey('none'))
                        : Padding(
                            key: const ValueKey('chip'),
                            padding: const EdgeInsets.only(left: 8),
                            child: trailing,
                          ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (fill) Expanded(child: body) else body,
          ],
        ),
      );
    },
  ),
);

Widget countChip(Palette p, String t) => AnimatedSwitcher(
  duration: const Duration(milliseconds: 240),
  transitionBuilder: popInTransition,
  child: Container(
    key: ValueKey(t),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: p.tint,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(t, style: uiStyle(11, p.ink)),
  ),
);

Widget tileWrapper(
  Palette p,
  Widget child, {
  bool hl = false,
  int? i,
  required bool mobile,
  required bool flat,
}) {
  final t = AnimatedContainer(
    duration: const Duration(milliseconds: 160),
    margin: const EdgeInsets.only(bottom: 10),
    padding: EdgeInsets.symmetric(horizontal: 18, vertical: mobile ? 16 : 14),
    decoration: BoxDecoration(
      color: flat ? p.surface : p.bg,
      borderRadius: BorderRadius.circular(mobile ? 12 : 14),
      border: Border.all(
        color: hl ? p.accent : edgeColor(p, mobile),
        width: hl ? 1.5 : borderWidth(mobile),
      ),
    ),
    child: child,
  );
  return i == null ? t : AppearAnimation(index: i, child: t);
}

Widget searchField(
  Palette p,
  String hint,
  ValueChanged<String> onChanged, {
  required bool mobile,
}) {
  if (mobile) return softSearchField(p, hint, onChanged);
  OutlineInputBorder b(Color c, double w) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: BorderSide(color: c, width: w),
  );
  return TextField(
    onChanged: onChanged,
    cursorColor: p.accent,
    style: sansStyle(14, p.text),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: sansStyle(14, p.sub),
      prefixIcon: Icon(LucideIcons.search, size: 16, color: p.sub),
      filled: true,
      fillColor: p.bg,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: b(p.line, 1.5),
      enabledBorder: b(p.line, 1.5),
      focusedBorder: b(p.accent, 2),
    ),
  );
}

Widget softSearchField(Palette p, String hint, ValueChanged<String> onChanged) {
  OutlineInputBorder b(Color c) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: c),
  );
  return TextField(
    onChanged: onChanged,
    cursorColor: p.accent,
    style: sansStyle(14, p.text),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: sansStyle(14, p.sub),
      prefixIcon: Icon(LucideIcons.search, size: 16, color: p.sub),
      filled: true,
      fillColor: p.surface,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: b(softColor(p)),
      enabledBorder: b(softColor(p)),
      focusedBorder: b(p.accent),
    ),
  );
}

Widget sectionLabel(Palette p, String t) => Text(
  t.toUpperCase(),
  style: sansStyle(11, p.sub, w: FontWeight.w700, ls: 1.4),
);

Widget topAlign(Widget w) => Align(alignment: Alignment.topLeft, child: w);

Widget swapTransition(String k, Widget child) => AnimatedSwitcher(
  duration: const Duration(milliseconds: 320),
  switchInCurve: Curves.easeOutCubic,
  switchOutCurve: Curves.easeIn,
  layoutBuilder: (cur, prev) => Stack(
    alignment: Alignment.topLeft,
    children: [...prev, if (cur != null) cur],
  ),
  transitionBuilder: (c, a) => FadeTransition(opacity: a, child: c),
  child: KeyedSubtree(key: ValueKey(k), child: child),
);

Widget errorStateView(Palette p, VoidCallback onRetry) => topAlign(
  Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text('Could not load.', style: sansStyle(14, p.sub)),
      const SizedBox(width: 8),
      TextButton(
        onPressed: onRetry,
        child: Text('Retry', style: sansStyle(14, p.text, w: FontWeight.w600)),
      ),
    ],
  ),
);

Widget emptyStateView(Palette p, String t) =>
    topAlign(Text(t, style: sansStyle(14, p.sub)));

Widget softBox(Palette p, Widget child) => Container(
  padding: const EdgeInsets.all(14),
  decoration: BoxDecoration(
    color: p.surface,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: softColor(p)),
  ),
  child: child,
);
