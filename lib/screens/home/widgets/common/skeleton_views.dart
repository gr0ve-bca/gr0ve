import 'package:flutter/material.dart';
import 'package:gr0ve/config/home_prefs.dart';
import '../animations/shimmer_loader.dart';

Widget shimBox(Palette p, Widget child) => ShimmerLoader(
  base: p.line,
  glow: Color.lerp(p.line, p.surface, 0.65)!,
  child: child,
);

Widget boneShape({
  double? w,
  required double h,
  double r = 8,
  double gap = 0,
}) => Container(
  width: w,
  height: h,
  margin: EdgeInsets.only(bottom: gap),
  decoration: BoxDecoration(
    color: Colors.black,
    borderRadius: BorderRadius.circular(r),
  ),
);

Widget loadingListSkeleton(Palette p, {int rows = 6, double h = 62}) =>
    ClipRect(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: shimBox(
          p,
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < rows; i++) boneShape(h: h, r: 14, gap: 10),
            ],
          ),
        ),
      ),
    );

Widget scheduleSkeleton(Palette p) => shimBox(
  p,
  Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      boneShape(w: 110, h: 14, r: 6, gap: 10),
      boneShape(w: 210, h: 40, gap: 16),
      boneShape(h: 4, r: 2, gap: 12),
      boneShape(w: 170, h: 14, r: 6),
    ],
  ),
);

Widget lunchSkeleton(Palette p) => shimBox(
  p,
  Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (final w in const [150.0, 110.0]) ...[
        boneShape(w: 70, h: 11, r: 5, gap: 10),
        boneShape(w: w + 60, h: 14, r: 6, gap: 8),
        boneShape(w: w + 20, h: 14, r: 6, gap: 8),
        boneShape(w: w + 90, h: 14, r: 6, gap: 20),
      ],
    ],
  ),
);
