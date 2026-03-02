import 'package:mongo_dart/mongo_dart.dart';

class LogModel {
  final ObjectId id; 
  final String title;
  final String description;
  final String category;
  final String timestamp;
  final String username; 

  LogModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.timestamp,
    required this.username,
  });

  // Konversi dari Object ke JSON untuk dikirim ke Cloud
  Map<String, dynamic> toJson() => {
        '_id': id,
        'title': title,
        'description': description,
        'category': category,
        'timestamp': timestamp,
        'username': username,
      };

  // Konversi dari JSON (Atlas) ke Object Flutter
  factory LogModel.fromJson(Map<String, dynamic> json) => LogModel(
        id: json['_id'] as ObjectId,
        title: json['title'] ?? '',
        description: json['description'] ?? '',
        category: json['category'] ?? 'Pribadi',
        timestamp: json['timestamp'] ?? '',
        username: json['username'] ?? '',
      );
}