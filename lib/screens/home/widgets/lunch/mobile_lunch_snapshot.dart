import 'package:f0rest/f0rest.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:gr0ve/config/home_prefs.dart';
import '../../utils/home_typography.dart';
import '../common/panel_card.dart';
import '../common/skeleton_views.dart';
import '../navigation/mobile_tab_link.dart';

class MobileLunchSnapshot extends StatelessWidget {
  const MobileLunchSnapshot({
    super.key,
    required this.p,
    required this.lunchFuture,
    required this.onSwitchToTab,
  });

  final Palette p;
  final Future<List<LunchEntry>> lunchFuture;
  final ValueChanged<int> onSwitchToTab;

  @override
  Widget build(BuildContext context) => panelCard(
    p,
    'Lunch',
    HugeIcons.strokeRoundedUtensils,
    FutureBuilder<List<LunchEntry>>(
      future: lunchFuture,
      builder: (_, s) {
        if (!s.hasData) return lunchSkeleton(p);
        final entries = s.data!;
        if (entries.isEmpty) return emptyStateView(p, 'No menu today.');
        final sample = entries.take(3).toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final e in sample)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Text('• ${e.food.name}', style: sansStyle(14, p.text)),
              ),
          ],
        );
      },
    ),
    trailing: MobileTabLink(p: p, label: 'Menu', onTap: () => onSwitchToTab(4)),
    enter: 4,
    mobile: true,
  );
}
