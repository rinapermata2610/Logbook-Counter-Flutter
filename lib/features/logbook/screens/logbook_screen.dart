import 'package:flutter/material.dart';
import '../controllers/log_controller.dart';
import '../models/log_model.dart';
import '../widgets/log_card.dart';
import '../widgets/log_dialog.dart';
import '../../auth/login_view.dart'; 

class LogbookScreen extends StatefulWidget {
  final String username;
  const LogbookScreen({super.key, required this.username});

  @override
  State<LogbookScreen> createState() => _LogbookScreenState();
}

class _LogbookScreenState extends State<LogbookScreen> {
  late LogController _controller;

  @override
  void initState() {
    super.initState();
    _controller = LogController(username: widget.username);
    _controller.loadData();
  }

  // Fungsi Konfirmasi Logout
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Keluar"),
        content: const Text("Apakah Anda yakin ingin logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Tutup dialog
              // Pindah ke Login dan hapus semua history page sebelumnya
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginView()),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Ya, Keluar", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _handleShowDialog({LogModel? log, int? index}) async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => LogDialog(log: log),
    );

    if (result != null) {
      if (log == null) {
        _controller.addLog(result['title']!, result['desc']!);
      } else {
        _controller.editLog(index!, result['title']!, result['desc']!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Logbook: ${widget.username}"),
        backgroundColor: Colors.pink.shade100,
        centerTitle: true,
        // Tombol Logout di pojok kanan atas
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: _showLogoutDialog,
          ),
        ],
      ),
      body: ValueListenableBuilder<List<LogModel>>(
        valueListenable: _controller.logs,
        builder: (context, currentLogs, _) {
          if (currentLogs.isEmpty) {
            return const Center(child: Text("Belum ada catatan aktivitas."));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: currentLogs.length,
            itemBuilder: (context, index) {
              final logItem = currentLogs[index];
              return LogCard(
                log: logItem,
                onEdit: () => _handleShowDialog(log: logItem, index: index),
                onDelete: () => _controller.deleteLog(index),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _handleShowDialog(),
        backgroundColor: Colors.pink,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}