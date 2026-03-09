import 'dart:async';

class LoginController {
  // Database statis dengan penambahan Role
  final Map<String, Map<String, String>> _users = {
    "rina": {"pass": "123", "role": "Anggota"},
    "admin": {"pass": "admin", "role": "Ketua"},
  };

  int _attempt = 0;
  bool _isLocked = false;

  bool get isLocked => _isLocked;

  // Modifikasi fungsi login untuk mengembalikan role jika berhasil
  String? getRole(String username) {
    return _users[username]?['role'];
  }

  String? validate(String username, String password) {
    if (username.isEmpty || password.isEmpty) {
      return "Username dan password wajib diisi!";
    }
    return null;
  }

  // Fungsi login yang sekarang lebih informatif
  bool login(String username, String password) {
    if (_isLocked) return false;

    if (_users.containsKey(username) && _users[username]!['pass'] == password) {
      _attempt = 0; 
      return true;
    }

    _attempt++;
    if (_attempt >= 3) {
      _lockAccount();
    }
    return false;
  }

  void _lockAccount() {
    _isLocked = true;
    Timer(const Duration(seconds: 10), () {
      _attempt = 0;
      _isLocked = false;
    });
  }
}