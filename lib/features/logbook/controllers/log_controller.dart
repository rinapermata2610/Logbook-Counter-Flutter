import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/log_model.dart';
import '../../../services/mongo_service.dart';

class LogController {
  final String username;
  
  // ValueNotifier agar UI (LogbookScreen) otomatis refresh saat data berubah
  final ValueNotifier<List<LogModel>> filteredLogs = ValueNotifier<List<LogModel>>([]);
  
  // Reference ke Hive Box
  final Box<LogModel> _logBox = Hive.box<LogModel>('logs_box');
  
  List<LogModel> _allLogs = [];

  LogController({required this.username});

  /// [Method 1] Load data dari Hive (Offline-First)
  Future<void> fetchLogs() async {
    // Ambil semua data dari penyimpanan lokal Hive
    _allLogs = _logBox.values.toList();
    
    // Urutkan berdasarkan waktu terbaru (Desc)
    _allLogs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    _applyFilter("");
    
    // Opsional: Coba sync otomatis setiap kali buka app jika ada internet
    syncPendingLogs();
  }

  /// [Method 2] THE SYNC MANAGER (Skenario Wajib)
  /// Fungsi ini akan mengirim data berstatus 'isSynced: false' ke MongoDB Atlas
  Future<void> syncPendingLogs() async {
    // Ambil daftar catatan yang belum tersinkron
    final pendingLogs = _logBox.values.where((log) => !log.isSynced).toList();

    if (pendingLogs.isEmpty) return;

    debugPrint("🔄 Mendeteksi ${pendingLogs.length} log lokal. Memulai sinkronisasi...");

    for (var log in pendingLogs) {
      // Kirim ke MongoDB Atlas
      bool success = await MongoService().insertLog(log);
      
      if (success) {
        // Jika berhasil, update status isSynced di Hive
        final syncedLog = log.copyWith(isSynced: true);
        await _logBox.put(log.id, syncedLog);
        
        // Update list di memori agar UI berubah dari "Local" ke "Synced"
        int index = _allLogs.indexWhere((l) => l.id == log.id);
        if (index != -1) {
          _allLogs[index] = syncedLog;
        }
        debugPrint("✅ '${log.title}' berhasil di-upload ke Atlas.");
      }
    }
    _applyFilter(""); // Refresh UI
  }

  /// [Method 3] Tambah Log (Simpan ke Hive dulu!)
  Future<void> addLog(String title, String desc, String category, bool isPublic) async {
    final newLog = LogModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: desc,
      category: category,
      username: username,
      isPublic: isPublic,
      timestamp: DateTime.now().toIso8601String(),
      isSynced: false, // Default false karena baru dibuat secara lokal
    );
    
    // 1. Simpan ke Hive (Krusial: Data aman meski app mati/offline)
    await _logBox.put(newLog.id, newLog);
    
    // 2. Tambah ke list memori untuk tampilan instan
    _allLogs.insert(0, newLog);
    _applyFilter(""); 

    // 3. Coba sync langsung (jika ada internet langsung masuk Atlas, jika tidak biarkan saja)
    syncPendingLogs();
  }

  /// [Method 4] Edit Log
  Future<void> editLog(String id, String title, String desc, String category, bool isPublic) async {
    final index = _allLogs.indexWhere((log) => log.id == id);
    if (index != -1) {
      final updatedLog = _allLogs[index].copyWith(
        title: title,
        description: desc,
        category: category,
        isPublic: isPublic,
        isSynced: false, // Reset ke false agar di-upload ulang perubahannya
      );

      await _logBox.put(id, updatedLog);
      _allLogs[index] = updatedLog;
      _applyFilter("");
      
      syncPendingLogs(); // Coba sync update-an terbaru
    }
  }

  /// [Method 5] Hapus Log
  Future<void> deleteLog(String id) async {
    // 1. Hapus di Hive
    await _logBox.delete(id);
    
    // 2. Hapus di Cloud (MongoDB)
    await MongoService().deleteLog(id);
    
    // 3. Update UI
    _allLogs.removeWhere((log) => log.id == id);
    _applyFilter("");
  }

  /// [Method 6] Search
  void searchLog(String query) {
    _applyFilter(query);
  }

  void _applyFilter(String query) {
    filteredLogs.value = _allLogs.where((log) {
      // Hak Akses: Milik sendiri ATAU Public
      final bool canSee = log.username == username || log.isPublic;
      
      final bool matchesQuery = log.title.toLowerCase().contains(query.toLowerCase()) ||
                                log.description.toLowerCase().contains(query.toLowerCase());
                                
      return canSee && matchesQuery;
    }).toList();
  }

  /// [Method 7] Warna Kategori
  Color getCategoryColor(String category) {
    switch (category) {
      case 'Mechanical': return Colors.green;
      case 'Electronic': return Colors.blue;
      case 'Software': return Colors.purple;
      case 'Urgent': return Colors.red;
      default: return Colors.pink;
    }
  }
}