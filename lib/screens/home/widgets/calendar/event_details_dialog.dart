import 'package:f0rest/f0rest.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gr0ve/config/home_prefs.dart';
import '../../utils/home_helpers.dart';
import '../../utils/home_typography.dart';

class EventDetailsDialog extends StatelessWidget {
  const EventDetailsDialog({
    super.key,
    required this.p,
    required this.event,
    required this.mobile,
  });

  final Palette p;
  final Event event;
  final bool mobile;

  static void show(
    BuildContext context, {
    required Palette p,
    required Event event,
    required bool mobile,
  }) {
    showDialog(
      context: context,
      builder: (_) => EventDetailsDialog(p: p, event: event, mobile: mobile),
    );
  }

  @override
  Widget build(BuildContext context) {
    final when = event.allDay
        ? 'All Day'
        : (event.end != null && event.end!.isAfter(event.start)
              ? '${formatTime(event.start)} to ${formatTime(event.end!)}'
              : formatTime(event.start));
    return Dialog(
      backgroundColor: p.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: edgeColor(p, mobile),
          width: borderWidth(mobile),
        ),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      event.title,
                      style: sansStyle(18, p.text, w: FontWeight.w700),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(LucideIcons.x, size: 20, color: p.sub),
                    style: IconButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      hoverColor: p.bg,
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(LucideIcons.clock, size: 16, color: p.ink),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${formatDayName(event.start)} · $when',
                      style: uiStyle(13, p.ink, w: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              if (event.location != null &&
                  event.location!.trim().isNotEmpty) ...[
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(LucideIcons.mapPin, size: 16, color: p.sub),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        event.location!.trim(),
                        style: sansStyle(13, p.text),
                      ),
                    ),
                  ],
                ),
              ],
              if (event.description.trim().isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: p.bg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: edgeColor(p, mobile),
                      width: borderWidth(mobile),
                    ),
                  ),
                  child: Text(
                    event.description.trim(),
                    style: sansStyle(13, p.text, ls: 0.2),
                  ),
                ),
              ],
              if (event.url != null && event.url!.trim().isNotEmpty) ...[
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => launchUrl(Uri.parse(event.url!.trim())),
                  icon: const Icon(LucideIcons.externalLink, size: 16),
                  label: Text(
                    'OPEN LINK',
                    style: sansStyle(13, p.text, w: FontWeight.w700, ls: 0.5),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: p.text,
                    side: BorderSide(
                      color: edgeColor(p, mobile),
                      width: borderWidth(mobile),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    minimumSize: const Size.fromHeight(52),
                  ).copyWith(overlayColor: WidgetStatePropertyAll(p.surface)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
