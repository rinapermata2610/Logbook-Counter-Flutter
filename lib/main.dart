import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:hive_flutter/hive_flutter.dart'; // Library untuk database lokal biner
import 'features/onboarding/onboarding_view.dart'; 
import 'features/logbook/models/log_model.dart'; // Model yang sudah ditambahkan adaptor
import 'services/mongo_service.dart';

void main() async {
  /// Memastikan engine Flutter sudah terikat sempurna sebelum menjalankan fungsi asinkron
  WidgetsFlutterBinding.ensureInitialized();

  /// Memuat konfigurasi variabel lingkungan dari file .env
  try {
    await dotenv.load(fileName: ".env");
    debugPrint("SUCCESS: Konfigurasi .env berhasil dimuat");
  } catch (e) {
    debugPrint("ERROR: Konfigurasi .env gagal dimuat: $e");
  }

  /// Inisialisasi Hive untuk penyimpanan biner lokal (Offline-First)
  /// Proses ini krusial agar aplikasi tetap berfungsi tanpa koneksi internet
  await Hive.initFlutter();
  
  /// Registrasi LogModelAdapter agar Hive mengenali skema objek LogModel
  /// File adaptor ini dihasilkan otomatis oleh build_runner
  Hive.registerAdapter(LogModelAdapter());
  
  /// Membuka box penyimpanan utama agar siap digunakan sejak awal aplikasi berjalan
  await Hive.openBox<LogModel>('logs_box');

  /// Inisialisasi lokalisasi bahasa dan format tanggal Indonesia
  try {
    await initializeDateFormatting('id_ID', null);
    debugPrint("SUCCESS: Locale Indonesia telah aktif");
  } catch (e) {
    debugPrint("ERROR: Gagal memuat locale Indonesia: $e");
  }

  /// Inisialisasi koneksi awal ke MongoDB Atlas (Cloud Storage)
  /// Jika gagal (offline), aplikasi akan tetap berjalan dengan mengandalkan Hive
  try {
    await MongoService().connect();
  } catch (e) {
    debugPrint("WARNING: MongoDB belum terhubung, aplikasi berjalan dalam mode offline.");
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
      
      /// Konfigurasi tema global menggunakan Material 3 dan skema warna pink
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
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      
      /// Menetapkan OnboardingView sebagai halaman pertama saat aplikasi dibuka
      home: const OnboardingView(),
    );
  }
}