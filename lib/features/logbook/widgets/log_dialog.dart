import 'package:flutter/material.dart';
import '../models/log_model.dart';

class LogDialog extends StatefulWidget {
  final LogModel? log;
  const LogDialog({super.key, this.log});

  @override
  State<LogDialog> createState() => _LogDialogState();
}

class _LogDialogState extends State<LogDialog> {
  late TextEditingController _title;
  late TextEditingController _desc;
  String _cat = "Umum";

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.log?.title ?? "");
    _desc = TextEditingController(text: widget.log?.description ?? "");
    _cat = widget.log?.category ?? "Umum";
  }

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.log == null ? "Tambah Catatan" : "Edit Catatan"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: _title, decoration: const InputDecoration(labelText: "Judul")),
          TextField(controller: _desc, decoration: const InputDecoration(labelText: "Deskripsi")),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _cat,
            items: ["Umum", "Pekerjaan", "Pribadi", "Urgent"]
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (v) => setState(() => _cat = v!),
            decoration: const InputDecoration(labelText: "Kategori", border: OutlineInputBorder()),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, {
            'title': _title.text,
            'desc': _desc.text,
            'category': _cat,
          }),
          child: const Text("Simpan"),
        )
      ],
    );
  }
}