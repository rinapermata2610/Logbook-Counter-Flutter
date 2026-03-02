import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path_provider/path_provider.dart';

class LogHelper {
  static Future<void> writeLog(String source, String message) async {
    final logLevel = int.tryParse(dotenv.env['LOG_LEVEL'] ?? '0') ?? 0;
    final logMute = dotenv.env['LOG_MUTE']?.split(',') ?? [];

    // 1. Source Filtering: Jangan catat jika source ada di daftar LOG_MUTE
    if (logMute.contains(source)) return;

    final timestamp = DateTime.now();
    final formattedDate = "${timestamp.day.toString().padLeft(2, '0')}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.year}";
    final logEntry = "[${timestamp.toIso8601String()}] [$source] $message\n";

    // 2. Verbosity Control: Hanya muncul di terminal jika LOG_LEVEL == 3
    if (logLevel == 3) {
      print("AUDIT_LOG: $logEntry");
    }

    // 3. File Logging: Simpan otomatis ke folder /logs (dd-mm-yyyy.log)
    try {
      final directory = await getApplicationDocumentsDirectory();
      final logDir = Directory('${directory.path}/logs');
      if (!await logDir.exists()) await logDir.create();

      final file = File('${logDir.path}/$formattedDate.log');
      await file.writeAsString(logEntry, mode: FileMode.append);
    } catch (e) {
      print("Gagal menulis file log: $e");
    }
  }
}