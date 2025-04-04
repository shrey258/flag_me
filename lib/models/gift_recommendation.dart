

class GiftRecommendation {
  final String id;
  final String occasionId; // This is a UUID stored as String in Dart
  final String title;
  final String description;
  final double? price;
  final String? imageUrl;
  final DateTime createdAt;

  GiftRecommendation({
    required this.id,
    required this.occasionId,
    required this.title,
    required this.description,
    this.price,
    this.imageUrl,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'occasion_id': occasionId,
    'title': title,
    'description': description,
    'price': price,
    'image_url': imageUrl,
    'created_at': createdAt.toIso8601String(),
  };

  factory GiftRecommendation.fromJson(Map<String, dynamic> json) {
    print('Creating GiftRecommendation from JSON: $json');
    try {
      final recommendation = GiftRecommendation(
        id: json['id'] as String,
        occasionId: json['occasion_id'] as String,
        title: json['title'] as String,
        description: json['description'] ?? '',
        price: json['price'] != null ? (json['price'] as num).toDouble() : null,
        imageUrl: json['image_url'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
      print('Successfully created recommendation: ${recommendation.title}');
      return recommendation;
    } catch (e) {
      print('Error creating GiftRecommendation from JSON: $e');
      rethrow;
    }
  }
}
