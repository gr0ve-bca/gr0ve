import 'package:flutter/material.dart';
import 'motion_utils.dart';

class ShimmerLoader extends StatefulWidget {
  const ShimmerLoader({
    super.key,
    required this.base,
    required this.glow,
    required this.child,
  });

  final Color base;
  final Color glow;
  final Widget child;

  @override
  State<ShimmerLoader> createState() => _ShimmerLoaderState();
}

class _ShimmerLoaderState extends State<ShimmerLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  );

  @override
  void initState() {
    super.initState();
    if (!reduceMotion()) _c.repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _c,
    child: widget.child,
    builder: (_, child) => ShaderMask(
      blendMode: BlendMode.srcATop,
      shaderCallback: (r) => LinearGradient(
        colors: [widget.base, widget.glow, widget.base],
        stops: const [0.3, 0.5, 0.7],
        transform: SlideGradientTransform(_c.value),
      ).createShader(r),
      child: child,
    ),
  );
}

class SlideGradientTransform extends GradientTransform {
  const SlideGradientTransform(this.t);
  final double t;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) =>
      Matrix4.translationValues(bounds.width * (t * 2 - 1), 0, 0);
}
