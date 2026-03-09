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
  
  // Task 4: Field untuk sinkronisasi
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

  // Method copyWith untuk memudahkan update data
  LogModel copyWith({
    String? title,
    String? description,
    String? category,
    bool? isSynced,
    bool? isPublic, // Tambahkan di copyWith
  }) {
    return LogModel(
      id: this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      username: this.username,
      timestamp: this.timestamp,
      isSynced: isSynced ?? this.isSynced,
      isPublic: isPublic ?? this.isPublic, // Update isPublic
    );
  }

  // Konversi dari JSON (MongoDB)
  factory LogModel.fromJson(Map<String, dynamic> json) {
    return LogModel(
      id: json['_id'] is String ? json['_id'] : json['_id'].toHexString(),
      title: json['title'],
      description: json['description'],
      category: json['category'],
      username: json['username'],
      timestamp: json['timestamp'],
      isSynced: true, // Data dari Cloud sudah pasti tersinkron
      isPublic: json['isPublic'] ?? false, // Parsing field isPublic
    );
  }

  // Konversi ke JSON (MongoDB)
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'category': category,
      'username': username,
      'timestamp': timestamp,
      'isPublic': isPublic, // Simpan status publikasi ke Cloud
    };
  }
}