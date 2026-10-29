import 'package:f0rest/f0rest.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../config/bus_stars.dart';
import 'package:gr0ve/config/home_prefs.dart';
import '../../utils/home_helpers.dart';
import '../../utils/home_typography.dart';
import '../common/panel_card.dart';
import '../common/skeleton_views.dart';
import '../navigation/mobile_tab_link.dart';
import 'bus_tile.dart';

class MobileStarredBuses extends StatelessWidget {
  const MobileStarredBuses({
    super.key,
    required this.p,
    required this.busesFuture,
    required this.stars,
    required this.onSwitchToTab,
  });

  final Palette p;
  final Future<List<BusSpot>> busesFuture;
  final BusStars stars;
  final ValueChanged<int> onSwitchToTab;

  @override
  Widget build(BuildContext context) => FutureBuilder<List<BusSpot>>(
    future: busesFuture,
    builder: (context, s) {
      final data = s.data ?? const <BusSpot>[];
      final starred =
          data.where((b) => stars.has(cleanBusLabel(b.label))).toList()..sort(
            (a, b) => cleanBusLabel(a.label).compareTo(cleanBusLabel(b.label)),
          );
      if (starred.isEmpty && s.hasData) {
        return panelCard(
          p,
          'Starred buses',
          HugeIcons.strokeRoundedStar,
          Text(
            'Star buses in the Buses tab to track arrival spots.',
            style: sansStyle(14, p.sub),
          ),
          trailing: MobileTabLink(
            p: p,
            label: 'All',
            onTap: () => onSwitchToTab(2),
          ),
          enter: 2,
          mobile: true,
        );
      }
      return panelCard(
        p,
        'Starred buses',
        HugeIcons.strokeRoundedStar,
        s.hasData
            ? Column(
                children: [
                  for (var i = 0; i < starred.length; i++)
                    BusTile(
                      p: p,
                      spot: starred[i],
                      isMine: true,
                      onToggleStar: () =>
                          stars.toggle(cleanBusLabel(starred[i].label)),
                      index: i,
                      mobile: true,
                      flat: false,
                    ),
                ],
              )
            : loadingListSkeleton(p, rows: 2),
        trailing: MobileTabLink(
          p: p,
          label: 'All',
          onTap: () => onSwitchToTab(2),
        ),
        enter: 2,
        mobile: true,
      );
    },
  );
}
