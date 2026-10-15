import 'package:f0rest/f0rest.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:gr0ve/config/home_prefs.dart';
import '../../utils/home_helpers.dart';
import '../../utils/home_typography.dart';
import '../common/hover_detector.dart';
import '../common/panel_card.dart';
import 'event_details_dialog.dart';

class EventTile extends StatelessWidget {
  const EventTile({
    super.key,
    required this.p,
    required this.event,
    required this.mobile,
  });

  final Palette p;
  final Event event;
  final bool mobile;

  @override
  Widget build(BuildContext context) {
    final when = event.allDay
        ? 'All Day'
        : (event.end != null && event.end!.isAfter(event.start)
              ? '${formatTime(event.start)} to ${formatTime(event.end!)}'
              : formatTime(event.start));
    final note = [
      if (event.location != null && event.location!.trim().isNotEmpty)
        event.location!.trim(),
      if (event.description.trim().isNotEmpty)
        event.description.trim().replaceAll('\n', ' / '),
    ].join(' / ');
    return HoverDetector(
      onTap: () =>
          EventDetailsDialog.show(context, p: p, event: event, mobile: mobile),
      builder: (h) => tileWrapper(
        p,
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: sansStyle(14, p.text, w: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(when, style: uiStyle(11, p.ink)),
                  if (note.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      note,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: sansStyle(12, p.sub),
                    ),
                  ],
                ],
              ),
            ),
            Icon(LucideIcons.chevronRight, size: 16, color: h ? p.ink : p.sub),
          ],
        ),
        hl: h,
        mobile: mobile,
        flat: false,
      ),
    );
  }
}
