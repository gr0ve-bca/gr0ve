import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:spr0ut/spr0ut.dart';
import '../../../../config/home_prefs.dart';
import '../animations/motion_utils.dart';
import 'settings_content.dart';

class SettingsDrawer extends StatelessWidget {
  const SettingsDrawer({
    super.key,
    required this.p,
    required this.user,
    required this.name,
    required this.sideUrl,
    required this.slug,
    required this.prefs,
    required this.onSetAccent,
    required this.onSetDark,
    required this.onReload,
    required this.onSignOut,
  });

  final Palette p;
  final Spr0utUser? user;
  final String name;
  final String sideUrl;
  final String slug;
  final HomePrefs prefs;
  final ValueChanged<Spr0utTheme> onSetAccent;
  final ValueChanged<bool> onSetDark;
  final VoidCallback onReload;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final dw = math.min(380.0, MediaQuery.sizeOf(context).width * 0.92);
    return Drawer(
      width: dw,
      elevation: 0,
      backgroundColor: p.bg,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(),
      child: Stack(
        children: [
          Positioned(
            right: 0,
            bottom: 0,
            child: IgnorePointer(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                layoutBuilder: (cur, prev) => Stack(
                  alignment: Alignment.bottomRight,
                  children: [...prev, if (cur != null) cur],
                ),
                transitionBuilder: morphTransition(Alignment.bottomRight),
                child: SvgPicture.network(
                  sideUrl,
                  key: ValueKey(slug),
                  width: math.min(200.0, dw * 0.52),
                  fit: BoxFit.contain,
                  alignment: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(32, 28, 32, 32),
              child: SettingsContent(
                p: p,
                user: user,
                name: name,
                prefs: prefs,
                onSetAccent: onSetAccent,
                onSetDark: onSetDark,
                onReload: onReload,
                onSignOut: onSignOut,
                isDrawer: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
