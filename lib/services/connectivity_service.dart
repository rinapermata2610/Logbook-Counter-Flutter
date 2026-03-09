import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  
  // Stream untuk mendengarkan perubahan koneksi secara real-time
  Stream<List<ConnectivityResult>> get connectionStream => _connectivity.onConnectivityChanged;

  /// Fungsi untuk mengecek apakah saat ini ada akses internet
  Future<bool> hasInternet() async {
    final List<ConnectivityResult> results = await _connectivity.checkConnectivity();
    
    // Jika tidak ada koneksi sama sekali (none)
    if (results.contains(ConnectivityResult.none)) {
      return false;
    }
    
    // Bisa dikembangkan untuk mengecek akses internet asli (ping google/atlas)
    return true;
  }

  /// Listener otomatis untuk memicu sinkronisasi
  void listenToConnection(VoidCallback onReconnected) {
    connectionStream.listen((List<ConnectivityResult> results) {
      if (!results.contains(ConnectivityResult.none)) {
        debugPrint("Koneksi terdeteksi: Memicu sinkronisasi otomatis...");
        onReconnected();
      } else {
        debugPrint("Koneksi terputus: Berjalan dalam mode Offline (Hive).");
      }
    });
  }
}