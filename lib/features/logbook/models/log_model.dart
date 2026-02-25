class LogModel {
  final String id;
  final String title;
  final String description;
  final String timestamp;
  final String category;

  LogModel({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    this.category = 'Umum',
  });

  factory LogModel.fromMap(Map<String, dynamic> map) {
    return LogModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      timestamp: map['timestamp'] ?? '',
      category: map['category'] ?? 'Umum',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'timestamp': timestamp,
      'category': category,
    };
  }

  LogModel copyWith({
    String? id,
    String? title,
    String? description,
    String? timestamp,
    String? category,
  }) {
    return LogModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      category: category ?? this.category,
    );
  }
}