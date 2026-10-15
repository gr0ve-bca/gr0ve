import 'package:f0rest/f0rest.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../config/bus_stars.dart';
import 'package:gr0ve/config/home_prefs.dart';
import '../../utils/home_helpers.dart';
import '../common/panel_card.dart';
import '../common/skeleton_views.dart';
import 'bus_tile.dart';

class BusCard extends StatefulWidget {
  const BusCard({
    super.key,
    required this.p,
    required this.busesFuture,
    required this.stars,
    required this.fill,
    required this.mobile,
    required this.onRetry,
    this.showStar = true,
  });

  final Palette p;
  final Future<List<BusSpot>> busesFuture;
  final BusStars stars;
  final bool fill;
  final bool mobile;
  final VoidCallback onRetry;
  final bool showStar;

  @override
  State<BusCard> createState() => _BusCardState();
}

class _BusCardState extends State<BusCard> {
  String _bq = '';

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    return FutureBuilder<List<BusSpot>>(
      future: widget.busesFuture,
      builder: (context, s) {
        bool mine(BusSpot b) => widget.stars.has(cleanBusLabel(b.label));

        final data = s.data ?? const <BusSpot>[];
        final q = _bq.toLowerCase().trim();
        final shown =
            data
                .where(
                  (b) =>
                      q.isEmpty ||
                      cleanBusLabel(b.label).toLowerCase().contains(q),
                )
                .toList()
              ..sort((a, b) {
                final m = (mine(b) ? 1 : 0) - (mine(a) ? 1 : 0);
                return m != 0
                    ? m
                    : cleanBusLabel(a.label).toLowerCase().compareTo(
                        cleanBusLabel(b.label).toLowerCase(),
                      );
              });
        final here = data.where((b) => b.spot != null).length;

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
          raw = emptyStateView(p, data.isEmpty ? 'No bus data.' : 'No match.');
        } else {
          k = 'list';
          raw = ListView.builder(
            padding: EdgeInsets.only(
              bottom: widget.mobile ? mobileNavClear : 0,
            ),
            itemCount: shown.length,
            itemBuilder: (_, i) => BusTile(
              p: p,
              spot: shown[i],
              isMine: mine(shown[i]),
              onToggleStar: () =>
                  widget.stars.toggle(cleanBusLabel(shown[i].label)),
              index: i,
              mobile: widget.mobile,
              flat: false,
              showStar: widget.showStar,
            ),
          );
        }
        final list = swapTransition(k, raw);

        return panelCard(
          p,
          'Buses',
          LucideIcons.bus,
          Column(
            mainAxisSize: widget.fill ? MainAxisSize.max : MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              searchField(
                p,
                'Search town or route...',
                (v) => setState(() => _bq = v),
                mobile: widget.mobile,
              ),
              const SizedBox(height: 12),
              if (widget.fill)
                Expanded(child: list)
              else
                SizedBox(height: 420, child: list),
            ],
          ),
          trailing: s.hasData ? countChip(p, '$here/${data.length}') : null,
          fill: widget.fill,
          enter: 2,
          mobile: widget.mobile,
        );
      },
    );
  }
}
