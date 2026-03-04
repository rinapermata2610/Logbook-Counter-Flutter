import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart'; //
import 'features/onboarding/onboarding_view.dart'; 
import 'services/mongo_service.dart';

void main() async {
  // 1. Pastikan Flutter Engine siap sebelum proses async
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Memuat konfigurasi .env untuk kredensial MongoDB & Logging
  try {
    await dotenv.load(fileName: ".env");
    debugPrint("SUCCESS: File .env berhasil dimuat");
  } catch (e) {
    debugPrint("ERROR: File .env tidak ditemukan: $e");
  }

  // 3. HOMEWORK: Inisialisasi format tanggal lokal Indonesia
  try {
    await initializeDateFormatting('id_ID', null);
    debugPrint("SUCCESS: Locale Indonesia diinisialisasi");
  } catch (e) {
    debugPrint("ERROR: Gagal memuat locale: $e");
  }

  // 4. TASK 2 & 4: Inisialisasi koneksi awal ke MongoDB Atlas
  try {
    await MongoService().connect();
  } catch (e) {
    // Tetap jalankan aplikasi meski koneksi awal gagal (Connection Guard akan menangani di UI)
    debugPrint("WARNING: Gagal koneksi awal ke MongoDB: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Logbook Rina',
      debugShowCheckedModeBanner: false,
      
      // TASK 3: Konfigurasi tema global agar konsisten
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.pink,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.black,
          titleTextStyle: TextStyle(
            color: Colors.black, 
            fontSize: 20, 
            fontWeight: FontWeight.bold
          ),
        ),
      ),
      
      // Pintu masuk pertama aplikasi
      home: const OnboardingView(),
    );
  }
}