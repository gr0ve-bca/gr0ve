import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:gr0ve/config/home_prefs.dart';
import '../../models/home_day.dart';
import '../common/panel_card.dart';
import '../common/skeleton_views.dart';
import 'period_countdown.dart';

class ScheduleCard extends StatelessWidget {
  const ScheduleCard({
    super.key,
    required this.p,
    required this.dayFuture,
    required this.lunchPeriod,
    required this.mobile,
    required this.onRetry,
  });

  final Palette p;
  final Future<HomeDay> dayFuture;
  final String? lunchPeriod;
  final bool mobile;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => panelCard(
    p,
    'Schedule',
    HugeIcons.strokeRoundedClock01,
    FutureBuilder<HomeDay>(
      future: dayFuture,
      builder: (_, s) {
        final Widget w;
        final String k;
        if (s.hasError) {
          if (kDebugMode) debugPrint('${s.error}');
          k = 'error';
          w = errorStateView(p, onRetry);
        } else if (!s.hasData) {
          k = 'loading';
          w = scheduleSkeleton(p);
        } else {
          k = 'data';
          w = PeriodCountdown(day: s.data!, p: p, lunch: lunchPeriod);
        }
        return AnimatedSize(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topLeft,
          child: swapTransition(k, w),
        );
      },
    ),
    mobile: mobile,
  );
}
