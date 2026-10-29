import 'package:f0rest/f0rest.dart';
import 'package:flutter/material.dart';
import 'package:gr0ve/config/home_prefs.dart';
import '../../../config/bus_stars.dart';
import '../../../config/teacher_stars.dart';
import '../models/home_day.dart';
import '../utils/home_helpers.dart';
import 'buses/mobile_starred_buses.dart';
import 'calendar/mobile_today_events.dart';
import 'header/home_header.dart';
import 'lunch/mobile_lunch_snapshot.dart';
import 'schedule/schedule_card.dart';
import 'teachers/mobile_starred_teachers.dart';

class MobileHomeView extends StatelessWidget {
  const MobileHomeView({
    super.key,
    required this.p,
    required this.firstName,
    required this.short,
    required this.pad,
    required this.slug,
    required this.dark,
    required this.dayFuture,
    required this.lunchPeriod,
    required this.absencesFuture,
    required this.tStars,
    required this.busesFuture,
    required this.stars,
    required this.events,
    required this.lunchFuture,
    required this.onSwitchToTab,
    required this.onOpenSettings,
    required this.onRetry,
  });

  final Palette p;
  final String firstName;
  final bool short;
  final double pad;
  final String slug;
  final bool dark;
  final Future<HomeDay> dayFuture;
  final String? lunchPeriod;
  final Future<List<Absence>> absencesFuture;
  final TeacherStars tStars;
  final Future<List<BusSpot>> busesFuture;
  final BusStars stars;
  final Events events;
  final Future<List<LunchEntry>> lunchFuture;
  final ValueChanged<int> onSwitchToTab;
  final VoidCallback onOpenSettings;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: EdgeInsets.fromLTRB(pad + 8, 28, pad + 8, mobileNavClear),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            HomeHeader(
              p: p,
              firstName: firstName,
              wide: false,
              short: short,
              slug: slug,
              dark: dark,
              onOpenSettings: onOpenSettings,
            ),
            const SizedBox(height: 20),
            ScheduleCard(
              p: p,
              dayFuture: dayFuture,
              lunchPeriod: lunchPeriod,
              mobile: true,
              onRetry: onRetry,
            ),
            const SizedBox(height: homeGap),
            MobileStarredTeachers(
              p: p,
              absencesFuture: absencesFuture,
              stars: tStars,
              onSwitchToTab: onSwitchToTab,
            ),
            const SizedBox(height: homeGap),
            MobileStarredBuses(
              p: p,
              busesFuture: busesFuture,
              stars: stars,
              onSwitchToTab: onSwitchToTab,
            ),
            const SizedBox(height: homeGap),
            MobileTodayEvents(
              p: p,
              events: events,
              onSwitchToTab: onSwitchToTab,
            ),
            const SizedBox(height: homeGap),
            MobileLunchSnapshot(
              p: p,
              lunchFuture: lunchFuture,
              onSwitchToTab: onSwitchToTab,
            ),
          ],
        ),
      ),
    ),
  );
}
