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

  Future<void> _handleShowDialog({LogModel? log}) async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => LogDialog(log: log),
    );

    if (result != null) {
      if (log == null) {
        _controller.addLog(result['title']!, result['desc']!, result['category']!);
      } else {
        _controller.editLog(log.id, result['title']!, result['desc']!, result['category']!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Logbook: ${widget.username}"),
        backgroundColor: Colors.pink.shade100,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginView()),
              (route) => false,
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: _controller.searchLog,
              decoration: const InputDecoration(
                hintText: "Cari catatan...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ValueListenableBuilder<List<LogModel>>(
              valueListenable: _controller.filteredLogs,
              builder: (context, currentLogs, _) {
                if (currentLogs.isEmpty) return _buildEmptyState();

                return ListView.builder(
                  itemCount: currentLogs.length,
                  itemBuilder: (context, index) {
                    final item = currentLogs[index];
                    return Dismissible(
                      key: Key(item.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) => _controller.deleteLog(item.id),
                      child: LogCard(
                        log: item,
                        color: _controller.getCategoryColor(item.category),
                        onEdit: () => _handleShowDialog(log: item),
                        onDelete: () => _controller.deleteLog(item.id),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _handleShowDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notes, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text("Data Kosong", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}