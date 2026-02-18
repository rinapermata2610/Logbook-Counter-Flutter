import 'package:flutter/material.dart';
import 'counter_controller.dart';
import '../auth/login_view.dart';

class CounterView extends StatefulWidget {
  final String username;
  const CounterView({super.key, required this.username});

  @override
  State<CounterView> createState() => _CounterViewState();
}

class _CounterViewState extends State<CounterView> {
  final CounterController _controller = CounterController();
  final TextEditingController _stepController = TextEditingController(text: "1");

  // Definisi Warna
  final Color softPink = const Color(0xFFFCE4EC);
  final Color deepPink = const Color(0xFFD81B60);

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() async {
    await _controller.loadData(widget.username);
    if (mounted) setState(() {});
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) return "Selamat Pagi ☀️";
    if (hour < 15) return "Selamat Siang 🌤️";
    if (hour < 18) return "Selamat Sore 🌥️";
    return "Selamat Malam 🌙";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("LogBook Digital"),
        backgroundColor: Colors.white,
        foregroundColor: deepPink,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const LoginView())
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Banner
            Container(
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              decoration: BoxDecoration(
                color: softPink,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_getGreeting(), style: TextStyle(color: deepPink, fontSize: 16)),
                  const SizedBox(height: 5),
                  Text(
                    widget.username,
                    style: TextStyle(color: deepPink, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            // Card Counter
            Center(
              child: Card(
                elevation: 0,
                color: Colors.grey.shade50,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: softPink),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 30),
                  child: Column(
                    children: [
                      Text("Total Hitungan", style: TextStyle(color: Colors.grey.shade600)),
                      Text(
                        "${_controller.value}",
                        style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold, color: deepPink),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _stepController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Step",
                prefixIcon: Icon(Icons.tune, color: deepPink),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (value) {
                final step = int.tryParse(value) ?? 1;
                setState(() => _controller.setStep(step));
              },
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => setState(() => _controller.decrement(widget.username)),
                  icon: const Icon(Icons.remove),
                  label: const Text("Kurang"),
                  style: ElevatedButton.styleFrom(backgroundColor: softPink, foregroundColor: deepPink),
                ),
                ElevatedButton.icon(
                  onPressed: () => setState(() => _controller.increment(widget.username)),
                  icon: const Icon(Icons.add),
                  label: const Text("Tambah"),
                  style: ElevatedButton.styleFrom(backgroundColor: deepPink, foregroundColor: Colors.white),
                ),
                ElevatedButton(
                  onPressed: _showResetDialog,
                  style: ElevatedButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text("Reset"),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text("Riwayat Aktivitas", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true, // Agar bisa dalam SingleChildScrollView
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _controller.history.length,
              itemBuilder: (context, index) {
                final item = _controller.history[index];
                return Card(
                  child: ListTile(
                    leading: Icon(Icons.history, color: deepPink),
                    title: Text(item),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Konfirmasi Reset"),
        content: const Text("Yakin ingin reset counter?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () {
              setState(() => _controller.reset(widget.username));
              Navigator.pop(context);
            },
            child: const Text("Reset"),
          ),
        ],
      ),
    );
  }
}