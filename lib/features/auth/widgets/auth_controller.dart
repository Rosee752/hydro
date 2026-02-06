import 'package:flutter/material.dart';

import '../../../core/services/local_storage.dart';

/// Global in-memory auth singleton.
///
/// * Ships with one **built-in demo account** (`demo@hydro.app`).
/// * For real apps replace with hashed storage.
class AuthController with ChangeNotifier {
  // ── singleton boiler-plate
  static final AuthController _instance = AuthController._internal();
  factory AuthController() => _instance;
  AuthController._internal() {
    // ← built-in test user
    _users['demo@hydro.app'] = _User(
      fullName: 'Demo User',
      email: 'demo@hydro.app',
      phone: '',
      password: 'password123',
    );
  }

  // ── in-memory store
  final Map<String, _User> _users = {}; // key = email
  _User? _current;
  _User? get current => _current;

  // ── register
  Future<bool> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    if (_users.containsKey(email)) return false;
    _users[email] =
        _User(fullName: fullName, email: email, phone: phone, password: password);
    _current = _users[email];
    await LocalStorage().setBool('remember_me', true);
    await LocalStorage().setString('remember_email', email);
    notifyListeners();
    return true;
  }

  // ── login
  Future<bool> login({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    final user = _users[email];
    if (user == null || user.password != password) return false;
    _current = user;
    await LocalStorage().setBool('remember_me', rememberMe);
    if (rememberMe) {
      await LocalStorage().setString('remember_email', email);
    } else {
      await LocalStorage().remove('remember_email');
    }
    notifyListeners();
    return true;
  }

  // ── auto-login helper (if you ever call it)
  Future<void> tryAutoLogin() async {
    final remember = LocalStorage().getBool('remember_me') ?? false;
    final email = LocalStorage().getString('remember_email');
    if (!remember || email == null) return;
    _current = _users[email];
    notifyListeners();
  }

  void logout() {
    _current = null;
    notifyListeners();
  }
}

class _User {
  final String fullName;
  final String email;
  final String phone;
  final String password; // plain for demo

  _User({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.password,
  });
}
