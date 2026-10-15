import 'package:f0rest/f0rest.dart';
import 'package:flutter/material.dart';
import 'package:gr0ve/config/home_prefs.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../config/teacher_stars.dart';
import '../../utils/home_typography.dart';
import '../common/panel_card.dart';
import '../common/skeleton_views.dart';
import '../navigation/mobile_tab_link.dart';
import 'teacher_tile.dart';

class MobileStarredTeachers extends StatelessWidget {
  const MobileStarredTeachers({
    super.key,
    required this.p,
    required this.absencesFuture,
    required this.stars,
    required this.onSwitchToTab,
  });

  final Palette p;
  final Future<List<Absence>> absencesFuture;
  final TeacherStars stars;
  final ValueChanged<int> onSwitchToTab;

  @override
  Widget build(BuildContext context) => FutureBuilder<List<Absence>>(
    future: absencesFuture,
    builder: (context, s) {
      final all = s.data ?? const <Absence>[];
      final starred = all.where((a) => stars.has(a.name)).toList();
      if (starred.isEmpty && s.hasData) {
        return panelCard(
          p,
          'Starred teachers',
          LucideIcons.star,
          Text(
            'Star teachers in the Teachers tab to view them here.',
            style: sansStyle(14, p.sub),
          ),
          trailing: MobileTabLink(
            p: p,
            label: 'All',
            onTap: () => onSwitchToTab(1),
          ),
          enter: 1,
          mobile: true,
        );
      }
      return panelCard(
        p,
        'Starred teachers',
        LucideIcons.star,
        s.hasData
            ? Column(
                children: [
                  for (var i = 0; i < starred.length; i++)
                    TeacherTile(
                      p: p,
                      absence: starred[i],
                      isStarred: stars.has(starred[i].name),
                      onToggleStar: () => stars.toggle(starred[i].name),
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
          onTap: () => onSwitchToTab(1),
        ),
        enter: 1,
        mobile: true,
      );
    },
  );
}
