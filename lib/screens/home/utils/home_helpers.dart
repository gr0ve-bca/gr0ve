import 'package:flutter/material.dart';
import 'package:gr0ve/config/home_prefs.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:spr0ut/spr0ut.dart';

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

Color edgeColor(Palette p, [bool mobile = true]) => softColor(p);

double borderWidth([bool mobile = true]) => 1.0;

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

final _allDay = RegExp(r'all\s*day', caseSensitive: false);
final _ordinal = RegExp(r'(\d{1,2})(?:st|nd|rd|th)\b');
final _range = RegExp(
  r'(\d{1,2})(?:st|nd|rd|th)?\s*(?:-|–|to|through)\s*(\d{1,2})(?:st|nd|rd|th)?',
);
final _periodList = RegExp(r'periods?\s*((?:\d{1,2}\s*(?:,|&|and)?\s*)+)');
final _digits = RegExp(r'\d{1,2}');
final _igs = RegExp(r'\bigs\b');

/// Parses period-specific statuses such as "1st period only", "2nd period",
/// "periods 3-5", or "3rd, 4th period".
///
/// Returns the matching slots in grid order, or null if the status isn't
/// period-specific (so the caller should fall back to [parseOutPeriods]).
/// Note: this null means "not handled", unlike [parseOutPeriods], where
/// null means "out all day".
List<String>? parseOrdinalPeriods(String status) {
  final s = status.toLowerCase();
  if (_allDay.hasMatch(s)) return null;
  if (!s.contains('period') && !_ordinal.hasMatch(s)) return null;

  final out = <String>{};

  if (s.contains('period')) {
    for (final m in _range.allMatches(s)) {
      final a = int.parse(m[1]!);
      final b = int.parse(m[2]!);
      for (var i = a; i <= b && i <= 9; i++) {
        out.add('$i');
      }
    }
    for (final m in _periodList.allMatches(s)) {
      for (final d in _digits.allMatches(m[1]!)) {
        out.add(d[0]!);
      }
    }
  }

  for (final m in _ordinal.allMatches(s)) {
    out.add(m[1]!);
  }
  if (_igs.hasMatch(s)) out.add('IGS');

  final result = periodSlots.where(out.contains).toList();
  return result.isEmpty ? null : result;
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
