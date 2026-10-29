import 'package:f0rest/f0rest.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:gr0ve/config/home_prefs.dart';
import '../../utils/home_typography.dart';
import '../common/panel_card.dart';
import '../navigation/mobile_tab_link.dart';
import 'event_tile.dart';

class MobileTodayEvents extends StatelessWidget {
  const MobileTodayEvents({
    super.key,
    required this.p,
    required this.events,
    required this.onSwitchToTab,
  });

  final Palette p;
  final Events events;
  final ValueChanged<int> onSwitchToTab;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final ev = events.query(date: today);
    return panelCard(
      p,
      'Today',
      HugeIcons.strokeRoundedCalendar01,
      ev.isEmpty
          ? Text('Nothing scheduled today.', style: sansStyle(14, p.sub))
          : Column(
              children: [
                for (final e in ev) EventTile(p: p, event: e, mobile: true),
              ],
            ),
      trailing: MobileTabLink(
        p: p,
        label: 'Calendar',
        onTap: () => onSwitchToTab(3),
      ),
      enter: 3,
      mobile: true,
    );
  }
}
