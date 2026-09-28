class CustomHoliday {
  final String id;
  final String name;
  final DateTime date;
  final bool isRecurringYearly;

  const CustomHoliday({
    required this.id,
    required this.name,
    required this.date,
    this.isRecurringYearly = true,
  });

  bool matchesDate(DateTime targetDate) {
    if (isRecurringYearly) {
      return targetDate.month == date.month && targetDate.day == date.day;
    }
    return targetDate.year == date.year &&
        targetDate.month == date.month &&
        targetDate.day == date.day;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'date': date.toIso8601String(),
        'isRecurringYearly': isRecurringYearly,
      };

  factory CustomHoliday.fromJson(Map<String, dynamic> json) => CustomHoliday(
        id: json['id'] as String,
        name: json['name'] as String,
        date: DateTime.parse(json['date'] as String),
        isRecurringYearly: json['isRecurringYearly'] as bool? ?? true,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomHoliday &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          date.year == other.date.year &&
          date.month == other.date.month &&
          date.day == other.date.day &&
          isRecurringYearly == other.isRecurringYearly;

  @override
  int get hashCode =>
      id.hashCode ^ name.hashCode ^ date.hashCode ^ isRecurringYearly.hashCode;
}
