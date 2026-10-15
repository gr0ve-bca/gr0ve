import 'package:f0rest/f0rest.dart';
import 'package:flutter/material.dart';
import 'package:gr0ve/config/home_prefs.dart';
import '../navigation/screen_header.dart';
import 'calendar_card.dart';

class MobileEventsView extends StatelessWidget {
  const MobileEventsView({
    super.key,
    required this.p,
    required this.pad,
    required this.events,
    required this.month,
    required this.selectedDate,
    required this.dots,
    required this.onSelectDate,
    required this.onShiftMonth,
  });

  final Palette p;
  final double pad;
  final Events events;
  final DateTime month;
  final DateTime selectedDate;
  final Set<int> dots;
  final ValueChanged<DateTime> onSelectDate;
  final ValueChanged<int> onShiftMonth;

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
              subtitle: 'STUFF YOU\'LL PROBABLY MISS',
              title: 'CALENDAR',
              center: true,
            ),
            Expanded(
              child: CalendarCard(
                p: p,
                events: events,
                month: month,
                selectedDate: selectedDate,
                dots: dots,
                fill: true,
                mobile: true,
                onSelectDate: onSelectDate,
                onShiftMonth: onShiftMonth,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
