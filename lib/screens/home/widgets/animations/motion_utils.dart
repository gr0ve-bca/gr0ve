import 'package:flutter/widgets.dart';

bool reduceMotion() => WidgetsBinding
    .instance
    .platformDispatcher
    .accessibilityFeatures
    .disableAnimations;

Widget popInTransition(Widget c, Animation<double> a) => FadeTransition(
  opacity: a,
  child: ScaleTransition(
    scale: Tween(begin: 0.85, end: 1.0).animate(a),
    child: c,
  ),
);

Widget Function(Widget, Animation<double>) morphTransition(Alignment anchor) =>
    (child, a) => FadeTransition(
      opacity: a,
      child: ScaleTransition(
        alignment: anchor,
        scale: Tween(begin: 0.94, end: 1.0).animate(a),
        child: child,
      ),
    );
