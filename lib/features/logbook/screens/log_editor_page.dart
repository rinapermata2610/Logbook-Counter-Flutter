import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/log_model.dart';

class LogEditorPage extends StatefulWidget {
  final LogModel? log;

  const LogEditorPage({super.key, this.log});

  @override
  State<LogEditorPage> createState() => _LogEditorPageState();
}

class _LogEditorPageState extends State<LogEditorPage> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late String _selectedCategory;
  late bool _isPublic;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.log?.title ?? "");
    _descriptionController = TextEditingController(text: widget.log?.description ?? "");
    
    // HOMEWORK: Menggunakan kategori teknis sesuai spesifikasi
    _selectedCategory = widget.log?.category ?? "Mechanical";
    
    // TASK 5: Default privat (false) untuk menjamin kedaulatan data
    _isPublic = widget.log?.isPublic ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.log == null ? "Tambah Aktivitas" : "Edit Aktivitas"),
          backgroundColor: Colors.pink.shade50,
          bottom: const TabBar(
            indicatorColor: Colors.pink,
            labelColor: Colors.pink,
            tabs: [
              Tab(icon: Icon(Icons.edit_note), text: "Editor"),
              Tab(icon: Icon(Icons.auto_awesome), text: "Preview"),
            ],
          ),
          actions: [
            IconButton(
              onPressed: _handleSave,
              icon: const Icon(Icons.check_circle, color: Colors.pink, size: 28),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: TabBarView(
          children: [
            _buildEditorTab(),
            _buildPreviewTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildEditorTab() {
    return ListView(
      padding: const EdgeInsets.all(20.0),
      children: [
        TextField(
          controller: _titleController,
          decoration: InputDecoration(
            labelText: "Judul Log",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 20),
        
        // TASK 5: Kontrol Visibilitas (Private by Default)
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: SwitchListTile(
            title: const Text("Visibilitas Publik"),
            subtitle: Text(_isPublic 
              ? "Anggota tim dapat melihat catatan ini" 
              : "Hanya Anda yang dapat melihat catatan ini"),
            value: _isPublic,
            activeColor: Colors.pink,
            onChanged: (bool value) => setState(() => _isPublic = value),
            secondary: Icon(_isPublic ? Icons.public : Icons.lock_outline, 
                color: _isPublic ? Colors.blue : Colors.orange),
          ),
        ),
        const SizedBox(height: 20),
        
        // HOMEWORK: Dropdown Kategori Teknis
        DropdownButtonFormField<String>(
          value: _selectedCategory,
          decoration: InputDecoration(
            labelText: "Kategori Proyek",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.category),
          ),
          items: ["Mechanical", "Electronic", "Software"]
              .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
              .toList(),
          onChanged: (value) => setState(() => _selectedCategory = value!),
        ),
        const SizedBox(height: 20),
        
        TextField(
          controller: _descriptionController,
          maxLines: 12,
          decoration: InputDecoration(
            labelText: "Deskripsi (Markdown)",
            hintText: "Gunakan # Header atau **Bold**",
            alignLabelWithHint: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildPreviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Visual Indicator untuk Kategori (Homework)
              Chip(
                label: Text(_selectedCategory),
                backgroundColor: _getCategoryColor().withOpacity(0.1),
                labelStyle: TextStyle(color: _getCategoryColor(), fontWeight: FontWeight.bold),
              ),
              Icon(_isPublic ? Icons.public : Icons.lock, color: Colors.grey, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _titleController.text.isEmpty ? "Tanpa Judul" : _titleController.text,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const Divider(height: 32),
          MarkdownBody(
            data: _descriptionController.text.isEmpty 
                ? "_Belum ada deskripsi untuk dipratinjau._" 
                : _descriptionController.text,
            selectable: true,
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor() {
    switch (_selectedCategory) {
      case 'Mechanical': return Colors.green;
      case 'Electronic': return Colors.blue;
      case 'Software': return Colors.purple;
      default: return Colors.grey;
    }
  }

  void _handleSave() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Judul tidak boleh kosong!")),
      );
      return;
    }

    Navigator.pop(context, {
      'title': _titleController.text.trim(),
      'desc': _descriptionController.text.trim(),
      'category': _selectedCategory,
      'isPublic': _isPublic,
    });
  }
}