import 'package:f0rest/f0rest.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:gr0ve/config/home_prefs.dart';
import '../../utils/home_helpers.dart';
import '../common/panel_card.dart';
import 'day_panel.dart';
import 'month_grid.dart';

class CalendarCard extends StatelessWidget {
  const CalendarCard({
    super.key,
    required this.p,
    required this.events,
    required this.month,
    required this.selectedDate,
    required this.dots,
    required this.fill,
    required this.mobile,
    required this.onSelectDate,
    required this.onShiftMonth,
  });

  final Palette p;
  final Events events;
  final DateTime month;
  final DateTime selectedDate;
  final Set<int> dots;
  final bool fill;
  final bool mobile;
  final ValueChanged<DateTime> onSelectDate;
  final ValueChanged<int> onShiftMonth;

  @override
  Widget build(BuildContext context) {
    final ev = events.query(date: selectedDate);
    final body = LayoutBuilder(
      builder: (context, c) {
        if (mobile && fill) {
          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: mobileNavClear),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                softBox(
                  p,
                  MonthGrid(
                    p: p,
                    month: month,
                    selectedDate: selectedDate,
                    dots: dots,
                    rowHeight: 46,
                    onSelectDate: onSelectDate,
                    onShiftMonth: onShiftMonth,
                  ),
                ),
                const SizedBox(height: 22),
                DayPanel(
                  p: p,
                  events: ev,
                  selectedDate: selectedDate,
                  fill: false,
                  mobile: mobile,
                ),
              ],
            ),
          );
        }
        if (!fill) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MonthGrid(
                p: p,
                month: month,
                selectedDate: selectedDate,
                dots: dots,
                rowHeight: 44,
                onSelectDate: onSelectDate,
                onShiftMonth: onShiftMonth,
              ),
              const SizedBox(height: 20),
              DayPanel(
                p: p,
                events: ev,
                selectedDate: selectedDate,
                fill: false,
                mobile: mobile,
              ),
            ],
          );
        }
        if (c.maxWidth >= 440) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: (c.maxWidth * 0.52).clamp(220.0, 300.0).toDouble(),
                child: MonthGrid(
                  p: p,
                  month: month,
                  selectedDate: selectedDate,
                  dots: dots,
                  rowHeight: null,
                  onSelectDate: onSelectDate,
                  onShiftMonth: onShiftMonth,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: DayPanel(
                  p: p,
                  events: ev,
                  selectedDate: selectedDate,
                  fill: true,
                  mobile: mobile,
                ),
              ),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: MonthGrid(
                p: p,
                month: month,
                selectedDate: selectedDate,
                dots: dots,
                rowHeight: null,
                onSelectDate: onSelectDate,
                onShiftMonth: onShiftMonth,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              flex: 2,
              child: DayPanel(
                p: p,
                events: ev,
                selectedDate: selectedDate,
                fill: true,
                mobile: mobile,
              ),
            ),
          ],
        );
      },
    );
    return panelCard(
      p,
      'Calendar',
      LucideIcons.calendar,
      body,
      fill: fill,
      enter: 3,
      mobile: mobile,
    );
  }
}
