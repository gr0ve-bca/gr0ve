import 'package:f0rest/f0rest.dart';
import 'package:flutter/material.dart';
import 'package:gr0ve/config/home_prefs.dart';
import '../../utils/home_helpers.dart';
import '../../utils/home_typography.dart';
import '../common/panel_card.dart';
import '../common/star_button.dart';

class BusTile extends StatelessWidget {
  const BusTile({
    super.key,
    required this.p,
    required this.spot,
    required this.isMine,
    required this.onToggleStar,
    required this.index,
    required this.mobile,
    required this.flat,
    this.showStar = true,
  });

  final Palette p;
  final BusSpot spot;
  final bool isMine;
  final VoidCallback onToggleStar;
  final int index;
  final bool mobile;
  final bool flat;
  final bool showStar;

  @override
  Widget build(BuildContext context) {
    final spotValue = spot.spot;
    final arrived = spotValue != null && gridSpotRegex.hasMatch(spotValue);
    final status = spotValue == null
        ? 'Not arrived'
        : (arrived ? 'Arrived' : 'Delayed');
    return tileWrapper(
      p,
      Row(
        children: [
          AnimatedScale(
            scale: showStar ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
            child: AnimatedOpacity(
              opacity: showStar ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 250),
              child: StarButton(
                on: isMine,
                idle: p.sub,
                hover: Color.lerp(p.bg, p.sub, 0.55)!,
                pressed: p.ink,
                onTap: onToggleStar,
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: showStar ? 14 : 0,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cleanBusLabel(spot.label),
                  style: sansStyle(14, p.text, w: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(status, style: sansStyle(13, p.sub)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            constraints: const BoxConstraints(minWidth: 48),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: arrived ? p.accent : p.surface,
              borderRadius: BorderRadius.circular(8),
              border: arrived
                  ? null
                  : Border.all(
                      color: edgeColor(p, mobile),
                      width: borderWidth(mobile),
                    ),
            ),
            child: Center(
              widthFactor: 1,
              child: Text(
                spotValue ?? '?',
                style: uiStyle(14, arrived ? p.onAccent : p.sub),
              ),
            ),
          ),
        ],
      ),
      i: index,
      mobile: mobile,
      flat: flat,
    );
  }
}
