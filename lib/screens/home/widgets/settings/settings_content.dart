import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:spr0ut/spr0ut.dart';
import '../../../../config/home_prefs.dart';
import 'package:gr0ve/config/home_prefs.dart';
import '../../changelog.dart';
import '../../utils/home_helpers.dart';
import '../../utils/home_typography.dart';
import '../animations/appear_animation.dart';
import '../common/hover_detector.dart';
import '../common/panel_card.dart';
import 'package:gr0ve/config/theme.dart';

class SettingsContent extends StatelessWidget {
  const SettingsContent({
    super.key,
    required this.p,
    required this.user,
    required this.name,
    required this.prefs,
    required this.onSetAccent,
    required this.onSetDark,
    required this.onReload,
    required this.onSignOut,
    this.isDrawer = false,
  });

  final Palette p;
  final Spr0utUser? user;
  final String name;
  final HomePrefs prefs;
  final ValueChanged<Spr0utTheme> onSetAccent;
  final ValueChanged<bool> onSetDark;
  final VoidCallback onReload;
  final VoidCallback onSignOut;
  final bool isDrawer;

  @override
  Widget build(BuildContext context) {
    if (isDrawer) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppearAnimation(
            index: 0,
            step: 50,
            child: Row(
              children: [
                Text(
                  'Settings',
                  style: uiStyle(20, p.text, w: FontWeight.w800),
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Close',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(LucideIcons.x, size: 24, color: p.text),
                  style: IconButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    hoverColor: p.surface,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppearAnimation(
            index: 1,
            step: 50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: sansStyle(16, p.text, w: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(user?.email ?? '', style: sansStyle(13, p.sub)),
              ],
            ),
          ),
          const SizedBox(height: 32),
          AppearAnimation(
            index: 2,
            step: 50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                sectionLabel(p, 'Theme'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final e in HomePrefs.accents.entries)
                      _swatch(p, e.key, e.value),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          AppearAnimation(
            index: 3,
            step: 50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                sectionLabel(p, 'Appearance'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _seg(p, 'Light', !prefs.dark, () => onSetDark(false)),
                    const SizedBox(width: 8),
                    _seg(p, 'Dark', prefs.dark, () => onSetDark(true)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          AppearAnimation(
            index: 4,
            step: 50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                sectionLabel(p, 'Install as an app'),
                const SizedBox(height: 12),
                _how(
                  p,
                  'iPhone / iPad (Safari)',
                  'Tap Share, then Add to Home Screen.',
                ),
                _how(
                  p,
                  'Android (Chrome)',
                  'Open the menu, then tap Install app.',
                ),
                _how(
                  p,
                  'Desktop (Chrome / Edge)',
                  'Click the install icon at the right of the address bar.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          AppearAnimation(
            index: 5,
            step: 50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _btn(
                  p,
                  'Changelog',
                  LucideIcons.fileText,
                  () => showChangelogDialog(context, p),
                ),
                const SizedBox(height: 12),
                _btn(p, 'Refresh data', LucideIcons.refreshCw, onReload),
                const SizedBox(height: 12),
                _btn(p, 'Sign out', LucideIcons.logOut, onSignOut),
              ],
            ),
          ),
        ],
      );
    }

    Widget a(int i, Widget c) => AppearAnimation(index: i, step: 50, child: c);
    const gap = SizedBox(height: 14);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        a(
          0,
          _group(
            p,
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: p.accent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    name.isEmpty ? '?' : name.substring(0, 1).toUpperCase(),
                    style: uiStyle(22, p.onAccent, w: FontWeight.w800),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: sansStyle(18, p.text, w: FontWeight.w700),
                      ),
                      if ((user?.email ?? '').isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          user?.email ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: sansStyle(13, p.sub),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        gap,
        a(
          1,
          _group(
            p,
            label: 'Theme',
            trailing: Text(prefs.accent.name, style: sansStyle(12, p.sub)),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              spacing: 6,
              runSpacing: 10,
              children: [
                for (final e in HomePrefs.accents.entries)
                  _swatch(p, e.key, e.value),
              ],
            ),
          ),
        ),
        gap,
        a(
          2,
          _group(
            p,
            label: 'Appearance',
            child: Row(
              children: [
                _seg(p, 'Light', !prefs.dark, () => onSetDark(false)),
                const SizedBox(width: 10),
                _seg(p, 'Dark', prefs.dark, () => onSetDark(true)),
              ],
            ),
          ),
        ),
        gap,
        a(
          3,
          _group(
            p,
            label: 'Install as an app',
            child: Column(
              children: [
                _howRow(
                  p,
                  LucideIcons.tablet,
                  'iPhone / iPad (Safari)',
                  'Tap Share, then Add to Home Screen.',
                ),
                _howRow(
                  p,
                  LucideIcons.smartphone,
                  'Android (Chrome)',
                  'Open the menu, then tap Install app.',
                ),
                _howRow(
                  p,
                  LucideIcons.monitor,
                  'Desktop (Chrome / Edge)',
                  'Click the install icon at the right of the address bar.',
                  last: true,
                ),
              ],
            ),
          ),
        ),
        gap,
        a(
          4,
          Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: p.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: softColor(p)),
            ),
            child: Column(
              children: [
                _settingsRow(
                  p,
                  LucideIcons.fileText,
                  'Changelog',
                  () => showChangelogDialog(context, p),
                ),
                _settingsRow(
                  p,
                  LucideIcons.refreshCw,
                  'Refresh data',
                  onReload,
                ),
                _settingsRow(
                  p,
                  LucideIcons.logOut,
                  'Sign out',
                  onSignOut,
                  danger: true,
                  last: true,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _group(
    Palette p, {
    String? label,
    Widget? trailing,
    required Widget child,
  }) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: p.surface,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: softColor(p)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (label != null) ...[
          Row(
            children: [
              sectionLabel(p, label),
              const Spacer(),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 14),
        ],
        child,
      ],
    ),
  );

  Widget _howRow(
    Palette p,
    IconData icon,
    String title,
    String body, {
    bool last = false,
  }) => Padding(
    padding: EdgeInsets.only(bottom: last ? 0 : 16),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: p.sub),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: sansStyle(14, p.text, w: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(body, style: sansStyle(13, p.sub)),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _settingsRow(
    Palette p,
    IconData icon,
    String label,
    VoidCallback f, {
    bool danger = false,
    bool last = false,
  }) {
    final c = danger ? Gr0veColors.error : p.text;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        HoverDetector(
          onTap: f,
          pressAsHover: true,
          builder: (h) => AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            color: h ? p.tint : Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
            child: Row(
              children: [
                Icon(icon, size: 20, color: danger ? c : p.sub),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style: sansStyle(15, c, w: FontWeight.w600),
                  ),
                ),
                if (!danger)
                  AnimatedSlide(
                    duration: const Duration(milliseconds: 140),
                    curve: Curves.easeOut,
                    offset: h ? const Offset(0.3, 0) : Offset.zero,
                    child: Icon(
                      LucideIcons.chevronRight,
                      size: 18,
                      color: p.sub,
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (!last) Divider(height: 1, thickness: 1, color: softColor(p)),
      ],
    );
  }

  Widget _how(Palette p, String title, String body) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: sansStyle(13, p.text, w: FontWeight.w600)),
        const SizedBox(height: 2),
        Text(body, style: sansStyle(13, p.sub)),
      ],
    ),
  );

  Widget _swatch(Palette p, Spr0utTheme t, Color c) {
    final sel = prefs.accent == t;
    return Tooltip(
      message: t.name,
      child: HoverDetector(
        onTap: () => onSetAccent(t),
        builder: (h) => AnimatedScale(
          scale: h && !sel ? 1.1 : 1,
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            width: 38,
            height: 38,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(11),
              border: Border.all(
                width: 2,
                color: sel ? p.text : (h ? p.line : Colors.transparent),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: ColoredBox(color: c),
            ),
          ),
        ),
      ),
    );
  }

  Widget _seg(Palette p, String label, bool on, VoidCallback f) => Expanded(
    child: HoverDetector(
      onTap: f,
      builder: (h) => AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: on ? p.text : (h ? p.surface : Colors.transparent),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: on ? p.text : edgeColor(p, !isDrawer),
            width: borderWidth(!isDrawer),
          ),
        ),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 160),
          style: sansStyle(13, on ? p.bg : p.text, w: FontWeight.w600),
          child: Text(label),
        ),
      ),
    ),
  );

  Widget _btn(Palette p, String label, IconData icon, VoidCallback f) =>
      OutlinedButton.icon(
        onPressed: f,
        icon: Icon(icon, size: 16),
        label: Text(
          label.toUpperCase(),
          style: sansStyle(13, p.text, w: FontWeight.w700, ls: 0.5),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: p.text,
          side: BorderSide(
            color: edgeColor(p, !isDrawer),
            width: borderWidth(!isDrawer),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          minimumSize: const Size.fromHeight(52),
        ).copyWith(overlayColor: WidgetStatePropertyAll(p.surface)),
      );
}
