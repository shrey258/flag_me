import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/gift_preference.dart';

class GiftService {
  static const String baseUrl = 'http://192.168.190.182:8000';

  Future<List<String>> getGiftSuggestions(GiftPreference preference) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/gift-suggestions'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'person_details': preference.toJson(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<String>.from(data['gift_suggestions']);
      } else {
        throw Exception('Failed to get gift suggestions: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting gift suggestions: $e');
    }
  }

  Future<List<ProductSearchResult>> searchProducts(
    String query, {
    double? minPrice,
    double? maxPrice,
    List<String>? platforms,
  }) async {
    try {
      final Map<String, dynamic> requestBody = {
        'query': query,
      };

      if (minPrice != null) {
        requestBody['min_price'] = minPrice;
      }

      if (maxPrice != null) {
        requestBody['max_price'] = maxPrice;
      }

      if (platforms != null && platforms.isNotEmpty) {
        requestBody['platforms'] = platforms;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/search-products'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['products'] as List)
            .map((product) => ProductSearchResult(
                  title: product['title'],
                  price: product['price'].toDouble(),
                  url: product['url'],
                  platform: product['platform'],
                  imageUrl: product['image_url'],
                ))
            .toList();
      } else {
        throw Exception('Failed to search products: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error searching products: $e');
    }
  }
}

class ProductSearchResult {
  final String title;
  final double price;
  final String url;
  final String platform;
  final String? imageUrl;

  ProductSearchResult({
    required this.title,
    required this.price,
    required this.url,
    required this.platform,
    this.imageUrl,
  });
}
