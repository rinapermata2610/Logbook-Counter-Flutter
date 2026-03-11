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
  
  // Task 4: Field untuk sinkronisasi lokal
  @HiveField(6)
  final bool isSynced;

  // TASK 5: Field untuk privasi data (Default: false/Private)
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
    this.isPublic = false, // Secara default bersifat privat
  });

  // Method copyWith: Digunakan oleh LogController untuk update data tanpa merusak objek asli
  LogModel copyWith({
    String? title,
    String? description,
    String? category,
    bool? isSynced,
    bool? isPublic,
  }) {
    return LogModel(
      id: this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      username: this.username,
      timestamp: this.timestamp,
      isSynced: isSynced ?? this.isSynced,
      isPublic: isPublic ?? this.isPublic,
    );
  }

  // Konversi dari JSON (MongoDB/API)
  factory LogModel.fromJson(Map<String, dynamic> json) {
    return LogModel(
      // Menangani fleksibilitas ID MongoDB (ObjectId atau String)
      id: json['_id'] is String ? json['_id'] : (json['_id']?.toString() ?? ""),
      title: json['title'] ?? "",
      description: json['description'] ?? "",
      category: json['category'] ?? "General",
      username: json['username'] ?? "Unknown",
      timestamp: json['timestamp'] ?? DateTime.now().toIso8601String(),
      isSynced: true, // Data dari Cloud dianggap sudah tersinkron
      isPublic: json['isPublic'] ?? false,
    );
  }

  // Konversi ke JSON (Untuk dikirim ke MongoDB Cloud)
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'username': username,
      'timestamp': timestamp,
      'isPublic': isPublic,
      // '_id' biasanya tidak dikirim saat POST baru, 
      // tapi dikirim saat PUT/PATCH. Sesuaikan dengan backend Anda.
    };
  }
}