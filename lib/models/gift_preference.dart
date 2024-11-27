import 'package:flutter/foundation.dart';
import 'enums.dart';

class GiftPreference {
  final String id;
  final String occasionId;
  final RelationType relationType;
  final double minBudget;
  final double maxBudget;
  final List<String> preferredColors;
  final Map<String, String> sizes; // e.g., {'clothes': 'M', 'shoes': '42'}
  final List<String> interests;
  final List<GiftCategory> selectedCategories;
  final List<GiftCategory> excludedCategories;
  final DateTime lastUpdated;

  GiftPreference({
    required this.id,
    required this.occasionId,
    required this.relationType,
    required this.minBudget,
    required this.maxBudget,
    required this.preferredColors,
    required this.sizes,
    required this.interests,
    required this.selectedCategories,
    required this.excludedCategories,
    required this.lastUpdated,
  });

  factory GiftPreference.fromJson(Map<String, dynamic> json) {
    return GiftPreference(
      id: json['id'] as String,
      occasionId: json['occasionId'] as String,
      relationType: RelationType.values.firstWhere(
        (e) => e.toString() == 'RelationType.${json['relationType']}',
      ),
      minBudget: json['minBudget'] as double,
      maxBudget: json['maxBudget'] as double,
      preferredColors: List<String>.from(json['preferredColors']),
      sizes: Map<String, String>.from(json['sizes']),
      interests: List<String>.from(json['interests']),
      selectedCategories: (json['selectedCategories'] as List<dynamic>)
          .map((e) => GiftCategory.values.firstWhere(
                (cat) => cat.toString() == 'GiftCategory.$e',
              ))
          .toList(),
      excludedCategories: (json['excludedCategories'] as List<dynamic>)
          .map((e) => GiftCategory.values.firstWhere(
                (cat) => cat.toString() == 'GiftCategory.$e',
              ))
          .toList(),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'occasionId': occasionId,
      'relationType': relationType.toString().split('.').last,
      'minBudget': minBudget,
      'maxBudget': maxBudget,
      'preferredColors': preferredColors,
      'sizes': sizes,
      'interests': interests,
      'selectedCategories':
          selectedCategories.map((e) => e.toString().split('.').last).toList(),
      'excludedCategories':
          excludedCategories.map((e) => e.toString().split('.').last).toList(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  GiftPreference copyWith({
    String? id,
    String? occasionId,
    RelationType? relationType,
    double? minBudget,
    double? maxBudget,
    List<String>? preferredColors,
    Map<String, String>? sizes,
    List<String>? interests,
    List<GiftCategory>? selectedCategories,
    List<GiftCategory>? excludedCategories,
    DateTime? lastUpdated,
  }) {
    return GiftPreference(
      id: id ?? this.id,
      occasionId: occasionId ?? this.occasionId,
      relationType: relationType ?? this.relationType,
      minBudget: minBudget ?? this.minBudget,
      maxBudget: maxBudget ?? this.maxBudget,
      preferredColors: preferredColors ?? this.preferredColors,
      sizes: sizes ?? this.sizes,
      interests: interests ?? this.interests,
      selectedCategories: selectedCategories ?? this.selectedCategories,
      excludedCategories: excludedCategories ?? this.excludedCategories,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  static List<String> getCommonColors() {
    return [
      'Red',
      'Blue',
      'Green',
      'Black',
      'White',
      'Navy',
      'Purple',
      'Pink',
      'Yellow',
      'Gray',
      'Brown',
      'Orange',
    ];
  }

  static Map<String, List<String>> getSizeCategories() {
    return {
      'Clothing': ['XS', 'S', 'M', 'L', 'XL', 'XXL', '3XL'],
      'Shoes': ['36', '37', '38', '39', '40', '41', '42', '43', '44', '45', '46'],
      'Rings': ['5', '6', '7', '8', '9', '10', '11', '12', '13'],
    };
  }
}
