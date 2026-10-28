library;

import 'package:flutter/foundation.dart';
import 'package:spr0ut/spr0ut.dart';

class AuthService {
  AuthService._();
  static final instance = AuthService._();

  final Spr0utSupabaseBackend _backend = Spr0utSupabaseBackend();
  Spr0utUser? _currentUser;
  bool _initialized = false;
  Spr0utUser? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  final ValueNotifier<Spr0utUser?> userNotifier = ValueNotifier<Spr0utUser?>(
    null,
  );
  String? get accessToken => _backend.accessToken;

  Future<void> init() async {
    if (_initialized) return;

    try {
      final savedUser = await _backend.restoreSession();
      if (savedUser != null) {
        _currentUser = savedUser;
        userNotifier.value = savedUser;
        if (kDebugMode) {
          print(
            '[AuthService] Restored persistent session for ${savedUser.email}',
          );
        }
      }
    } catch (e) {
      if (kDebugMode) print('[AuthService] Init error: $e');
    }

    _initialized = true;
  }

  Future<void> send6DigitEmailCode(String email) async {
    await _backend.sendOtpCode(email);
  }

  Future<Spr0utIdentity> verify6DigitCode({
    required String email,
    required String code,
  }) async {
    return _backend.verifyOtpCode(email: email, token: code);
  }

  Future<Spr0utUser?> checkExistingProfile(String uid) async {
    return _backend.fetchProfile(uid);
  }

  void setActiveUser(Spr0utUser user) {
    _currentUser = user;
    userNotifier.value = user;
  }

  Future<Spr0utUser> saveProfile({
    required String uid,
    required String email,
    required String firstName,
    required String lastName,
    required String academy,
    required int gradYear,
  }) async {
    final cleanFname = firstName.trim();
    final cleanLname = lastName.trim();
    final cleanAcademy = academy.trim().toUpperCase();

    final displayName = '${cleanLname}_$cleanFname ($cleanAcademy-$gradYear)';

    final user = await _backend.saveProfile(
      uid: uid,
      email: email.trim().toLowerCase(),
      displayName: displayName,
      theme: 'grover',
    );

    _currentUser = user;
    userNotifier.value = user;
    return user;
  }

  Future<void> updateTheme(Spr0utTheme theme) async {
    final u = _currentUser;
    if (u == null) return;
    try {
      await _backend.setTheme(u.uid, theme);
      _currentUser = u.copyWith(theme: theme);
    } catch (e) {
      if (kDebugMode) print('[AuthService] Theme save failed: $e');
    }
  }

  Future<void> signOut() async {
    await _backend.signOut();
    _currentUser = null;
    userNotifier.value = null;
  }
}
