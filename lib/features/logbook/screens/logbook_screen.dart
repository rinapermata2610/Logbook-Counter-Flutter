import 'package:flutter/material.dart';
import '../controllers/log_controller.dart';
import '../models/log_model.dart';
import '../widgets/log_card.dart';
import 'log_editor_page.dart'; 
import '../../../services/access_policy.dart'; 
import '../../../services/connectivity_service.dart'; 
import '../../auth/login_view.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class LogbookScreen extends StatefulWidget {
  final String username;
  final String role; 

  const LogbookScreen({
    super.key, 
    required this.username, 
    required this.role
  });

  @override
  State<LogbookScreen> createState() => _LogbookScreenState();
}

class _LogbookScreenState extends State<LogbookScreen> {
  late LogController _controller;

  @override
  void initState() {
    super.initState();
    _controller = LogController(username: widget.username);
    _controller.fetchLogs();

    ConnectivityService().listenToConnection(() {
      _controller.syncPendingLogs();
    });
  }

  Future<void> _refreshData() async {
    await _controller.fetchLogs();
  }

  /// [TASK 5 UPDATE]: Menangani data isPublic dari Editor
  Future<void> _navigateToEditor({LogModel? log}) async {
    // Navigator sekarang menangkap Map<String, dynamic> karena isPublic bertipe bool
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => LogEditorPage(log: log),
      ),
    );

    if (result != null) {
      // Mengambil nilai dari hasil editor
      final String title = result['title']!;
      final String desc = result['desc']!;
      final String category = result['category']!;
      final bool isPublic = result['isPublic'] ?? false; // Ambil nilai privasi

      if (log == null) {
        // Tambah log baru dengan parameter isPublic
        await _controller.addLog(title, desc, category, isPublic);
      } else {
        // Edit log lama dengan parameter isPublic
        await _controller.editLog(log.id, title, desc, category, isPublic);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Logbook: ${widget.username}"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(20),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              "Mode: ${widget.role}", 
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.pink)
            ),
          ),
        ),
        backgroundColor: Colors.pink.shade50,
        elevation: 0,
        actions: [
          StreamBuilder(
            stream: ConnectivityService().connectionStream,
            builder: (context, snapshot) {
              final isOffline = snapshot.data?.contains(ConnectivityResult.none) ?? false;
              return Icon(
                isOffline ? Icons.cloud_off : Icons.cloud_queue,
                color: isOffline ? Colors.orange : Colors.green,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginView()),
              (route) => false,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: ValueListenableBuilder<List<LogModel>>(
              valueListenable: _controller.filteredLogs,
              builder: (context, currentLogs, _) {
                return RefreshIndicator(
                  onRefresh: _refreshData,
                  color: Colors.pink,
                  child: currentLogs.isEmpty 
                    ? _buildEmptyState() 
                    : _buildLogList(currentLogs),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToEditor(),
        backgroundColor: Colors.pink,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        onChanged: _controller.searchLog,
        decoration: InputDecoration(
          hintText: "Cari catatan...",
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.pink.shade50.withValues(alpha: 0.3),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildLogList(List<LogModel> logs) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final item = logs[index];

        // [TASK 5 SOVEREIGNTY]: Cek izin hanya berdasarkan kepemilikan (isOwner)
        final bool canManage = AccessPolicy.canManageLog(
          userRole: widget.role,
          currentUsername: widget.username,
          logOwner: item.username,
        );

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Dismissible(
            key: Key(item.id),
            direction: canManage ? DismissDirection.endToStart : DismissDirection.none,
            confirmDismiss: (direction) async {
              return await _showDeleteConfirm();
            },
            background: _buildDeleteBackground(),
            onDismissed: (_) => _controller.deleteLog(item.id),
            child: LogCard(
              log: item,
              color: _controller.getCategoryColor(item.category),
              onEdit: canManage ? () => _navigateToEditor(log: item) : null,
              onDelete: canManage ? () => _controller.deleteLog(item.id) : null,
            ),
          ),
        );
      },
    );
  }

  Widget _buildDeleteBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.red.shade400,
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Icon(Icons.delete_sweep, color: Colors.white, size: 30),
    );
  }

  Future<bool?> _showDeleteConfirm() {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Catatan?"),
        content: const Text("Tindakan ini akan menghapus data dari lokal dan cloud."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Batal")),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true), 
            child: const Text("Hapus", style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        Column(
          children: [
            Icon(Icons.notes_rounded, size: 100, color: Colors.pink.shade100),
            const SizedBox(height: 16),
            const Text(
              "Logbook masih kosong", 
              style: TextStyle(color: Colors.black54, fontSize: 18, fontWeight: FontWeight.bold)
            ),
            const Text(
              "Tulis aktivitas pertamamu sekarang!", 
              style: TextStyle(color: Colors.grey, fontSize: 14)
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _refreshData,
              icon: const Icon(Icons.refresh),
              label: const Text("Coba Refresh"),
            )
          ],
        ),
      ],
    );
  }
}