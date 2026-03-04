import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' show ObjectId; // Import ObjectId
import '../../../services/mongo_service.dart';
import '../models/log_model.dart';

class LogController {
  final String username;
  LogController({required this.username});

  final MongoService _mongoService = MongoService();
  final ValueNotifier<List<LogModel>> filteredLogs = ValueNotifier<List<LogModel>>([]);
  List<LogModel> _allLogs = [];

  Future<List<LogModel>> fetchLogs() async {
  try {
    // REVISI: Tambahkan delay buatan 1.5 detik agar spinner terlihat jelas saat demo
    await Future.delayed(const Duration(milliseconds: 1500)); 

    await _mongoService.connect();
    final data = await _mongoService.getLogs(username);
    _allLogs = data;
    filteredLogs.value = _allLogs;
    return _allLogs;
  } catch (e) {
    debugPrint("Error fetch: $e");
    return [];
  }
}

  void searchLog(String query) {
    if (query.isEmpty) {
      filteredLogs.value = _allLogs;
    } else {
      filteredLogs.value = _allLogs
          .where((log) => 
              log.title.toLowerCase().contains(query.toLowerCase()) ||
              log.description.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }

  Future<void> addLog(String title, String desc, String category) async {
    try {
      final newLog = LogModel(
        id: ObjectId(), // Membuat ID unik otomatis
        title: title,
        description: desc,
        category: category,
        username: username, 
        timestamp: DateTime.now().toString().substring(0, 16),
      );

      await _mongoService.insertLog(newLog);
      await fetchLogs(); 
    } catch (e) {
      debugPrint("Error adding log: $e");
    }
  }

  Future<void> editLog(dynamic id, String title, String desc, String category) async {
    try {
      await _mongoService.updateLog(id, title, desc, category);
      await fetchLogs();
    } catch (e) {
      debugPrint("Error editing log: $e");
    }
  }

  Future<void> deleteLog(dynamic id) async {
    try {
      await _mongoService.deleteLog(id);
      await fetchLogs();
    } catch (e) {
      debugPrint("Error deleting log: $e");
    }
  }

  Color getCategoryColor(String category) {
    switch (category) {
      case 'Pekerjaan': return Colors.blue.shade100;
      case 'Pribadi': return Colors.green.shade100;
      case 'Urgent': return Colors.red.shade100;
      default: return Colors.grey.shade100;
    }
  }
}