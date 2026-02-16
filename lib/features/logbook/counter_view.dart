import 'package:flutter/material.dart';
import 'counter_controller.dart';

class CounterView extends StatefulWidget {
  final String username;

  const CounterView({super.key, required this.username});

  @override
  State<CounterView> createState() => _CounterViewState();
}

class _CounterViewState extends State<CounterView> {
  final CounterController _controller = CounterController();
  final TextEditingController _stepController =
      TextEditingController(text: "1");

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() async {
    await _controller.loadData();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text("LogBook - ${widget.username}"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Text("Angka Terakhir"),
                    const SizedBox(height: 8),
                    Text(
                      "${_controller.value}",
                      style: const TextStyle(
                        fontSize: 44,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: _stepController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Step",
                prefixIcon: const Icon(Icons.tune),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
                  onPressed: () => setState(() =>
                      _controller.decrement(widget.username)),
                  icon: const Icon(Icons.remove),
                  label: const Text("Kurang"),
                ),
                ElevatedButton.icon(
                  onPressed: () => setState(() =>
                      _controller.increment(widget.username)),
                  icon: const Icon(Icons.add),
                  label: const Text("Tambah"),
                ),
                ElevatedButton(
                  onPressed: _showResetDialog,
                  child: const Text("Reset"),
                ),
              ],
            ),

            const SizedBox(height: 20),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Riwayat Aktivitas"),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: ListView.builder(
                itemCount: _controller.history.length,
                itemBuilder: (context, index) {
                  final item = _controller.history[index];

                  Color color = Colors.grey;
                  if (item.contains("menambah")) color = Colors.green;
                  if (item.contains("mengurangi")) color = Colors.red;

                  return Card(
                    child: ListTile(
                      leading: Icon(Icons.history, color: color),
                      title: Text(item, style: TextStyle(color: color)),
                    ),
                  );
                },
              ),
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
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => _controller.reset(widget.username));
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Counter berhasil di-reset")),
              );
            },
            child: const Text("Reset"),
          ),
        ],
      ),
    );
  }
}
