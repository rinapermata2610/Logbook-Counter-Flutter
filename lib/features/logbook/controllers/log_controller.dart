import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/log_model.dart';

class LogController {
  final String username;
  LogController({required this.username});

  // Task 3: ValueNotifier untuk manajemen state reaktif tanpa setState manual di UI
  final ValueNotifier<List<LogModel>> logs = ValueNotifier<List<LogModel>>([]);

  // --- Task 4: Persistence Logic (JSON & SharedPreferences) ---

  // Fungsi internal untuk menyimpan data setiap ada perubahan (C/U/D)
  Future<void> _saveToLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Mengonversi List Object menjadi List Map, lalu ke String JSON
      final List<Map<String, dynamic>> mapList = 
          logs.value.map((log) => log.toMap()).toList();
      
      final String jsonString = jsonEncode(mapList);
      
      // Simpan menggunakan key yang unik per user
      await prefs.setString('logbook_data_$username', jsonString);
    } catch (e) {
      debugPrint("Error saving data: $e");
    }
  }

  // Fungsi untuk memuat data saat aplikasi pertama kali dibuka
  Future<void> loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString('logbook_data_$username');

      if (jsonString != null && jsonString.isNotEmpty) {
        // Decode JSON String kembali menjadi List dynamic
        final List<dynamic> decodedList = jsonDecode(jsonString);
        
        // Mapping kembali ke dalam List<LogModel>
        logs.value = decodedList.map((item) => LogModel.fromMap(item)).toList();
      }
    } catch (e) {
      debugPrint("Error loading data: $e");
      // Jika error (misal data korup), set ke list kosong agar aplikasi tidak crash
      logs.value = [];
    }
  }

  // --- Task 2: CRUD Operations dengan Auto-Save ---

  // CREATE
  void addLog(String title, String desc) {
    if (title.trim().isEmpty) return; // Validasi sederhana

    final newLog = LogModel(
      title: title,
      description: desc,
      // Format timestamp: YYYY-MM-DD HH:mm
      timestamp: DateTime.now().toString().substring(0, 16),
    );

    // Spread operator untuk memicu notifikasi pada ValueNotifier
    logs.value = [...logs.value, newLog];
    _saveToLocal(); 
  }

  // UPDATE
  void editLog(int index, String newTitle, String newDesc) {
    if (index < 0 || index >= logs.value.length) return;

    // Update properti objek pada index tertentu
    logs.value[index].title = newTitle;
    logs.value[index].description = newDesc;
    
    // List.from digunakan untuk membuat referensi list baru agar UI ter-update
    logs.value = List.from(logs.value);
    _saveToLocal();
  }

  // DELETE
  void deleteLog(int index) {
    if (index < 0 || index >= logs.value.length) return;

    final currentList = List<LogModel>.from(logs.value);
    currentList.removeAt(index);
    
    logs.value = currentList;
    _saveToLocal();
  }
}