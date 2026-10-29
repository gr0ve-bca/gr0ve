import 'package:f0rest/f0rest.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../config/teacher_stars.dart';
import 'package:gr0ve/config/home_prefs.dart';
import '../../utils/home_helpers.dart';
import '../common/panel_card.dart';
import '../common/skeleton_views.dart';
import 'teacher_tile.dart';

class TeachersCard extends StatefulWidget {
  const TeachersCard({
    super.key,
    required this.p,
    required this.absencesFuture,
    required this.stars,
    required this.fill,
    required this.mobile,
    required this.onRetry,
  });

  final Palette p;
  final Future<List<Absence>> absencesFuture;
  final TeacherStars stars;
  final bool fill;
  final bool mobile;
  final VoidCallback onRetry;

  @override
  State<TeachersCard> createState() => _TeachersCardState();
}

class _TeachersCardState extends State<TeachersCard> {
  String _tq = '';

  int _rank(Absence a) {
    final out = parseOrdinalPeriods(a.status) ?? parseOutPeriods(a.status);
    final present = out != null && out.isEmpty;
    final starred = widget.stars.has(a.name);
    return (starred ? 0 : 2) + (present ? 1 : 0);
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    return FutureBuilder<List<Absence>>(
      future: widget.absencesFuture,
      builder: (context, s) {
        final all = (s.data ?? const <Absence>[]).toList()
          ..sort((a, b) {
            final r = _rank(a) - _rank(b);
            return r != 0
                ? r
                : foldString(a.name).compareTo(foldString(b.name));
          });
        final q = _tq.toLowerCase().trim();
        final shown = q.isEmpty
            ? all
            : all
                  .where(
                    (a) =>
                        a.name.toLowerCase().contains(q) ||
                        (a.matched && a.department.toLowerCase().contains(q)),
                  )
                  .toList();

        final Widget raw;
        final String k;
        if (s.hasError) {
          if (kDebugMode) debugPrint('${s.error}');
          k = 'error';
          raw = errorStateView(p, widget.onRetry);
        } else if (!s.hasData) {
          k = 'loading';
          raw = loadingListSkeleton(p);
        } else if (all.isEmpty) {
          k = 'empty';
          raw = emptyStateView(p, 'Everyone is in today.');
        } else if (shown.isEmpty) {
          k = 'nomatch';
          raw = emptyStateView(p, 'No match.');
        } else {
          k = 'list';
          raw = ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: shown.length,
            itemBuilder: (_, i) => TeacherTile(
              p: p,
              absence: shown[i],
              isStarred: widget.stars.has(shown[i].name),
              onToggleStar: () => widget.stars.toggle(shown[i].name),
              index: i,
              mobile: widget.mobile,
              flat: false,
            ),
          );
        }
        final list = swapTransition(k, raw);

        return panelCard(
          p,
          'Teachers out',
          HugeIcons.strokeRoundedUser,
          Column(
            mainAxisSize: widget.fill ? MainAxisSize.max : MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              searchField(
                p,
                'Search teachers...',
                (v) => setState(() => _tq = v),
                mobile: widget.mobile,
              ),
              const SizedBox(height: 12),
              if (widget.fill)
                Expanded(child: list)
              else
                SizedBox(height: 460, child: list),
            ],
          ),
          trailing: s.hasData ? countChip(p, '${all.length}') : null,
          fill: widget.fill,
          enter: 1,
          mobile: widget.mobile,
        );
      },
    );
  }
}
