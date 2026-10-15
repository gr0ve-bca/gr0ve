import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../config/home_prefs.dart';

const String changelogUrl =
    'https://raw.githubusercontent.com/gr0ve-bca/arb0r/refs/heads/main/changelog.json';

class ChangelogItem {
  final String icon;
  final String title;
  final String description;

  const ChangelogItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  factory ChangelogItem.fromJson(Map<String, dynamic> j) {
    return ChangelogItem(
      icon: (j['icon'] ?? 'sparkles').toString(),
      title: (j['title'] ?? '').toString(),
      description: (j['desciprtion'] ?? j['description'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'icon': icon,
        'title': title,
        'desciprtion': description,
      };

  IconData get iconData {
    switch (icon.toLowerCase()) {
      case 'bus':
        return LucideIcons.bus;
      case 'calendar':
      case 'event':
        return LucideIcons.calendar;
      case 'user':
      case 'teacher':
        return LucideIcons.user;
      case 'utensils':
      case 'lunch':
      case 'food':
        return LucideIcons.utensils;
      case 'palette':
      case 'theme':
        return LucideIcons.palette;
      case 'clock':
      case 'schedule':
        return LucideIcons.clock;
      case 'game':
      case 'gamepad':
        return LucideIcons.gamepad2;
      case 'zap':
      case 'fast':
        return LucideIcons.zap;
      case 'shield':
      case 'lock':
        return LucideIcons.shield;
      case 'smartphone':
      case 'mobile':
        return LucideIcons.smartphone;
      default:
        return LucideIcons.sparkles;
    }
  }
}

class ChangelogRelease {
  final String version;
  final String title;
  final String shortTitle;
  final List<ChangelogItem> updates;

  const ChangelogRelease({
    required this.version,
    required this.title,
    required this.shortTitle,
    required this.updates,
  });

  factory ChangelogRelease.fromJson(Map<String, dynamic> j) {
    final list = j['updates'] as List<dynamic>? ?? const [];
    return ChangelogRelease(
      version: (j['version'] ?? '3.0.0').toString(),
      title: (j['title'] ?? 'New Update').toString(),
      shortTitle: (j['short_title'] ?? '').toString(),
      updates: list
          .map((e) => ChangelogItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  static const defaultRelease = ChangelogRelease(
    version: '3.0.0',
    title: 'Grove 3.0 Redesign',
    shortTitle: 'Modern flat design, mobile tabs & live school data',
    updates: [
      ChangelogItem(
        icon: 'mobile',
        title: 'Responsive Mobile Layout',
        description:
            'Dedicated 5-tab mobile navigation bar for Home, Teachers, Buses, Events, and More.',
      ),
      ChangelogItem(
        icon: 'palette',
        title: 'New Grove Flat Branding',
        description:
            'Completely flat design language: no drop shadows, 1.5px clean borders, and custom theme accents.',
      ),
      ChangelogItem(
        icon: 'utensils',
        title: 'Lunch Nutrition Facts',
        description:
            'Tap any item in today\'s lunch menu to view complete nutrition breakdowns and calories.',
      ),
      ChangelogItem(
        icon: 'calendar',
        title: 'Interactive Events Calendar',
        description:
            'Click on any school or club event to view detailed descriptions, locations, and timings.',
      ),
      ChangelogItem(
        icon: 'game',
        title: 'ac0rn Daily Word Game',
        description:
            'New daily puzzle experience for BCA students inspired by Wordle and linked word games.',
      ),
    ],
  );

  static Future<ChangelogRelease> fetchLatest() async {
    try {
      final res = await http.get(Uri.parse(changelogUrl)).timeout(
            const Duration(seconds: 4),
          );
      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        if (decoded is Map<String, dynamic>) {
          return ChangelogRelease.fromJson(decoded);
        }
      }
    } catch (_) {
    }
    return defaultRelease;
  }
}

void showChangelogDialog(BuildContext context, Palette p) {
  showDialog(
    context: context,
    builder: (_) => FutureBuilder<ChangelogRelease>(
      future: ChangelogRelease.fetchLatest(),
      builder: (context, snapshot) {
        final release = snapshot.data ?? ChangelogRelease.defaultRelease;
        return Dialog(
          backgroundColor: p.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: p.line, width: 1.5),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480, maxHeight: 600),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: p.tint,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: p.accent, width: 1.5),
                        ),
                        child: Text(
                          'v${release.version}',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: p.ink,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          release.title,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: p.text,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Close',
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(LucideIcons.x, size: 20, color: p.sub),
                        style: IconButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          hoverColor: p.bg,
                        ),
                      ),
                    ],
                  ),
                  if (release.shortTitle.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      release.shortTitle,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: p.sub,
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  Divider(color: p.line, height: 1),
                  const SizedBox(height: 14),
                  Expanded(
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: release.updates.length,
                      separatorBuilder: (_, index) => const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                        final update = release.updates[i];
                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: p.bg,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: p.line, width: 1.5),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: p.tint,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  update.iconData,
                                  size: 18,
                                  color: p.ink,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      update.title,
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: p.text,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      update.description,
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 13,
                                        color: p.sub,
                                        height: 1.35,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}
