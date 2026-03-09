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
  late TextEditingController _title;
  late TextEditingController _desc;
  late String _cat;
  // TASK 5: State untuk visibilitas catatan
  late bool _isPublic;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.log?.title ?? "");
    _desc = TextEditingController(text: widget.log?.description ?? "");
    _cat = widget.log?.category ?? "Umum";
    // Skenario: Default adalah false (Private)
    _isPublic = widget.log?.isPublic ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.log == null ? "Tambah Catatan" : "Edit Catatan"),
          backgroundColor: Colors.pink.shade100,
          bottom: const TabBar(
            indicatorColor: Colors.pink,
            tabs: [
              Tab(icon: Icon(Icons.edit), text: "Edit"),
              Tab(icon: Icon(Icons.visibility), text: "Preview"),
            ],
          ),
          actions: [
            IconButton(
              onPressed: _handleSave,
              icon: const Icon(Icons.check),
            )
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
      padding: const EdgeInsets.all(16.0),
      children: [
        TextField(
          controller: _title,
          decoration: const InputDecoration(labelText: "Judul", border: OutlineInputBorder()),
        ),
        const SizedBox(height: 16),
        
        // TASK 5: Input untuk status Publikasi
        SwitchListTile(
          title: const Text("Jadikan Publik"),
          subtitle: Text(_isPublic 
            ? "Anggota tim lain dapat melihat catatan ini" 
            : "Hanya Anda yang dapat melihat catatan ini"),
          value: _isPublic,
          onChanged: (bool value) {
            setState(() {
              _isPublic = value;
            });
          },
          secondary: Icon(_isPublic ? Icons.public : Icons.lock),
          activeColor: Colors.pink,
        ),
        
        const SizedBox(height: 16),
        TextField(
          controller: _desc,
          maxLines: 12,
          decoration: const InputDecoration(
            labelText: "Deskripsi (Markdown)", 
            hintText: "Gunakan # Header, **Bold**, dsb",
            border: OutlineInputBorder()
          ),
          onChanged: (v) => setState(() {}),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _cat,
          items: ["Umum", "Pekerjaan", "Pribadi", "Urgent"]
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (v) => setState(() => _cat = v!),
          decoration: const InputDecoration(labelText: "Kategori", border: OutlineInputBorder()),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.pink,
            minimumSize: const Size(double.infinity, 50),
          ),
          onPressed: _handleSave,
          child: const Text("SIMPAN PERUBAHAN", style: TextStyle(color: Colors.white)),
        )
      ],
    );
  }

  Widget _buildPreviewTab() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _title.text.isEmpty ? "Tanpa Judul" : _title.text,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              // Indikator status privasi di preview
              Icon(_isPublic ? Icons.public : Icons.lock, size: 20, color: Colors.grey),
            ],
          ),
          const Divider(),
          Expanded(
            child: MarkdownBody(
              data: _desc.text.isEmpty ? "_Belum ada deskripsi_" : _desc.text,
              selectable: true,
            ),
          ),
        ],
      ),
    );
  }

  void _handleSave() {
    Navigator.pop(context, {
      'title': _title.text,
      'desc': _desc.text,
      'category': _cat,
      'isPublic': _isPublic, // Mengirimkan status publikasi kembali
    });
  }
}