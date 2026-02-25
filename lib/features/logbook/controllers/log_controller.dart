import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/log_model.dart';

class LogController {
  final String username;
  LogController({required this.username});

  final ValueNotifier<List<LogModel>> logs = ValueNotifier<List<LogModel>>([]);
  final ValueNotifier<List<LogModel>> filteredLogs = ValueNotifier<List<LogModel>>([]);

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString('logbook_data_$username');
    if (jsonString != null && jsonString.isNotEmpty) {
      final List<dynamic> decodedList = jsonDecode(jsonString);
      logs.value = decodedList.map((item) => LogModel.fromMap(item)).toList();
      filteredLogs.value = logs.value;
    }
  }

  void searchLog(String query) {
    if (query.isEmpty) {
      filteredLogs.value = logs.value;
    } else {
      filteredLogs.value = logs.value
          .where((log) => log.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }

  void addLog(String title, String desc, String category) {
    final newLog = LogModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: desc,
      category: category,
      timestamp: DateTime.now().toString().substring(0, 16),
    );
    logs.value = [...logs.value, newLog];
    searchLog(""); 
    _saveToLocal();
  }

  void editLog(String id, String title, String desc, String category) {
    final index = logs.value.indexWhere((log) => log.id == id);
    if (index != -1) {
      logs.value[index] = logs.value[index].copyWith(
        title: title,
        description: desc,
        category: category,
      );
      logs.value = List.from(logs.value);
      searchLog("");
      _saveToLocal();
    }
  }

  void deleteLog(String id) {
    logs.value = logs.value.where((log) => log.id != id).toList();
    searchLog("");
    _saveToLocal();
  }

  Color getCategoryColor(String category) {
    switch (category) {
      case 'Pekerjaan': return Colors.blue.shade50;
      case 'Pribadi': return Colors.green.shade50;
      case 'Urgent': return Colors.red.shade50;
      default: return Colors.white;
    }
  }

  Future<void> _saveToLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonString = jsonEncode(logs.value.map((log) => log.toMap()).toList());
    await prefs.setString('logbook_data_$username', jsonString);
  }
}