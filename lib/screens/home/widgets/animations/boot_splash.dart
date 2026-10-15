import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gr0ve/config/home_prefs.dart';
import '../../utils/home_helpers.dart';
import '../../utils/home_typography.dart';

class BootSplash extends StatefulWidget {
  const BootSplash({
    super.key,
    required this.p,
    required this.sideUrl,
    required this.ready,
    required this.onDone,
  });

  final Palette p;
  final String sideUrl;
  final bool ready;
  final VoidCallback onDone;

  @override
  State<BootSplash> createState() => _BootSplashState();
}

class _BootSplashState extends State<BootSplash>
    with SingleTickerProviderStateMixin {
  late final AnimationController _out = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  );
  late final Animation<double> _outA = Tween(
    begin: 1.0,
    end: 0.0,
  ).animate(CurvedAnimation(parent: _out, curve: Curves.easeInOut));

  bool _font = false;
  bool _svg = false;
  bool _held = false;
  bool _exiting = false;

  @override
  void initState() {
    super.initState();
    _step(GoogleFonts.pendingFonts([brandStyle(60, Colors.black)]), () {
      _font = true;
    });
    _step(SvgNetworkLoader(widget.sideUrl).loadBytes(null), () {
      _svg = true;
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      _held = true;
      if (mounted) _tryExit();
    });
  }

  void _step(Future<Object?> f, VoidCallback done) {
    f
        .timeout(const Duration(seconds: 6))
        .then<void>((_) {}, onError: (Object _) {})
        .whenComplete(() {
          if (mounted) setState(done);
        });
  }

  @override
  void didUpdateWidget(BootSplash old) {
    super.didUpdateWidget(old);
    if (widget.ready && !old.ready) _tryExit();
  }

  void _tryExit() {
    if (_exiting || !_held || !widget.ready) return;
    _exiting = true;
    _out.forward().whenComplete(() {
      if (mounted) widget.onDone();
    });
  }

  @override
  void dispose() {
    _out.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    const fade = Duration(milliseconds: 300);
    return AbsorbPointer(
      child: FadeTransition(
        opacity: _outA,
        child: Material(
          color: p.bg,
          child: LayoutBuilder(
            builder: (context, c) {
              final side = (c.maxWidth * 0.62).clamp(200.0, 440.0).toDouble();
              final fs = (math.min(c.maxWidth, c.maxHeight) * 0.17)
                  .clamp(46.0, 88.0)
                  .toDouble();
              return Stack(
                fit: StackFit.expand,
                children: [
                  Center(
                    child: AnimatedOpacity(
                      opacity: _font ? 1 : 0,
                      duration: fade,
                      child: Text(
                        brandNameText,
                        style: brandStyle(fs, p.accent),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: AnimatedOpacity(
                      opacity: _svg ? 1 : 0,
                      duration: fade,
                      child: SvgPicture.network(
                        widget.sideUrl,
                        width: side,
                        fit: BoxFit.contain,
                        alignment: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
