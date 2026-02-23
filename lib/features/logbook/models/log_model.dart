class LogModel {
  String title;
  String description;
  String timestamp;

  LogModel({
    required this.title,
    required this.description,
    required this.timestamp,
  });

  // --- Task 4: JSON Serialization ---

  /// Mengonversi Map (JSON) kembali menjadi Object LogModel.
  factory LogModel.fromMap(Map<String, dynamic> map) {
    return LogModel(
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      timestamp: map['timestamp'] ?? '',
    );
  }

  /// Mengonversi Object LogModel menjadi Map (JSON).
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'timestamp': timestamp,
    };
  }

  // --- Helper Method ---

  /// Fungsi copyWith memudahkan kita jika ingin mengupdate satu field saja 
  LogModel copyWith({
    String? title,
    String? description,
    String? timestamp,
  }) {
    return LogModel(
      title: title ?? this.title,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}