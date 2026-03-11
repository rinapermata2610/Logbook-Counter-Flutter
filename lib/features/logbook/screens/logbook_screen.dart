import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../controllers/log_controller.dart';
import '../models/log_model.dart';
import '../widgets/log_card.dart';
import 'log_editor_page.dart'; 
import '../../../services/access_policy.dart'; 
import '../../../services/connectivity_service.dart'; 
import '../../auth/login_view.dart';

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
  // Pastikan class LogController sudah terdefinisi di log_controller.dart
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

  Future<void> _navigateToEditor({LogModel? log}) async {
    // Navigator menangkap Map dari LogEditorPage
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => LogEditorPage(log: log),
      ),
    );

    if (result != null) {
      final String title = result['title'] ?? "";
      final String desc = result['desc'] ?? "";
      final String category = result['category'] ?? "General";
      final bool isPublic = result['isPublic'] ?? false;

      if (log == null) {
        await _controller.addLog(title, desc, category, isPublic);
      } else {
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
          preferredSize: const Size.fromHeight(25),
          child: Container(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              "Access Level: ${widget.role.toUpperCase()}", 
              style: const TextStyle(fontSize: 10, letterSpacing: 1.2, fontWeight: FontWeight.bold, color: Colors.pink)
            ),
          ),
        ),
        backgroundColor: Colors.pink.shade50,
        elevation: 0,
        actions: [
          _buildConnectionIndicator(),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: _handleLogout,
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToEditor(),
        backgroundColor: Colors.pink,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("New Log", style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildConnectionIndicator() {
    return StreamBuilder<List<ConnectivityResult>>(
      stream: ConnectivityService().connectionStream,
      builder: (context, snapshot) {
        final isOffline = snapshot.data?.contains(ConnectivityResult.none) ?? false;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Icon(
            isOffline ? Icons.wifi_off_rounded : Icons.cloud_done_rounded,
            color: isOffline ? Colors.orange : Colors.green,
            size: 20,
          ),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: TextField(
        onChanged: _controller.searchLog,
        decoration: InputDecoration(
          hintText: "Search titles or content...",
          prefixIcon: const Icon(Icons.search_rounded, color: Colors.pink),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.pink.shade50),
          ),
        ),
      ),
    );
  }

  Widget _buildLogList(List<LogModel> logs) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final item = logs[index];

        // Validasi kedaulatan data (Sovereignty)
        final bool isOwner = AccessPolicy.canManageLog(
          userRole: widget.role,
          currentUsername: widget.username,
          logOwner: item.username,
        );

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Dismissible(
            key: Key(item.id),
            direction: isOwner ? DismissDirection.endToStart : DismissDirection.none,
            confirmDismiss: (dir) => _showDeleteConfirm(),
            background: _buildDeleteBackground(),
            onDismissed: (_) => _controller.deleteLog(item.id),
            child: LogCard(
              log: item,
              color: _controller.getCategoryColor(item.category),
              onEdit: isOwner ? () => _navigateToEditor(log: item) : null,
              onDelete: isOwner ? () => _controller.deleteLog(item.id) : null,
            ),
          ),
        );
      },
    );
  }

  Widget _buildDeleteBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 25),
      decoration: BoxDecoration(
        color: Colors.redAccent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.delete_forever_rounded, color: Colors.white, size: 28),
          Text("Delete", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.15),
        Opacity(
          opacity: 0.6,
          child: Column(
            children: [
              // PERBAIKAN: Typo Topic_outlined -> topic_outlined
              const Icon(Icons.topic_outlined, size: 120, color: Colors.pink),
              const SizedBox(height: 24),
              const Text(
                "No Logs Found", 
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  "Try adjusting your search or create your first activity log to get started!",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
              const SizedBox(height: 32),
              OutlinedButton.icon(
                onPressed: _refreshData,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text("Refresh List"),
                style: OutlinedButton.styleFrom(foregroundColor: Colors.pink),
              )
            ],
          ),
        ),
      ],
    );
  }

  void _handleLogout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginView()),
      (route) => false,
    );
  }

  Future<bool?> _showDeleteConfirm() {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Confirm Deletion"),
        content: const Text("This will permanently remove the log from both local storage and the cloud."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true), 
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Delete", style: TextStyle(color: Colors.white))
          ),
        ],
      ),
    );
  }
}