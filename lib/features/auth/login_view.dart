import 'package:flutter/material.dart';
import 'login_controller.dart'; 
import '../logbook/screens/logbook_screen.dart'; 

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  // Inisialisasi controller
  final LoginController _authController = LoginController();
  
  // Controller untuk menangkap teks input
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  bool _isPasswordVisible = false;

  void _processLogin() {
    final username = _userController.text.trim();
    final password = _passController.text.trim();

    // 1. Validasi input
    final errorMsg = _authController.validate(username, password);
    if (errorMsg != null) {
      _showSnackbar(errorMsg, Colors.orange);
      return;
    }

    // 2. Eksekusi Login
    if (_authController.login(username, password)) {
      // Jika Berhasil: Pindah ke Logbook Screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LogbookScreen(username: username),
        ),
      );
    } else {
      // Jika Gagal: Update UI (untuk tombol lock) dan beri peringatan
      setState(() {}); 
      _showSnackbar("Username atau Password salah!", Colors.red);
    }
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              const SizedBox(height: 50),
              const Icon(Icons.lock_outline, size: 100, color: Colors.pink),
              const SizedBox(height: 20),
              const Text(
                "Welcome Back!",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              
              // TextField Username
              TextField(
                controller: _userController,
                decoration: InputDecoration(
                  labelText: "Username",
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
              const SizedBox(height: 20),
              
              // TextField Password
              TextField(
                controller: _passController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: "Password",
                  prefixIcon: const Icon(Icons.key),
                  suffixIcon: IconButton(
                    icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
              const SizedBox(height: 40),
              
              // Tombol Login
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _authController.isLocked ? null : _processLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: Text(
                    _authController.isLocked ? "Terkunci (10s)" : "LOGIN",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}