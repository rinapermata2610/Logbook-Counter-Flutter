import 'package:hive/hive.dart';

part 'log_model.g.dart';

@HiveType(typeId: 0)
class LogModel {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String description;
  @HiveField(3)
  final String category;
  @HiveField(4)
  final String username;
  @HiveField(5)
  final String timestamp;
  @HiveField(6)
  final bool isSynced;
  @HiveField(7)
  final bool isPublic;

  LogModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.username,
    required this.timestamp,
    this.isSynced = false,
    this.isPublic = false,
  });

  // Perbaikan: Tambahkan copyWith yang lengkap untuk semua field
  LogModel copyWith({
    String? title,
    String? description,
    String? category,
    bool? isSynced,
    bool? isPublic,
  }) {
    return LogModel(
      id: this.id, // ID tidak boleh berubah
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      username: this.username,
      timestamp: this.timestamp,
      isSynced: isSynced ?? this.isSynced,
      isPublic: isPublic ?? this.isPublic,
    );
  }

  factory LogModel.fromJson(Map<String, dynamic> json) {
    return LogModel(
      // Sinkronisasi ID: Mengambil '_id' dari MongoDB dan menyimpannya sebagai 'id' di Hive
      id: json['_id']?.toString() ?? json['id'] ?? "", 
      title: json['title'] ?? "",
      description: json['description'] ?? "",
      category: json['category'] ?? "Umum",
      username: json['username'] ?? "Unknown",
      timestamp: json['timestamp'] ?? DateTime.now().toIso8601String(),
      isSynced: true, // Data dari Cloud otomatis dianggap tersinkron
      isPublic: json['isPublic'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {

      '_id': id, 
      'title': title,
      'description': description,
      'category': category,
      'username': username,
      'timestamp': timestamp,
      'isPublic': isPublic,
    };
  }
}