import 'package:f0rest/f0rest.dart';
import 'package:flutter/material.dart';
import 'package:gr0ve/config/home_prefs.dart';
import '../../utils/home_typography.dart';
import '../common/panel_card.dart';
import '../common/star_button.dart';
import 'period_grid.dart';

class TeacherTile extends StatelessWidget {
  const TeacherTile({
    super.key,
    required this.p,
    required this.absence,
    required this.isStarred,
    required this.onToggleStar,
    required this.index,
    required this.mobile,
    required this.flat,
  });

  final Palette p;
  final Absence absence;
  final bool isStarred;
  final VoidCallback onToggleStar;
  final int index;
  final bool mobile;
  final bool flat;

  @override
  Widget build(BuildContext context) {
    String title;
    if (absence.matched) {
      final lastName = absence.name.split(',').first.trim();
      final prefix = absence.prefix.trim();
      title = prefix.toLowerCase() == 'lao shi'
          ? '$lastName $prefix'
          : '$prefix. $lastName';
    } else {
      title = absence.name;
    }
    final star = StarButton(
      on: isStarred,
      idle: p.sub,
      hover: Color.lerp(p.bg, p.sub, 0.55)!,
      pressed: p.ink,
      onTap: onToggleStar,
    );
    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: sansStyle(14, p.text, w: FontWeight.w600),
        ),
        const SizedBox(height: 2),
        Text(
          absence.matched ? absence.department : 'Not in roster',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: sansStyle(13, p.sub),
        ),
      ],
    );
    return tileWrapper(
      p,
      LayoutBuilder(
        builder: (context, c) {
          final stack = c.maxWidth < 34 + 14 + 110 + 16 + 146;
          if (stack) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    star,
                    const SizedBox(width: 14),
                    Expanded(child: text),
                  ],
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: PeriodGrid(p: p, status: absence.status),
                ),
              ],
            );
          }
          return Row(
            children: [
              star,
              const SizedBox(width: 14),
              Expanded(child: text),
              const SizedBox(width: 16),
              PeriodGrid(p: p, status: absence.status),
            ],
          );
        },
      ),
      i: index,
      mobile: mobile,
      flat: flat,
    );
  }
}
