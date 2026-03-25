import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  
  // Stream untuk mendengarkan perubahan koneksi
  Stream<List<ConnectivityResult>> get connectionStream => _connectivity.onConnectivityChanged;

  /// Fungsi untuk mengecek internet saat ini secara instan
  Future<bool> hasInternet() async {
    final List<ConnectivityResult> results = await _connectivity.checkConnectivity();
    // Cek jika list tidak mengandung 'none'
    return !results.contains(ConnectivityResult.none);
  }

  /// Listener otomatis yang akan memicu callback saat koneksi KEMBALI tersedia
  void listenToConnection(VoidCallback onReconnected) {
    connectionStream.listen((List<ConnectivityResult> results) {
      // Jika list tidak mengandung 'none', berarti ada koneksi (WiFi atau Mobile Data)
      if (!results.contains(ConnectivityResult.none)) {
        debugPrint("🌐 ConnectivityService: Internet Terhubung!");
        onReconnected();
      } else {
        debugPrint("🔌 ConnectivityService: Mode Offline.");
      }
    });
  }
}