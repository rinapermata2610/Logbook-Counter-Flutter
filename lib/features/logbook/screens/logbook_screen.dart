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
  late Future<List<LogModel>> _logFuture;

  @override
  void initState() {
    super.initState();
    _controller = LogController(username: widget.username);
    _logFuture = _controller.fetchLogs();
  }

  // TASK 3 & HOMEWORK: Fungsi Refresh yang bisa dipanggil manual & otomatis
  Future<void> _refreshData() async {
    setState(() {
      _logFuture = _controller.fetchLogs();
    });
    // Menunggu future selesai agar animasi RefreshIndicator sinkron
    await _logFuture;
  }

  Future<void> _handleShowDialog({LogModel? log}) async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => LogDialog(log: log),
    );

    if (result != null) {
      if (log == null) {
        await _controller.addLog(
          result['title']!, 
          result['desc']!, 
          result['category']!
        );
      } else {
        await _controller.editLog(
          log.id, 
          result['title']!, 
          result['desc']!, 
          result['category']!
        );
      }
      _refreshData();
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
              decoration: InputDecoration(
                hintText: "Cari catatan...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10)
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<LogModel>>(
              future: _logFuture,
              builder: (context, snapshot) {
                // 1. Loading State
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.pink),
                  );
                }

                // 2. HOMEWORK: Connection Guard (Error/Offline State)
                if (snapshot.hasError) {
                  return _buildErrorState(snapshot.error.toString());
                }

                return ValueListenableBuilder<List<LogModel>>(
                  valueListenable: _controller.filteredLogs,
                  builder: (context, currentLogs, _) {
                    // 3. HOMEWORK: Pull-to-Refresh pembungkus list
                    return RefreshIndicator(
                      onRefresh: _refreshData,
                      color: Colors.pink,
                      child: currentLogs.isEmpty 
                        ? _buildEmptyState() 
                        : ListView.builder(
                            padding: const EdgeInsets.only(bottom: 80),
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: currentLogs.length,
                            itemBuilder: (context, index) {
                              final item = currentLogs[index];
                              return Dismissible(
                                key: Key(item.id.toString()),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  color: Colors.red,
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  child: const Icon(Icons.delete, color: Colors.white),
                                ),
                                onDismissed: (_) async {
                                  await _controller.deleteLog(item.id);
                                  _refreshData();
                                },
                                child: LogCard(
                                  log: item,
                                  color: _controller.getCategoryColor(item.category),
                                  onEdit: () => _handleShowDialog(log: item),
                                  onDelete: () async {
                                    await _controller.deleteLog(item.id);
                                    _refreshData();
                                  },
                                ),
                              );
                            },
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
        backgroundColor: Colors.pink,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // HOMEWORK: Widget untuk menampilkan pesan error/offline yang ramah
  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, size: 80, color: Colors.pink),
            const SizedBox(height: 16),
            const Text(
              "Koneksi Bermasalah",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Gagal terhubung ke MongoDB Atlas. Pastikan internetmu aktif.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _refreshData,
              icon: const Icon(Icons.refresh),
              label: const Text("Coba Lagi"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView( // Gunakan ListView agar tetap bisa di-pull refresh
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        const Column(
          children: [
            Icon(Icons.notes, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              "Belum ada catatan nih.", 
              style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold)
            ),
            Text(
              "Klik tombol + untuk menambah baru", 
              style: TextStyle(color: Colors.grey, fontSize: 14)
            ),
          ],
        ),
      ],
    );
  }
}