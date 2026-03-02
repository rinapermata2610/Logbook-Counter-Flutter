import 'package:mongo_dart/mongo_dart.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../features/logbook/models/log_model.dart';
import '../utils/log_helper.dart'; // Import LogHelper untuk Task 4

class MongoService {
  static final MongoService _instance = MongoService._internal();
  factory MongoService() => _instance;
  MongoService._internal();

  Db? _db;
  final String _source = "MongoService"; // Identitas source untuk filtering

  Future<void> connect() async {
    if (_db != null && _db!.isConnected) return;
    try {
      final dbUri = dotenv.env['MONGODB_URI'];
      if (dbUri == null) throw Exception("URI .env tidak ditemukan!");
      
      _db = await Db.create(dbUri);
      await _db!.open();
      
      // Task 4: Audit Log saat koneksi berhasil
      await LogHelper.writeLog(_source, "Database connected successfully to Atlas.");
    } catch (e) {
      await LogHelper.writeLog(_source, "Database connection failed: $e");
      rethrow;
    }
  }

  DbCollection get collection => _db!.collection('logs');

  /// PERBAIKAN TASK 3 & 4: Fetch dengan Audit Logging
  Future<List<LogModel>> getLogs(String username) async {
    try {
      // Task 4: Smart Logger mencatat aktivitas fetch
      await LogHelper.writeLog(_source, "Fetching all logs for user: $username");
      
      final cursor = collection.find(where.eq('username', username));
      final result = await cursor.toList();
      
      return result.map((json) => LogModel.fromJson(json)).toList();
    } catch (e) {
      await LogHelper.writeLog(_source, "Error during getLogs: $e");
      return [];
    }
  }

  /// PERBAIKAN TASK 4: Insert dengan Audit Logging
  Future<void> insertLog(LogModel log) async {
    try {
      await collection.insertOne(log.toJson());
      await LogHelper.writeLog(_source, "Inserted new log: ${log.title} (ID: ${log.id})");
    } catch (e) {
      await LogHelper.writeLog(_source, "Failed to insert log: $e");
    }
  }

  /// PERBAIKAN TASK 4: Update dengan Audit Logging
  Future<void> updateLog(dynamic id, String title, String desc, String category) async {
    try {
      await collection.updateOne(
        where.id(id),
        modify.set('title', title).set('description', desc).set('category', category),
      );
      await LogHelper.writeLog(_source, "Updated log ID: $id with new title: $title");
    } catch (e) {
      await LogHelper.writeLog(_source, "Failed to update log ID $id: $e");
    }
  }

  /// PERBAIKAN TASK 4: Delete dengan Audit Logging
  Future<void> deleteLog(dynamic id) async {
    try {
      await collection.remove(where.id(id));
      await LogHelper.writeLog(_source, "Deleted log ID: $id from Cloud.");
    } catch (e) {
      await LogHelper.writeLog(_source, "Failed to delete log ID $id: $e");
    }
  }

  Future<void> close() async {
    await LogHelper.writeLog(_source, "Closing database connection.");
    await _db?.close();
  }
}