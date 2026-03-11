import 'package:flutter/material.dart';
import '../models/log_model.dart';

/// LOGIC CONTROLLER: Menangani semua manipulasi data Logbook.
/// Dipisahkan dari UI untuk mematuhi prinsip Clean Architecture.
class LogController {
  final String username;
  
  // Notifier untuk update list secara real-time di UI (LogbookScreen)
  final ValueNotifier<List<LogModel>> filteredLogs = ValueNotifier<List<LogModel>>([]);
  
  // Database lokal (dalam memori)
  List<LogModel> _allLogs = [];

  LogController({required this.username});

  /// [Method 1] Fetch Data awal
  Future<void> fetchLogs() async {
    // Di sini nantinya bisa ditambahkan pemanggilan ke Hive atau MongoDB API
    // Untuk sekarang kita inisialisasi list kosong
    _applyFilter("");
  }

  /// [Method 2] Sinkronisasi yang dipanggil oleh ConnectivityService di Screen
  Future<void> syncPendingLogs() async {
    debugPrint("🔄 Sinkronisasi data cloud untuk user: $username");
    // Logika sinkronisasi data offline ke cloud
  }

  /// [Method 3] Tambah Log baru (Sinkron dengan LogEditorPage)
  Future<void> addLog(String title, String desc, String category, bool isPublic) async {
    final newLog = LogModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: desc,
      category: category,
      username: username,
      isPublic: isPublic,
      timestamp: DateTime.now().toIso8601String(),
    );
    
    _allLogs.insert(0, newLog);
    _applyFilter(""); 
  }

  /// [Method 4] Edit Log yang sudah ada
  Future<void> editLog(String id, String title, String desc, String category, bool isPublic) async {
    final index = _allLogs.indexWhere((log) => log.id == id);
    if (index != -1) {
      _allLogs[index] = _allLogs[index].copyWith(
        title: title,
        description: desc,
        category: category,
        isPublic: isPublic,
      );
      _applyFilter("");
    }
  }

  /// [Method 5] Menghapus Log
  Future<void> deleteLog(String id) async {
    _allLogs.removeWhere((log) => log.id == id);
    _applyFilter("");
  }

  /// [Method 6] Fitur Search Real-time (Homework 1)
  void searchLog(String query) {
    _applyFilter(query);
  }

  /// [Internal Logic] Gabungan filter Search + Hak Akses (Task 5)
  void _applyFilter(String query) {
    filteredLogs.value = _allLogs.where((log) {
      // Sovereignity: User hanya bisa melihat miliknya sendiri ATAU yang diset Public
      final bool canSee = log.username == username || log.isPublic;
      
      final bool matchesQuery = log.title.toLowerCase().contains(query.toLowerCase()) ||
                                log.description.toLowerCase().contains(query.toLowerCase());
                                
      return canSee && matchesQuery;
    }).toList();
  }

  /// [Method 7] Warna Kategori untuk LogCard & Chip UI
  Color getCategoryColor(String category) {
    switch (category) {
      case 'Mechanical': return Colors.green;
      case 'Electronic': return Colors.blue;
      case 'Software': return Colors.purple;
      default: return Colors.grey;
    }
  }
}