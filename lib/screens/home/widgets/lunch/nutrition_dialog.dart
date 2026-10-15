import 'package:f0rest/f0rest.dart';
import 'package:flutter/material.dart';
import 'package:gr0ve/config/home_prefs.dart';
import '../../utils/home_helpers.dart';
import '../../utils/home_typography.dart';

class NutritionDialog extends StatelessWidget {
  const NutritionDialog({
    super.key,
    required this.p,
    required this.entry,
    required this.mobile,
  });

  final Palette p;
  final LunchEntry entry;
  final bool mobile;

  static void show(
    BuildContext context, {
    required Palette p,
    required LunchEntry entry,
    required bool mobile,
  }) {
    final n = entry.food.nutrition;
    if (n == null || n.isEmpty) return;
    showDialog(
      context: context,
      builder: (_) => NutritionDialog(p: p, entry: entry, mobile: mobile),
    );
  }

  @override
  Widget build(BuildContext context) {
    final n = entry.food.nutrition!;
    const keys = <String, String>{
      'calories': 'Calories',
      'g_fat': 'Total Fat',
      'g_saturated_fat': 'Saturated Fat',
      'g_trans_fat': 'Trans Fat',
      'mg_cholesterol': 'Cholesterol',
      'mg_sodium': 'Sodium',
      'g_carbs': 'Total Carbs',
      'g_fiber': 'Dietary Fiber',
      'g_sugar': 'Sugar',
      'g_protein': 'Protein',
    };

    String unit(String k) {
      if (k == 'calories') return '';
      if (k.startsWith('g_')) return 'g';
      if (k.startsWith('mg_')) return 'mg';
      return '';
    }

    return Dialog(
      backgroundColor: p.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: edgeColor(p, mobile),
          width: borderWidth(mobile),
        ),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                entry.food.name,
                style: sansStyle(16, p.text, w: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(entry.station, style: sansStyle(13, p.sub)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: p.bg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: edgeColor(p, mobile),
                    width: borderWidth(mobile),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('NUTRITION FACTS', style: uiStyle(11, p.sub, ls: 1.5)),
                    const SizedBox(height: 12),
                    for (final e in keys.entries)
                      if (n[e.key] != null) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                e.value,
                                style: sansStyle(
                                  13,
                                  e.key == 'calories' ? p.text : p.sub,
                                  w: e.key == 'calories'
                                      ? FontWeight.w700
                                      : FontWeight.w400,
                                ),
                              ),
                              Text(
                                '${n[e.key]}${unit(e.key)}',
                                style: sansStyle(
                                  13,
                                  e.key == 'calories' ? p.ink : p.text,
                                  w: e.key == 'calories'
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (e.key == 'calories')
                          Divider(color: p.line, height: 12),
                      ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Close',
                    style: sansStyle(14, p.text, w: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
