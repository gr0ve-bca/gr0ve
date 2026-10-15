import 'package:f0rest/f0rest.dart';
import 'package:flutter/material.dart';
import 'package:gr0ve/config/home_prefs.dart';
import '../../models/home_day.dart';
import '../navigation/screen_header.dart';
import 'lunch_card.dart';

class MobileLunchView extends StatelessWidget {
  const MobileLunchView({
    super.key,
    required this.p,
    required this.pad,
    required this.lunchFuture,
    required this.dayFuture,
    required this.lunchPeriod,
    required this.onRetry,
  });

  final Palette p;
  final double pad;
  final Future<List<LunchEntry>> lunchFuture;
  final Future<HomeDay> dayFuture;
  final String? lunchPeriod;
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
              subtitle: '"FOOD" THEY SAY',
              title: 'LUNCH',
              center: true,
            ),
            Expanded(
              child: LunchCard(
                p: p,
                lunchFuture: lunchFuture,
                dayFuture: dayFuture,
                lunchPeriod: lunchPeriod,
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
