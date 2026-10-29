import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:gr0ve/config/home_prefs.dart';
import '../../utils/home_helpers.dart';
import '../../utils/home_typography.dart';
import 'day_cell.dart';

class MonthGrid extends StatelessWidget {
  const MonthGrid({
    super.key,
    required this.p,
    required this.month,
    required this.selectedDate,
    required this.dots,
    required this.rowHeight,
    required this.onSelectDate,
    required this.onShiftMonth,
  });

  final Palette p;
  final DateTime month;
  final DateTime selectedDate;
  final Set<int> dots;
  final double? rowHeight;
  final ValueChanged<DateTime> onSelectDate;
  final ValueChanged<int> onShiftMonth;

  @override
  Widget build(BuildContext context) {
    final days = DateTime(month.year, month.month + 1, 0).day;
    final lead = month.weekday % 7;
    final today = DateTime.now();
    final weeks = ((lead + days) / 7).ceil();

    Widget week(int w) {
      final row = Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < 7; i++)
            Expanded(
              child: () {
                final n = w * 7 + i - lead + 1;
                if (n < 1 || n > days) return const SizedBox.shrink();
                final date = DateTime(month.year, month.month, n);
                return DayCell(
                  p: p,
                  date: date,
                  isSel: isSameDay(date, selectedDate),
                  isToday: isSameDay(date, today),
                  hasDot: dots.contains(n),
                  onTap: () => onSelectDate(date),
                );
              }(),
            ),
        ],
      );
      return rowHeight == null
          ? Expanded(child: row)
          : SizedBox(height: rowHeight, child: row);
    }

    return Column(
      mainAxisSize: rowHeight == null ? MainAxisSize.max : MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            _navBtn(
              p,
              HugeIcons.strokeRoundedChevronLeft,
              'Previous month',
              () => onShiftMonth(-1),
            ),
            Expanded(
              child: Center(
                child: Text(
                  '${monthNamesList[month.month - 1]} ${month.year}',
                  style: uiStyle(15, p.text),
                ),
              ),
            ),
            _navBtn(
              p,
              HugeIcons.strokeRoundedChevronRight,
              'Next month',
              () => onShiftMonth(1),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            for (final w in weekdaysList)
              Expanded(
                child: Center(
                  child: Text(
                    w,
                    style: sansStyle(11, p.sub, w: FontWeight.w700),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        for (var w = 0; w < weeks; w++) week(w),
      ],
    );
  }

  Widget _navBtn(
    Palette p,
    List<List<dynamic>> icon,
    String tip,
    VoidCallback f,
  ) => IconButton(
    tooltip: tip,
    onPressed: f,
    icon: HugeIcon(icon: icon, size: 16, color: p.text),
    style: IconButton.styleFrom(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      hoverColor: p.line,
    ),
  );
}
