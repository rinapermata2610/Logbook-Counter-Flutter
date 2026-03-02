import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// Sesuaikan kembali ke path asli kamu:
import 'features/onboarding/onboarding_view.dart'; 
import 'services/mongo_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Memuat konfigurasi .env
  try {
    await dotenv.load(fileName: ".env");
    debugPrint("SUCCESS: File .env berhasil dimuat");
  } catch (e) {
    debugPrint("ERROR: File .env tidak ditemukan: $e");
  }

  // Inisialisasi koneksi awal (Audit Log Koneksi Task 4)
  try {
    await MongoService().connect();
  } catch (e) {
    debugPrint("WARNING: Gagal koneksi awal: $e");
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
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.pink,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.black,
        ),
      ),
      // Gunakan path yang benar
      home: const OnboardingView(),
    );
  }
}