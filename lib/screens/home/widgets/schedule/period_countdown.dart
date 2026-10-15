import 'dart:async';
import 'package:f0rest/f0rest.dart';
import 'package:flutter/material.dart';
import 'package:gr0ve/config/home_prefs.dart';
import '../../models/home_day.dart';
import '../../utils/home_helpers.dart';
import '../../utils/home_typography.dart';

class PeriodCountdown extends StatefulWidget {
  const PeriodCountdown({
    super.key,
    required this.day,
    required this.p,
    this.lunch,
  });

  final HomeDay day;
  final Palette p;
  final String? lunch;

  @override
  State<PeriodCountdown> createState() => _PeriodCountdownState();
}

class _PeriodCountdownState extends State<PeriodCountdown> {
  Timer? _t;

  @override
  void initState() {
    super.initState();
    _t = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  String _name(String k) => k == 'IGS' ? 'IGS' : 'Period $k';

  String _tag(String k) => k == widget.lunch ? '  ·  Lunch' : '';

  String _fmt(Duration d) {
    final s = d.inSeconds < 0 ? 0 : d.inSeconds;
    final h = s ~/ 3600;
    final m = (s % 3600) ~/ 60;
    return h > 0
        ? '$h:${formatTwoDigits(m)}:${formatTwoDigits(s % 60)}'
        : '${formatTwoDigits(m)}:${formatTwoDigits(s % 60)}';
  }

  Widget _view(
    Palette p,
    String k,
    String label,
    Widget hero,
    String sub, {
    double? progress,
  }) => AnimatedSize(
    duration: const Duration(milliseconds: 260),
    curve: Curves.easeOutCubic,
    alignment: Alignment.topLeft,
    child: AnimatedSwitcher(
      duration: const Duration(milliseconds: 320),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeIn,
      layoutBuilder: (cur, prev) => Stack(
        alignment: Alignment.topLeft,
        children: [...prev, if (cur != null) cur],
      ),
      transitionBuilder: (child, a) => FadeTransition(
        opacity: a,
        child: SlideTransition(
          position: Tween(
            begin: const Offset(0, 0.06),
            end: Offset.zero,
          ).animate(a),
          child: child,
        ),
      ),
      child: KeyedSubtree(
        key: ValueKey(k),
        child: _body(p, label, hero, sub, progress),
      ),
    ),
  );

  Widget _body(
    Palette p,
    String label,
    Widget hero,
    String sub,
    double? progress,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: sansStyle(14, p.sub, w: FontWeight.w500)),
      const SizedBox(height: 8),
      FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: hero,
      ),
      const SizedBox(height: 16),
      if (progress != null) ...[
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: Container(
            height: 4,
            color: p.line,
            alignment: Alignment.centerLeft,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress.clamp(0.0, 1.0)),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutCubic,
              builder: (_, v, __) => FractionallySizedBox(
                widthFactor: v,
                child: Container(color: p.accent),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
      Text(sub, style: sansStyle(14, p.text)),
    ],
  );

  Widget _text(Palette p, String t) =>
      Text(t, style: uiStyle(40, p.text, ls: -1));

  Widget _time(Palette p, Duration d) =>
      Text(_fmt(d), style: monoStyle(40, p.text, w: FontWeight.w700, ls: -0.5));

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    final now = DateTime.now();
    final rows = widget.day.periods.entries.toList()
      ..sort((a, b) => a.value.start.compareTo(b.value.start));

    if (rows.isEmpty) {
      return _view(
        p,
        'none',
        'Today',
        _text(p, 'No school'),
        'Nothing in the next two weeks.',
      );
    }
    if (!widget.day.today) {
      return _view(
        p,
        'off',
        'Today',
        _text(p, 'No school'),
        'Back ${formatDayName(widget.day.day)}, first bell ${formatClock(rows.first.value.start)}',
      );
    }

    MapEntry<String, SchedulePeriod>? cur, next;
    for (final e in rows) {
      final s = e.value;
      if (!now.isBefore(s.start) && now.isBefore(s.end)) {
        cur = e;
        break;
      }
      if (now.isBefore(s.start)) {
        next = e;
        break;
      }
    }
    if (cur == null && next == null) {
      return _view(
        p,
        'done',
        'Today',
        _text(p, "School's out"),
        'Done for the day.',
      );
    }

    if (cur != null) {
      final s = cur.value;
      return _view(
        p,
        'cur-${cur.key}',
        '${_name(cur.key)}${_tag(cur.key)}',
        _time(p, s.end.difference(now)),
        'Ends at ${formatClock(s.end)}',
        progress:
            now.difference(s.start).inSeconds /
            s.end.difference(s.start).inSeconds,
      );
    }
    final n = next!;
    final before = now.isBefore(rows.first.value.start);
    return _view(
      p,
      '${before ? 'before' : 'pass'}-${n.key}',
      before ? 'Before school' : 'Passing time',
      _time(p, n.value.start.difference(now)),
      'Next: ${_name(n.key)}${_tag(n.key)} at ${formatClock(n.value.start)}',
    );
  }
}
