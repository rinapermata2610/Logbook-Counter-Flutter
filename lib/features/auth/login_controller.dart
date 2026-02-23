import 'dart:async';

class LoginController {
  // Database statis untuk praktikum
  final Map<String, String> _users = {
    "rina": "123",
    "admin": "admin",
  };

  int _attempt = 0;
  bool _isLocked = false;

  // Getter untuk mengecek status tombol (apakah terkunci/tidak)
  bool get isLocked => _isLocked;

  // Fungsi validasi input agar tidak kosong
  String? validate(String username, String password) {
    if (username.isEmpty || password.isEmpty) {
      return "Username dan password wajib diisi!";
    }
    return null;
  }

  // Fungsi utama login
  bool login(String username, String password) {
    if (_users.containsKey(username) && _users[username] == password) {
      _attempt = 0; 
      return true;
    }

    // Jika gagal, hitung percobaan
    _attempt++;
    if (_attempt >= 3) {
      _lockAccount();
    }
    return false;
  }

  // Mengunci akses selama 10 detik
  void _lockAccount() {
    _isLocked = true;
    Timer(const Duration(seconds: 10), () {
      _attempt = 0;
      _isLocked = false;
    });
  }
}