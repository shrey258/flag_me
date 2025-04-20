
class WishListItem {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final String store;
  final double rating;
  final String occasionId;
  final DateTime dateAdded;
  final String? notes;

  WishListItem({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.store,
    required this.rating,
    required this.occasionId,
    required this.dateAdded,
    this.notes,
  });

  factory WishListItem.fromJson(Map<String, dynamic> json) {
    return WishListItem(
      id: json['id'] as String,
      name: json['name'] as String,
      price: json['price'] as double,
      imageUrl: json['imageUrl'] as String,
      store: json['store'] as String,
      rating: json['rating'] as double,
      occasionId: json['occasionId'] as String,
      dateAdded: DateTime.parse(json['dateAdded'] as String),
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
      'store': store,
      'rating': rating,
      'occasionId': occasionId,
      'dateAdded': dateAdded.toIso8601String(),
      'notes': notes,
    };
  }

  WishListItem copyWith({
    String? id,
    String? name,
    double? price,
    String? imageUrl,
    String? store,
    double? rating,
    String? occasionId,
    DateTime? dateAdded,
    String? notes,
  }) {
    return WishListItem(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      store: store ?? this.store,
      rating: rating ?? this.rating,
      occasionId: occasionId ?? this.occasionId,
      dateAdded: dateAdded ?? this.dateAdded,
      notes: notes ?? this.notes,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WishListItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
