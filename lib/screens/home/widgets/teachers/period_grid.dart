import 'package:flutter/material.dart';
import 'package:gr0ve/config/home_prefs.dart';
import 'package:gr0ve/config/theme.dart';
import '../../utils/home_helpers.dart';
import '../../utils/home_typography.dart';

class PeriodGrid extends StatelessWidget {
  const PeriodGrid({super.key, required this.p, required this.status});

  final Palette p;
  final String status;

  @override
  Widget build(BuildContext context) {
    const w = 5 * 26.0 + 4 * 4.0;
    final out = parseOutPeriods(status);
    if (out == null) {
      return Container(
        width: w,
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Gr0veColors.error,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text('All Day', style: uiStyle(12, Colors.white)),
      );
    }
    if (out.isEmpty) {
      return Container(
        width: w,
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Gr0veColors.success,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text('Present', style: uiStyle(12, Colors.white)),
      );
    }
    Widget cell(String s) => Container(
      width: 26,
      height: 22,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: out.contains(s) ? Gr0veColors.error : p.surface,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        s,
        style: uiStyle(
          s == 'IGS' ? 8 : 10,
          out.contains(s) ? Colors.white : p.sub,
        ),
      ),
    );
    Widget row(List<String> r) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < r.length; i++) ...[
          if (i > 0) const SizedBox(width: 4),
          cell(r[i]),
        ],
      ],
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        row(periodSlots.sublist(0, 5)),
        const SizedBox(height: 4),
        row(periodSlots.sublist(5)),
      ],
    );
  }
}
