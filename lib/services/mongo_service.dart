import 'package:mongo_dart/mongo_dart.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../features/logbook/models/log_model.dart';
import '../utils/log_helper.dart';

class MongoService {
  static final MongoService _instance = MongoService._internal();
  factory MongoService() => _instance;
  MongoService._internal();

  Db? _db;
  final String _source = "MongoService";

  // TASK 4: Getter untuk mengecek status koneksi secara cepat
  bool get isConnected => _db != null && _db!.isConnected;

  Future<void> connect() async {
    if (isConnected) return;
    try {
      final dbUri = dotenv.env['MONGODB_URI'];
      if (dbUri == null) throw Exception("URI .env tidak ditemukan!");
      
      _db = await Db.create(dbUri);
      // Timeout 5 detik agar aplikasi tidak "freeze" jika internet lemot
      await _db!.open().timeout(const Duration(seconds: 5));
      
      await LogHelper.writeLog(_source, "Database connected successfully to Atlas.");
    } catch (e) {
      await LogHelper.writeLog(_source, "Database connection failed: $e");
      // Jangan rethrow agar aplikasi tidak crash saat offline, cukup log saja
    }
  }

  DbCollection get collection => _db!.collection('logs');

  /// TASK 4: Insert dengan pengecekan koneksi aktif
  Future<bool> insertLog(LogModel log) async {
    try {
      if (!isConnected) await connect(); // Coba hubungkan jika putus
      
      final result = await collection.insertOne(log.toJson());
      if (result.isSuccess) {
        await LogHelper.writeLog(_source, "Inserted new log: ${log.title} (ID: ${log.id})");
        return true;
      }
      return false;
    } catch (e) {
      await LogHelper.writeLog(_source, "Failed to insert log to Cloud: $e");
      return false;
    }
  }

  /// Update & Delete tetap menggunakan logika Anda yang sudah benar, 
  /// namun ditambahkan return bool untuk memberi sinyal ke Controller
  Future<bool> updateLog(dynamic id, String title, String desc, String category) async {
    try {
      if (!isConnected) return false;
      await collection.updateOne(
        where.id(id),
        modify.set('title', title).set('description', desc).set('category', category),
      );
      await LogHelper.writeLog(_source, "Updated log ID: $id");
      return true;
    } catch (e) {
      await LogHelper.writeLog(_source, "Failed to update log ID $id: $e");
      return false;
    }
  }

  Future<bool> deleteLog(dynamic id) async {
    try {
      if (!isConnected) return false;
      await collection.remove(where.id(id));
      await LogHelper.writeLog(_source, "Deleted log ID: $id from Cloud.");
      return true;
    } catch (e) {
      await LogHelper.writeLog(_source, "Failed to delete log ID $id: $e");
      return false;
    }
  }

  Future<List<LogModel>> getLogs(String username) async {
    try {
      if (!isConnected) return []; // Return kosong jika offline, UI akan ambil dari Hive
      await LogHelper.writeLog(_source, "Fetching all logs for user: $username");
      
      final cursor = collection.find(where.eq('username', username));
      final result = await cursor.toList();
      
      return result.map((json) => LogModel.fromJson(json)).toList();
    } catch (e) {
      await LogHelper.writeLog(_source, "Error during getLogs: $e");
      return [];
    }
  }

  Future<void> close() async {
    await LogHelper.writeLog(_source, "Closing database connection.");
    await _db?.close();
  }
}