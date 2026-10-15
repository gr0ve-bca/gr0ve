import 'package:f0rest/f0rest.dart';
import 'package:flutter/material.dart';
import 'package:gr0ve/config/home_prefs.dart';
import '../../utils/home_helpers.dart';
import '../../utils/home_typography.dart';
import 'event_tile.dart';

class DayPanel extends StatelessWidget {
  const DayPanel({
    super.key,
    required this.p,
    required this.events,
    required this.selectedDate,
    required this.fill,
    required this.mobile,
  });

  final Palette p;
  final List<Event> events;
  final DateTime selectedDate;
  final bool fill;
  final bool mobile;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    mainAxisSize: fill ? MainAxisSize.max : MainAxisSize.min,
    children: [
      Row(
        children: [
          Expanded(
            child: Text(
              formatMdy(selectedDate),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: sansStyle(14, p.text, w: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${events.length} ${events.length == 1 ? 'event' : 'events'}',
            style: uiStyle(12, p.ink),
          ),
        ],
      ),
      const SizedBox(height: 14),
      if (events.isEmpty)
        Text('Nothing scheduled.', style: sansStyle(14, p.sub))
      else if (fill)
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              for (final e in events) EventTile(p: p, event: e, mobile: mobile),
            ],
          ),
        )
      else
        for (final e in events) EventTile(p: p, event: e, mobile: mobile),
    ],
  );
}
