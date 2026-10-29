import 'package:f0rest/f0rest.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../config/teacher_stars.dart';
import 'package:gr0ve/config/home_prefs.dart';
import '../../utils/home_helpers.dart';
import '../../utils/home_typography.dart';
import '../animations/appear_animation.dart';
import '../common/hover_detector.dart';
import '../common/panel_card.dart';
import '../common/skeleton_views.dart';
import '../common/star_button.dart';
import '../navigation/screen_header.dart';
import 'period_grid.dart';

class MobileTeachersView extends StatefulWidget {
  const MobileTeachersView({
    super.key,
    required this.p,
    required this.pad,
    required this.absencesFuture,
    required this.stars,
    required this.onRetry,
  });

  final Palette p;
  final double pad;
  final Future<List<Absence>> absencesFuture;
  final TeacherStars stars;
  final VoidCallback onRetry;

  @override
  State<MobileTeachersView> createState() => _MobileTeachersViewState();
}

class _MobileTeachersViewState extends State<MobileTeachersView> {
  String _tq = '';
  String _pf = 'All';
  bool _pfOpen = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    return Padding(
      padding: EdgeInsets.fromLTRB(widget.pad + 8, 28, widget.pad + 8, 0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ScreenHeader(
                p: p,
                subtitle: 'HOPE YOU HAVE A FREE!',
                title: 'TEACHERS',
                center: true,
              ),
              softSearchField(
                p,
                'Search teachers...',
                (v) => setState(() => _tq = v),
              ),
              const SizedBox(height: 12),
              _periodPicker(p),
              const SizedBox(height: 18),
              Expanded(child: _teacherList(p)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _periodPicker(Palette p) => HoverDetector(
    onTap: () => _pickPeriod(p),
    builder: (h) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
      decoration: BoxDecoration(
        color: h ? p.tint : p.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: softColor(p)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Period: $_pf',
              style: sansStyle(14, p.text, w: FontWeight.w600),
            ),
          ),
          AnimatedRotation(
            turns: _pfOpen ? 0.5 : 0,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedChevronDown,
              size: 14,
              color: p.sub,
            ),
          ),
        ],
      ),
    ),
  );

  void _pickPeriod(Palette p) {
    setState(() => _pfOpen = true);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(color: softColor(p)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'FILTER BY PERIOD',
              style: monoStyle(12, p.sub, w: FontWeight.w700, ls: 2),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final v in ['All', ...periodSlots])
                  HoverDetector(
                    onTap: () {
                      Navigator.pop(context);
                      setState(() => _pf = v);
                    },
                    builder: (h) => AnimatedContainer(
                      duration: const Duration(milliseconds: 140),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: v == _pf ? p.accent : (h ? p.tint : p.bg),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: v == _pf ? p.accent : softColor(p),
                        ),
                      ),
                      child: Text(
                        v,
                        style: uiStyle(14, v == _pf ? p.bg : p.text),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    ).whenComplete(() {
      if (mounted) setState(() => _pfOpen = false);
    });
  }

  Widget _teacherList(Palette p) => FutureBuilder<List<Absence>>(
    future: widget.absencesFuture,
    builder: (context, s) {
      int rank(Absence a) {
        final out = parseOrdinalPeriods(a.status) ?? parseOutPeriods(a.status);
        final present = out != null && out.isEmpty;
        return (widget.stars.has(a.name) ? 0 : 2) + (present ? 1 : 0);
      }

      final q = _tq.toLowerCase().trim();
      final data = s.data ?? const <Absence>[];
      final shown =
          data.where((a) {
            if (q.isNotEmpty &&
                !(a.name.toLowerCase().contains(q) ||
                    (a.matched && a.department.toLowerCase().contains(q)))) {
              return false;
            }
            if (_pf == 'All') return true;
            final out =
                parseOrdinalPeriods(a.status) ?? parseOutPeriods(a.status);
            return out == null || out.contains(_pf);
          }).toList()..sort((a, b) {
            final r = rank(a) - rank(b);
            return r != 0
                ? r
                : foldString(a.name).compareTo(foldString(b.name));
          });

      final Widget raw;
      final String k;
      if (s.hasError) {
        if (kDebugMode) debugPrint('${s.error}');
        k = 'error';
        raw = errorStateView(p, widget.onRetry);
      } else if (!s.hasData) {
        k = 'loading';
        raw = loadingListSkeleton(p);
      } else if (shown.isEmpty) {
        k = 'empty';
        raw = emptyStateView(
          p,
          data.isEmpty ? 'Everyone is in today.' : 'No match.',
        );
      } else {
        k = 'list';
        raw = ListView.builder(
          padding: const EdgeInsets.only(bottom: mobileNavClear),
          itemCount: shown.length,
          itemBuilder: (_, i) => _mobileTile(p, shown[i], i),
        );
      }
      return swapTransition(k, raw);
    },
  );

  Widget _mobileTile(Palette p, Absence a, int i) {
    final title = a.matched
        ? '${a.prefix}. ${a.name.split(',').first}'
        : a.name;
    return AppearAnimation(
      index: i,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: p.bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: softColor(p)),
        ),
        child: Row(
          children: [
            StarButton(
              on: widget.stars.has(a.name),
              idle: p.sub,
              hover: Color.lerp(p.bg, p.sub, 0.55)!,
              pressed: p.ink,
              onTap: () => widget.stars.toggle(a.name),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: sansStyle(14, p.text, w: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    a.matched ? a.department : 'Not in roster',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: sansStyle(13, p.sub),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            PeriodGrid(p: p, status: a.status),
          ],
        ),
      ),
    );
  }
}
