import 'package:flutter/material.dart';
import '../models/log_model.dart';

class LogDialog extends StatefulWidget {
  final LogModel? log;

  const LogDialog({super.key, this.log});

  @override
  State<LogDialog> createState() => _LogDialogState();
}

class _LogDialogState extends State<LogDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.log?.title ?? "");
    _descController = TextEditingController(text: widget.log?.description ?? "");
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(widget.log == null ? "Catatan Baru" : "Edit Catatan"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: "Judul",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Deskripsi",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Batal"),
        ),
        ElevatedButton(
          onPressed: () {
            if (_titleController.text.isNotEmpty) {
              Navigator.pop(context, {
                'title': _titleController.text,
                'desc': _descController.text,
              });
            }
          },
          child: const Text("Simpan"),
        ),
      ],
    );
  }
}