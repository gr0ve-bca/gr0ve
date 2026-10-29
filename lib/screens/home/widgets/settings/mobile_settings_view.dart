import 'package:flutter/material.dart';
import 'package:spr0ut/spr0ut.dart';
import '../../../../config/home_prefs.dart';
import '../../utils/home_helpers.dart';
import '../navigation/screen_header.dart';
import 'settings_content.dart';

class MobileSettingsView extends StatelessWidget {
  const MobileSettingsView({
    super.key,
    required this.p,
    required this.pad,
    required this.user,
    required this.name,
    required this.prefs,
    required this.onSetAccent,
    required this.onSetDark,
    required this.onReload,
    required this.onSignOut,
  });

  final Palette p;
  final double pad;
  final Spr0utUser? user;
  final String name;
  final HomePrefs prefs;
  final ValueChanged<Spr0utTheme> onSetAccent;
  final ValueChanged<bool> onSetDark;
  final VoidCallback onReload;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(pad + 8, 28, pad + 8, 0),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ScreenHeader(
              p: p,
              subtitle: 'MAKE IT YOURS',
              title: 'SETTINGS',
              center: true,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: mobileNavClear),
                child: SettingsContent(
                  p: p,
                  user: user,
                  name: name,
                  prefs: prefs,
                  onSetAccent: onSetAccent,
                  onSetDark: onSetDark,
                  onReload: onReload,
                  onSignOut: onSignOut,
                  isDrawer: false,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
