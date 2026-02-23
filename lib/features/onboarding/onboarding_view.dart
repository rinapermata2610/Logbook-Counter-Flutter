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

  // Konstanta warna agar lebih mudah dikelola
  static const Color primaryPink = Color(0xFFF8BBD0);
  static const Color darkPink = Color(0xFFC2185B);

  final List<Map<String, String>> _data = [
    {
      "image": "assets/images/onboard1.png",
      "title": "Halo, Saya Rina!",
      "desc": "Selamat datang di LogBook Rina. Mari mulai mencatat aktivitas harianmu dengan ceria dan teratur."
    },
    {
      "image": "assets/images/onboard2.png",
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
  void dispose() {
    _pageController.dispose(); // Membersihkan controller dari memori
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // Menggunakan SafeArea agar tidak terpotong notch/status bar
      body: SafeArea(
        child: Column(
          children: [
            // Area Konten Slide
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (int page) => setState(() => _currentPage = page),
                itemCount: _data.length,
                itemBuilder: (context, index) => _buildPageItem(index),
              ),
            ),

            // Indikator Titik (Dots Navigator)
            _buildDotsIndicator(),

            const SizedBox(height: 40),

            // Tombol Aksi Bawah
            _buildActionButton(),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Widget untuk isi setiap halaman slide
  Widget _buildPageItem(int index) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Placeholder jika image belum ada, ganti ke Image.asset jika asset sudah siap
          Image.asset(
            _data[index]["image"]!,
            height: 280,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.image_outlined,
              size: 200,
              color: primaryPink,
            ),
          ),
          const SizedBox(height: 40),
          Text(
            _data[index]["title"]!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: darkPink,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _data[index]["desc"]!,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk titik-titik indikator
  Widget _buildDotsIndicator() {
    return Row(
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
    );
  }

  // Widget untuk tombol Lanjut / Masuk
  Widget _buildActionButton() {
    bool isLastPage = _currentPage == _data.length - 1;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: SizedBox(
        width: double.infinity,
        height: 55,
        child: ElevatedButton(
          onPressed: () {
            if (isLastPage) {
              // Pindah ke halaman login
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginView()),
              );
            } else {
              // Slide ke halaman berikutnya
              _pageController.nextPage(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: isLastPage ? darkPink : primaryPink,
            foregroundColor: isLastPage ? Colors.white : darkPink,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          child: Text(
            isLastPage ? "Masuk ke Portal" : "Lanjut",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ),
    );
  }
}