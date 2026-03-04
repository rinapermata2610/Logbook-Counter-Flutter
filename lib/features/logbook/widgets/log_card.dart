import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; //
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
    // HOMEWORK: Formatting Timestamp ke format lokal Indonesia
    String formattedDate = "";
    try {
      DateTime dateTime = DateTime.parse(log.timestamp);
      // Hasil: "04 Mar 2026, 17:22"
      formattedDate = DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(dateTime);
    } catch (e) {
      formattedDate = log.timestamp; // Fallback jika parsing gagal
    }

    return Card(
      elevation: 3, // Cosmetic: Memberikan bayangan agar kartu lebih "timbul"
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), // Cosmetic: Sudut lebih melengkung
      child: Container(
        // Memberikan aksen warna tipis di sisi kiri kartu untuk kategori
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: color, width: 6)),
          borderRadius: BorderRadius.circular(15),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          title: Text(
            log.title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              // Menampilkan kategori dengan badge kecil
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  log.category,
                  style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              Text(log.description, style: TextStyle(color: Colors.grey.shade800)),
              const SizedBox(height: 10),
              // HOMEWORK: Menampilkan icon jam dan waktu yang sudah diformat
              Row(
                children: [
                  const Icon(Icons.access_time, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    formattedDate,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          // UX Enhancement: Menggunakan PopupMenu agar tampilan lebih bersih
          trailing: PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'edit') onEdit();
              if (value == 'delete') onDelete();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 20, color: Colors.blue),
                    SizedBox(width: 8),
                    Text("Edit"),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 20, color: Colors.red),
                    SizedBox(width: 8),
                    Text("Hapus", style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}