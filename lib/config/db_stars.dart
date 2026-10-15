import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spr0ut/spr0ut.dart';

import '../services/auth_service.dart';

abstract class DbStars extends ChangeNotifier {
  DbStars(this._legacyKey, this._label);

  final String _legacyKey;
  final String _label;

  final _set = <String>{};
  Future<void> _queue = Future.value();

  String? get _uid => AuthService.instance.currentUser?.uid;

  List<String> fromUser(Spr0utUser u);
  Future<List<String>> addRemote(String uid, String key);
  Future<List<String>> removeRemote(String uid, String key);

  bool has(String key) => _set.contains(key);

  Future<void> load() async {
    final uid = _uid;
    if (uid == null) {
      clear();
      return;
    }
    try {
      final user = await Spr0ut.fetchProfile(uid);
      if (user == null) return;
      _replace(fromUser(user));
      await _importLegacy(uid);
    } catch (e) {
      if (kDebugMode) debugPrint('$_label load failed: $e');
    }
  }

  Future<bool> toggle(String key) {
    final f = _queue.then((_) => _toggle(key));
    _queue = f.then<void>((_) {}, onError: (Object _) {});
    return f;
  }

  void clear() {
    if (_set.isEmpty) return;
    _set.clear();
    notifyListeners();
  }

  Future<bool> _toggle(String key) async {
    final uid = _uid;
    if (uid == null) return false;
    final adding = !_set.contains(key);
    adding ? _set.add(key) : _set.remove(key);
    notifyListeners();
    try {
      final stored = adding
          ? await addRemote(uid, key)
          : await removeRemote(uid, key);
      _replace(stored);
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('$_label save failed: $e');
      adding ? _set.remove(key) : _set.add(key);
      notifyListeners();
      return false;
    }
  }

  void _replace(Iterable<String> items) {
    final next = items.toSet();
    if (setEquals(_set, next)) return;
    _set
      ..clear()
      ..addAll(next);
    notifyListeners();
  }

  Future<void> _importLegacy(String uid) async {
    final sp = await SharedPreferences.getInstance();
    final old = sp.getStringList(_legacyKey);
    if (old == null || old.isEmpty) return;
    for (final k in old) {
      if (!_set.contains(k)) _replace(await addRemote(uid, k));
    }
    await sp.remove(_legacyKey);
  }
}
