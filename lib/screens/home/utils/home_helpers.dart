import 'package:flutter/material.dart';
import 'package:gr0ve/config/home_prefs.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:spr0ut/spr0ut.dart';
import '../../../config/theme.dart';

const daysList = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

const monthsList = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

const monthNamesList = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

const weekdaysList = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

const periodSlots = ['1', 'IGS', '2', '3', '4', '5', '6', '7', '8', '9'];

final gridSpotRegex = RegExp(r'^[A-I]\d{1,2}$', caseSensitive: false);

const quickLinksList = <(String, IconData, String)>[
  ('Schoology', LucideIcons.bookOpen, 'https://bca.schoology.com/home'),
  (
    'Powerschool',
    LucideIcons.barChart2,
    'https://bcts.powerschool.com/public/',
  ),
  (
    'Cancellations',
    LucideIcons.fileX,
    'https://docs.google.com/document/d/e/2PACX-1vRkhySmwAiTtY88tcshckpV4F0vRrULccaGrYl_Sf2ubWpyyXA4l8c-KAOuMzSwFe-qyAQhLqXzVsbA/pub',
  ),
  (
    'Buses',
    LucideIcons.bus,
    'https://docs.google.com/spreadsheets/d/1S5v7kTbSiqV8GottWVi5tzpqLdTrEgWEY4ND4zvyV3o/edit?gid=0#gid=0',
  ),
  (
    'Counselor',
    LucideIcons.calendarCheck,
    'https://outlook.office365.com/book/CounselorBookings@bergen.org/?ismsaljsauthenabled=true',
  ),
];

const arb0rBaseUrl =
    'https://raw.githubusercontent.com/gr0ve-bca/arb0r/refs/heads/main';

const brandNameText = 'GROVE';

const homeGap = 28.0;
const mobileNavClear = 124.0;
const headerLogoHeight = 26.0;

Color softColor(Palette p) => Color.lerp(p.surface, p.line, 0.4)!;

Color edgeColor(Palette p, bool mobile) => mobile ? softColor(p) : p.line;

double borderWidth(bool mobile) => mobile ? 1.0 : 1.5;

String formatTwoDigits(int n) => n.toString().padLeft(2, '0');

String formatClock(DateTime d) =>
    '${d.hour % 12 == 0 ? 12 : d.hour % 12}:${formatTwoDigits(d.minute)}';

String formatTime(DateTime d) =>
    '${formatClock(d)} ${d.hour < 12 ? 'AM' : 'PM'}';

String formatDayName(DateTime d) =>
    '${daysList[d.weekday - 1]}, ${monthsList[d.month - 1]} ${d.day}';

String formatMdy(DateTime d) =>
    '${daysList[d.weekday - 1]}, ${formatTwoDigits(d.month)}/${formatTwoDigits(d.day)}/${formatTwoDigits(d.year % 100)}';

String getGreeting() {
  final h = DateTime.now().hour;
  return h < 12 ? 'Good morning' : (h < 17 ? 'Good afternoon' : 'Good evening');
}

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

String cleanBusLabel(String s) =>
    s.replaceAll(RegExp(r'\s*\bba\d+\b', caseSensitive: false), '').trim();

int? userGrade(Spr0utUser? u) {
  final m = RegExp(r'-(\d{4})\)').firstMatch(u?.displayName ?? '');
  if (m == null) return null;
  final now = DateTime.now();
  final endYear = now.month >= 8 ? now.year + 1 : now.year;
  return (12 - (int.parse(m[1]!) - endYear)).clamp(9, 12).toInt();
}

String? userLunchPeriod(Spr0utUser? u) {
  final g = userGrade(u);
  if (g == null) return null;
  return g <= 9 ? '4' : (g == 10 ? '5' : '6');
}

Set<String>? parseOutPeriods(String status) {
  final s = status.toLowerCase();
  if (s.trim().isEmpty || s.contains('all')) return null;
  final out = <String>{};
  for (final m in RegExp(r'(\d)\s*(?:-|to)\s*(\d)').allMatches(s)) {
    for (var i = int.parse(m[1]!); i <= int.parse(m[2]!); i++) {
      out.add('$i');
    }
  }
  for (final m in RegExp(r'\b\d\b').allMatches(s)) {
    out.add(m[0]!);
  }
  if (s.contains('igs')) out.add('IGS');
  return out;
}

String foldString(String s) {
  const from = 'àáâãäåçèéêëìíîïñòóôõöùúûüýÿ';
  const to = 'aaaaaaceeeeiiiinooooouuuuyy';
  final b = StringBuffer();
  for (final r in s.toLowerCase().runes) {
    final ch = String.fromCharCode(r);
    final i = from.indexOf(ch);
    b.write(i >= 0 ? to[i] : ch);
  }
  return b.toString().trim();
}
