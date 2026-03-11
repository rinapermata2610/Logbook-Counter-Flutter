import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/log_model.dart';

class LogCard extends StatelessWidget {
  final LogModel log;
  final Color color;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const LogCard({
    super.key,
    required this.log,
    required this.color,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Format timestamp secara lokal (Indonesia)
    String formattedDate = "";
    try {
      DateTime dateTime = DateTime.parse(log.timestamp);
      formattedDate = DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(dateTime);
    } catch (e) {
      formattedDate = log.timestamp;
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        decoration: BoxDecoration(
          // HOMEWORK: Indikator warna berdasarkan kategori di sisi kiri
          border: Border(left: BorderSide(color: color, width: 8)),
          borderRadius: const BorderRadius.horizontal(left: Radius.circular(15)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Judul dan Action Menu
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      log.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (onEdit != null || onDelete != null) _buildPopupMenu(),
                ],
              ),
              const SizedBox(height: 6),

              // Tags: Kategori & Status Visibilitas (Task 5)
              Row(
                children: [
                  _buildTag(
                    label: log.category,
                    bgColor: color.withOpacity(0.1),
                    textColor: color,
                  ),
                  const SizedBox(width: 8),
                  _buildTag(
                    label: log.isPublic ? "PUBLIC" : "PRIVATE",
                    bgColor: Colors.grey.shade100,
                    textColor: Colors.grey.shade700,
                    icon: log.isPublic ? Icons.public : Icons.lock_outline,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Body: Deskripsi Singkat
              Text(
                log.description,
                style: TextStyle(color: Colors.grey.shade800, height: 1.4),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Divider(height: 24),

              // Footer: Timestamp dan Status Sinkronisasi
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(formattedDate, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                  _buildSyncStatus(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag({required String label, required Color bgColor, required Color textColor, IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            label.toUpperCase(),
            style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncStatus() {
    return Row(
      children: [
        Icon(
          log.isSynced ? Icons.cloud_done : Icons.cloud_off,
          size: 16,
          color: log.isSynced ? Colors.green : Colors.orange,
        ),
        const SizedBox(width: 4),
        Text(
          log.isSynced ? "Synced" : "Local",
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: log.isSynced ? Colors.green : Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildPopupMenu() {
    return PopupMenuButton<String>(
      padding: EdgeInsets.zero,
      icon: const Icon(Icons.more_horiz, color: Colors.grey),
      onSelected: (val) {
        if (val == 'edit') onEdit?.call();
        if (val == 'delete') onDelete?.call();
      },
      itemBuilder: (context) => [
        if (onEdit != null)
          const PopupMenuItem(
            value: 'edit',
            child: ListTile(
              leading: Icon(Icons.edit_outlined, color: Colors.blue),
              title: Text("Edit Log"),
              contentPadding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            ),
          ),
        if (onDelete != null)
          const PopupMenuItem(
            value: 'delete',
            child: ListTile(
              leading: Icon(Icons.delete_outline, color: Colors.red),
              title: Text("Delete", style: TextStyle(color: Colors.red)),
              contentPadding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            ),
          ),
      ],
    );
  }
}