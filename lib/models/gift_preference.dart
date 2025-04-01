import 'package:flutter/foundation.dart';
import 'enums.dart';

class GiftPreference {
  final int? age;
  final String? gender;
  final List<String> interests;
  final String? occasion;
  final String? budget;
  final double? minBudget;
  final double? maxBudget;
  final String? relationship;
  final String? additionalNotes;

  GiftPreference({
    this.age,
    this.gender,
    this.interests = const [],
    this.occasion,
    this.budget,
    this.minBudget,
    this.maxBudget,
    this.relationship,
    this.additionalNotes,
  });

  Map<String, dynamic> toJson() => {
    'age': age,
    'gender': gender,
    'interests': interests,
    'occasion': occasion,
    'budget': budget,
    'min_budget': minBudget,
    'max_budget': maxBudget,
    'relationship': relationship,
    'additional_notes': additionalNotes,
  };

  factory GiftPreference.fromJson(Map<String, dynamic> json) {
    return GiftPreference(
      age: json['age'] as int?,
      gender: json['gender'] as String?,
      interests: List<String>.from(json['interests'] ?? []),
      occasion: json['occasion'] as String?,
      budget: json['budget'] as String?,
      minBudget: json['min_budget'] != null ? (json['min_budget'] as num).toDouble() : null,
      maxBudget: json['max_budget'] != null ? (json['max_budget'] as num).toDouble() : null,
      relationship: json['relationship'] as String?,
      additionalNotes: json['additional_notes'] as String?,
    );
  }
}
