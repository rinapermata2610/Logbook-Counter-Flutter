class LoginController {
  final Map<String, String> _users = {
    "rina": "123",
    "admin": "admin",
  };

  int _attempt = 0;
  bool _isLocked = false;

  bool get isLocked => _isLocked;

  String? validate(String username, String password) {
    if (username.isEmpty || password.isEmpty) {
      return "Username dan Password tidak boleh kosong";
    }
    return null;
  }

  bool login(String username, String password) {
    if (_users.containsKey(username) &&
        _users[username] == password) {
      _attempt = 0;
      return true;
    }

    _attempt++;

    if (_attempt >= 3) {
      _lock();
    }

    return false;
  }

  void _lock() {
    _isLocked = true;

    Future.delayed(const Duration(seconds: 10), () {
      _attempt = 0;
      _isLocked = false;
    });
  }
}
