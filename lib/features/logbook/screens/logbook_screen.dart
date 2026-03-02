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
  // TASK 3: Inisialisasi Future untuk FutureBuilder
  late Future<List<LogModel>> _logFuture;

  @override
  void initState() {
    super.initState();
    _controller = LogController(username: widget.username);
    // Memuat data pertama kali
    _logFuture = _controller.fetchLogs();
  }

  // TASK 3: Fungsi Auto-Refresh untuk memicu fetch ulang ke Cloud
  void _refreshData() {
    setState(() {
      _logFuture = _controller.fetchLogs();
    });
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
      // TASK 3: Trigger refresh otomatis setelah menambah/mengedit data
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
            // TASK 3: Menggunakan FutureBuilder untuk menangani Latensi Jaringan
            child: FutureBuilder<List<LogModel>>(
              future: _logFuture,
              builder: (context, snapshot) {
                // 1. Loading State saat menunggu respon server Atlas
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.pink),
                  );
                }

                // 2. Error State
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }

                // 3. Reactive UI menggunakan ValueListenableBuilder untuk fitur Search
                return ValueListenableBuilder<List<LogModel>>(
                  valueListenable: _controller.filteredLogs,
                  builder: (context, currentLogs, _) {
                    // 4. Empty State jika koleksi MongoDB tidak memiliki dokumen
                    if (currentLogs.isEmpty) return _buildEmptyState();

                    return RefreshIndicator(
                      onRefresh: () async => _refreshData(),
                      child: ListView.builder(
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
                              _refreshData(); // Auto-refresh setelah hapus
                            },
                            child: LogCard(
                              log: item,
                              color: _controller.getCategoryColor(item.category),
                              onEdit: () => _handleShowDialog(log: item),
                              onDelete: () async {
                                await _controller.deleteLog(item.id);
                                _refreshData(); // Auto-refresh setelah hapus via tombol
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

  Widget _buildEmptyState() {
    return SingleChildScrollView( // Agar RefreshIndicator tetap bisa ditarik
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.6,
        alignment: Alignment.center,
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notes, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              "Data Kosong", 
              style: TextStyle(color: Colors.grey, fontSize: 16)
            ),
          ],
        ),
      ),
    );
  }
}