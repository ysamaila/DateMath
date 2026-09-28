class HistoryItem {
  final String id;
  final String toolName;
  final String category;
  final String title;
  final String resultSummary;
  final DateTime timestamp;
  final bool isFavorite;

  const HistoryItem({
    required this.id,
    required this.toolName,
    required this.category,
    required this.title,
    required this.resultSummary,
    required this.timestamp,
    this.isFavorite = false,
  });

  HistoryItem copyWith({
    String? id,
    String? toolName,
    String? category,
    String? title,
    String? resultSummary,
    DateTime? timestamp,
    bool? isFavorite,
  }) {
    return HistoryItem(
      id: id ?? this.id,
      toolName: toolName ?? this.toolName,
      category: category ?? this.category,
      title: title ?? this.title,
      resultSummary: resultSummary ?? this.resultSummary,
      timestamp: timestamp ?? this.timestamp,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'toolName': toolName,
        'category': category,
        'title': title,
        'resultSummary': resultSummary,
        'timestamp': timestamp.toIso8601String(),
        'isFavorite': isFavorite,
      };

  factory HistoryItem.fromJson(Map<String, dynamic> json) => HistoryItem(
        id: json['id'] as String,
        toolName: json['toolName'] as String,
        category: json['category'] as String? ?? 'General',
        title: json['title'] as String,
        resultSummary: json['resultSummary'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        isFavorite: json['isFavorite'] as bool? ?? false,
      );
}
