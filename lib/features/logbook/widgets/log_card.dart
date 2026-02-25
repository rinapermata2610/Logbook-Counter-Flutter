import 'package:flutter/material.dart';
import '../models/log_model.dart';

class LogCard extends StatelessWidget {
  final LogModel log;
  final Color color;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const LogCard({
    super.key,
    required this.log,
    required this.color,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(log.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("${log.category} - ${log.description}"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.edit, size: 20), onPressed: onEdit),
            IconButton(icon: const Icon(Icons.delete, size: 20, color: Colors.red), onPressed: onDelete),
          ],
        ),
      ),
    );
  }
}