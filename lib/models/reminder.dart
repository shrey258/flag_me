class Reminder {
  final String id;
  final DateTime date;
  final String occasionId;
  final bool isActive;

  Reminder({
    required this.id,
    required this.date,
    required this.occasionId,
    this.isActive = true,
  });

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      occasionId: json['occasionId'] as String,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'occasionId': occasionId,
      'isActive': isActive,
    };
  }

  Reminder copyWith({
    String? id,
    DateTime? date,
    String? occasionId,
    bool? isActive,
  }) {
    return Reminder(
      id: id ?? this.id,
      date: date ?? this.date,
      occasionId: occasionId ?? this.occasionId,
      isActive: isActive ?? this.isActive,
    );
  }
}
