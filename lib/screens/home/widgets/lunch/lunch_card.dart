import 'package:f0rest/f0rest.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:gr0ve/config/home_prefs.dart';
import '../../models/home_day.dart';
import '../../utils/home_helpers.dart';
import '../../utils/home_typography.dart';
import '../common/hover_detector.dart';
import '../common/panel_card.dart';
import '../common/skeleton_views.dart';
import 'nutrition_dialog.dart';

class LunchCard extends StatelessWidget {
  const LunchCard({
    super.key,
    required this.p,
    required this.lunchFuture,
    required this.dayFuture,
    required this.lunchPeriod,
    required this.fill,
    required this.mobile,
    required this.onRetry,
  });

  final Palette p;
  final Future<List<LunchEntry>> lunchFuture;
  final Future<HomeDay> dayFuture;
  final String? lunchPeriod;
  final bool fill;
  final bool mobile;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<LunchEntry>>(
      future: lunchFuture,
      builder: (_, s) {
        final Widget w;
        final String k;
        if (s.hasError) {
          if (kDebugMode) debugPrint('${s.error}');
          k = 'error';
          w = errorStateView(p, onRetry);
        } else if (!s.hasData) {
          k = 'loading';
          w = lunchSkeleton(p);
        } else {
          k = 'data';
          final entries = s.data!;
          if (entries.isEmpty) {
            w = emptyStateView(p, 'No menu today.');
          } else {
            final by = <String, List<LunchEntry>>{};
            for (final e in entries) {
              (by[e.station] ??= []).add(e);
            }
            w = Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final entryGroup in by.entries)
                  Container(
                    margin: EdgeInsets.only(bottom: mobile ? 10 : 20),
                    padding: mobile
                        ? const EdgeInsets.fromLTRB(18, 16, 18, 14)
                        : EdgeInsets.zero,
                    decoration: mobile
                        ? BoxDecoration(
                            color: p.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: softColor(p)),
                          )
                        : null,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        sectionLabel(p, entryGroup.key),
                        const SizedBox(height: 6),
                        for (final entry in entryGroup.value)
                          HoverDetector(
                            onTap: () => NutritionDialog.show(
                              context,
                              p: p,
                              entry: entry,
                              mobile: mobile,
                            ),
                            builder: (h) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      entry.food.name,
                                      style: sansStyle(14, h ? p.ink : p.text),
                                    ),
                                  ),
                                  if (entry.food.nutrition != null &&
                                      entry.food.nutrition!.isNotEmpty)
                                    Icon(
                                      LucideIcons.info,
                                      size: 14,
                                      color: h ? p.ink : p.sub,
                                    ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            );
          }
        }

        final content = AnimatedSize(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topLeft,
          child: swapTransition(k, w),
        );

        return panelCard(
          p,
          'Lunch',
          LucideIcons.utensils,
          fill
              ? SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: mobile ? mobileNavClear : 0),
                  child: content,
                )
              : content,
          trailing: _lunchChip(p),
          fill: fill,
          enter: 4,
          mobile: mobile,
        );
      },
    );
  }

  Widget? _lunchChip(Palette p) {
    final k = lunchPeriod;
    if (k == null) return null;
    return FutureBuilder<HomeDay>(
      future: dayFuture,
      builder: (_, s) {
        final start = s.data?.periods[k]?.start;
        return countChip(
          p,
          start == null ? 'P$k' : 'P$k · ${formatClock(start)}',
        );
      },
    );
  }
}
