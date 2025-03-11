class Product {
  final String title;
  final double price;
  final String url;
  final String platform;
  final String? imageUrl;

  Product({
    required this.title,
    required this.price,
    required this.url,
    required this.platform,
    this.imageUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      title: json['title'],
      price: json['price'].toDouble(),
      url: json['url'],
      platform: json['platform'],
      imageUrl: json['image_url'],
    );
  }
}

class ProductSearchRequest {
  final String query;

  ProductSearchRequest({required this.query});

  Map<String, dynamic> toJson() => {
        'query': query,
      };
}

class ProductSearchResponse {
  final List<Product> products;

  ProductSearchResponse({required this.products});

  factory ProductSearchResponse.fromJson(Map<String, dynamic> json) {
    return ProductSearchResponse(
      products: List<Product>.from(
          json['products'].map((x) => Product.fromJson(x))),
    );
  }
}
