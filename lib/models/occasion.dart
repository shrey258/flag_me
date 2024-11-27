import 'reminder.dart';
import 'enums.dart';

class Occasion {
  final String id;
  final String personName;
  final DateTime date;
  final RelationType relationType;
  final String description;
  final List<Reminder> reminders;

  Occasion({
    required this.id,
    required this.personName,
    required this.date,
    required this.relationType,
    required this.description,
    this.reminders = const [],
  });

  factory Occasion.fromJson(Map<String, dynamic> json) {
    return Occasion(
      id: json['id'] as String,
      personName: json['personName'] as String,
      date: DateTime.parse(json['date'] as String),
      relationType: RelationType.values.firstWhere(
        (e) => e.toString() == 'RelationType.${json['relationType']}',
      ),
      description: json['description'] as String,
      reminders: (json['reminders'] as List<dynamic>)
          .map((e) => Reminder.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'personName': personName,
      'date': date.toIso8601String(),
      'relationType': relationType.toString().split('.').last,
      'description': description,
      'reminders': reminders.map((e) => e.toJson()).toList(),
    };
  }

  Occasion copyWith({
    String? id,
    String? personName,
    DateTime? date,
    RelationType? relationType,
    String? description,
    List<Reminder>? reminders,
  }) {
    return Occasion(
      id: id ?? this.id,
      personName: personName ?? this.personName,
      date: date ?? this.date,
      relationType: relationType ?? this.relationType,
      description: description ?? this.description,
      reminders: reminders ?? this.reminders,
    );
  }
}
