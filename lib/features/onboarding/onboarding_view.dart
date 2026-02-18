import 'package:flutter/material.dart';
import '../auth/login_view.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final Color primaryPink = const Color(0xFFF8BBD0); 
  final Color darkPink = const Color(0xFFC2185B);

  final List<Map<String, String>> _data = [
    {
      "image": "assets/images/onboard1.png",
      "title": "Halo, Saya Rina!",
      "desc": "Selamat datang di LogBook Rina. Mari mulai mencatat aktivitas harianmu dengan ceria dan teratur."
    },
    {
      "image": "assets/images/onboard2.png", // Pastikan path ini benar di pubspec.yaml
      "title": "Pencapaian Terbaik",
      "desc": "Pantau setiap progres dan berikan penghargaan untuk setiap target yang berhasil kamu raih."
    },
    {
      "image": "assets/images/onboard3.png",
      "title": "Analisa Data",
      "desc": "Visualisasikan data logbook-mu agar lebih mudah dipahami dan dianalisa kapan saja."
    },
    {
      "image": "assets/images/onboard4.png",
      "title": "Siap Mencatat?",
      "desc": "Semua data tercatat rapi secara digital. Ayo buat catatan pertamamu sekarang juga!"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (int page) => setState(() => _currentPage = page),
              itemCount: _data.length,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(_data[index]["image"]!, height: 280),
                    const SizedBox(height: 40),
                    Text(
                      _data[index]["title"]!,
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: darkPink),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _data[index]["desc"]!,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey.shade600, height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _data.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 8,
                width: _currentPage == index ? 24 : 8,
                decoration: BoxDecoration(
                  color: _currentPage == index ? darkPink : primaryPink,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  if (_currentPage == _data.length - 1) {
                    Navigator.pushReplacement(
                      context, MaterialPageRoute(builder: (_) => const LoginView())
                    );
                  } else {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 500), 
                      curve: Curves.easeInOut
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryPink,
                  foregroundColor: darkPink,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: Text(_currentPage == _data.length - 1 ? "Masuk ke Portal" : "Lanjut"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}