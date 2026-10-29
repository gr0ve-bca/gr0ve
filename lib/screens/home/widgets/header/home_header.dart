import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gr0ve/config/home_prefs.dart';
import '../../utils/home_helpers.dart';
import '../../utils/home_typography.dart';
import '../animations/motion_utils.dart';
import '../animations/pulse_placeholder.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.p,
    required this.firstName,
    required this.wide,
    required this.short,
    required this.slug,
    required this.dark,
    this.onOpenSettings,
  });

  final Palette p;
  final String firstName;
  final bool wide;
  final bool short;
  final String slug;
  final bool dark;
  final VoidCallback? onOpenSettings;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      if (wide) ...[
        Row(
          children: [
            SizedBox(
              height: headerLogoHeight,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                layoutBuilder: (cur, prev) => Stack(
                  alignment: Alignment.centerLeft,
                  children: [...prev, if (cur != null) cur],
                ),
                transitionBuilder: morphTransition(Alignment.centerLeft),
                child: SvgPicture.network(
                  '$arb0rBaseUrl/$slug/${dark ? 'dark' : 'light'}/$slug.svg',
                  key: ValueKey('$slug-$dark'),
                  height: headerLogoHeight,
                  placeholderBuilder: (_) => PulsePlaceholder(
                    width: 18,
                    height: headerLogoHeight,
                    radius: 6,
                    color: p.line,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'GR0VE',
              style: monoStyle(16, p.ink, w: FontWeight.w800, ls: 3),
            ),
            const Spacer(),
            if (onOpenSettings != null)
              IconButton(
                tooltip: 'Settings',
                onPressed: onOpenSettings,
                icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedSettings01,
                  size: 18,
                  color: p.text,
                ),
                style: IconButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  hoverColor: p.surface,
                  padding: const EdgeInsets.all(12),
                ),
              ),
          ],
        ),
        SizedBox(height: short ? 0 : 8),
      ],
      Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              getGreeting().toUpperCase(),
              style: uiStyle(12, p.sub, w: FontWeight.w600, ls: 4),
            ),
            SizedBox(height: short ? 4 : 10),
            Text(
              firstName.toUpperCase(),
              textAlign: TextAlign.center,
              style: uiStyle(
                short ? 30 : (wide ? 44 : 36),
                p.ink,
                w: FontWeight.w800,
                ls: 3,
              ),
            ),
          ],
        ),
      ),
      SizedBox(height: short ? 6 : 14),
      Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: p.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: edgeColor(p, !wide),
              width: borderWidth(!wide),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final (label, icon, url) in quickLinksList)
                Tooltip(
                  message: label,
                  child: IconButton(
                    onPressed: () => launchUrl(Uri.parse(url)),
                    icon: HugeIcon(icon: icon, size: 22, color: p.text),
                    style: IconButton.styleFrom(
                      hoverColor: p.tint,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    ],
  );
}
