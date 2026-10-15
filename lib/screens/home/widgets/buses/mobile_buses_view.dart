import 'package:f0rest/f0rest.dart';
import 'package:flutter/material.dart';
import '../../../../config/bus_stars.dart';
import 'package:gr0ve/config/home_prefs.dart';
import '../navigation/screen_header.dart';
import 'bus_card.dart';

class MobileBusesView extends StatelessWidget {
  const MobileBusesView({
    super.key,
    required this.p,
    required this.pad,
    required this.busesFuture,
    required this.stars,
    required this.onRetry,
  });

  final Palette p;
  final double pad;
  final Future<List<BusSpot>> busesFuture;
  final BusStars stars;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(pad + 8, 28, pad + 8, 0),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ScreenHeader(
              p: p,
              subtitle: 'FINALLY LEAVING',
              title: 'BUSES',
              center: true,
            ),
            Expanded(
              child: BusCard(
                p: p,
                busesFuture: busesFuture,
                stars: stars,
                fill: true,
                mobile: true,
                onRetry: onRetry,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
