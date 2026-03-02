import 'dart:io'; // Tambahkan ini
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logbook_app_001/services/mongo_service.dart';

void main() {
  // PERBAIKAN: Gunakan binding yang mengizinkan akses network asli
  // Jangan gunakan TestWidgetsFlutterBinding.ensureInitialized()
  
  group('MongoDB Atlas Connection Test', () {
    
    setUpAll(() async {
      // Mengizinkan HttpClient untuk melakukan request asli selama test
      HttpOverrides.global = null; 
      
      // Load file .env
      await dotenv.load(fileName: ".env");
    });

    test('Harus berhasil terhubung ke MongoDB Atlas', () async {
      final mongoService = MongoService();

      print("\n[TEST] Memulai percobaan koneksi...");
      
      try {
        await mongoService.connect();
        
        // Verifikasi koneksi
        expect(mongoService.collection, isNotNull);
        
        print("[TEST] SUCCESS: Koneksi ke Atlas Berhasil!");
      } catch (e) {
        print("[TEST] ERROR DETAIL: $e");
        fail("[TEST] FAILED: Tidak bisa terhubung ke Atlas.");
      } finally {
        await mongoService.close();
      }
    });
  });
}