import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spr0ut/spr0ut.dart';

import '../services/auth_service.dart';
import 'theme.dart';

class Palette {
  const Palette({
    required this.bg,
    required this.surface,
    required this.line,
    required this.text,
    required this.sub,
    required this.accent,
    required this.onAccent,
  });

  final Color bg, surface, line, text, sub, accent, onAccent;

  factory Palette.of(Color accent, {required bool dark}) => Palette(
    bg: dark ? const Color(0xFF0E0E0E) : Gr0veColors.background,
    surface: dark ? const Color(0xFF171717) : Gr0veColors.surface,
    line: dark ? const Color(0xFF2A2A2A) : Gr0veColors.border,
    text: dark ? const Color(0xFFF2F2F2) : Gr0veColors.textPrimary,
    sub: dark ? const Color(0xFF9A9A95) : Gr0veColors.textSecondary,
    accent: accent,
    onAccent: accent.computeLuminance() > 0.5
        ? Gr0veColors.textPrimary
        : Colors.white,
  );

  Color get ink => accent;

  Color get tint => Color.alphaBlend(accent.withAlpha(36), surface);
}

class HomePrefs extends ChangeNotifier {
  HomePrefs._() {
    WidgetsBinding.instance.platformDispatcher.onPlatformBrightnessChanged = () {
      if (!_hasManualDark) {
        final sysDark =
            WidgetsBinding.instance.platformDispatcher.platformBrightness ==
            Brightness.dark;
        if (_dark != sysDark) {
          _dark = sysDark;
          notifyListeners();
        }
      }
    };
  }
  static final instance = HomePrefs._();

  static const _byName = <String, Color>{
    'grover': Gr0veColors.grover,
    'aspen': Gr0veColors.aspen,
    'rowan': Gr0veColors.rowan,
    'sakura': Gr0veColors.sakura,
    'abies': Gr0veColors.abies,
    'cedite': Gr0veColors.cedite,
    'ash': Gr0veColors.ash,
  };

  static final Map<Spr0utTheme, Color> accents = {
    for (final t in Spr0utTheme.values)
      if (_byName[t.name.toLowerCase()] != null)
        t: _byName[t.name.toLowerCase()]!,
  };

  static const _kDark = 'home_dark';

  bool _hasManualDark = false;
  Spr0utTheme _accent = Spr0utTheme.fallback;
  bool _dark =
      WidgetsBinding.instance.platformDispatcher.platformBrightness ==
      Brightness.dark;

  Spr0utTheme get accent => _accent;
  bool get dark => _dark;
  bool get hasManualDark => _hasManualDark;
  Palette get p =>
      Palette.of(accents[_accent] ?? accents.values.first, dark: _dark);

  void syncSystemDark(bool sysDark) {
    if (!_hasManualDark && _dark != sysDark) {
      _dark = sysDark;
      notifyListeners();
    }
  }

  Future<void> load(Spr0utTheme? userTheme) async {
    if (userTheme != null) _accent = userTheme;
    try {
      final sp = await SharedPreferences.getInstance();
      final saved = sp.getBool(_kDark);
      if (saved != null) {
        _hasManualDark = true;
        _dark = saved;
      } else {
        _dark =
            WidgetsBinding.instance.platformDispatcher.platformBrightness ==
            Brightness.dark;
      }
      notifyListeners();
    } catch (e) {
      if (kDebugMode) debugPrint('HomePrefs load failed: $e');
    }
  }

  Future<void> setAccent(Spr0utTheme t) async {
    if (_accent == t) return;
    _accent = t;
    notifyListeners();
    final uid = AuthService.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      await Spr0utSupabaseBackend().setTheme(uid, t);
    } catch (e) {
      if (kDebugMode) debugPrint('HomePrefs setTheme failed: $e');
    }
  }

  Future<void> setDark(bool d) async {
    _hasManualDark = true;
    if (_dark == d) return;
    _dark = d;
    notifyListeners();
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.setBool(_kDark, d);
    } catch (e) {
      if (kDebugMode) debugPrint('HomePrefs save failed: $e');
    }
  }
}
