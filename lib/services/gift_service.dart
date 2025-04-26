import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/gift_preference.dart';
import '../models/gift_recommendation.dart';

class GiftService {
  static const String baseUrl = 'http://192.168.1.6:8000';
  final _supabase = Supabase.instance.client;
  static const String _tableName = 'gift_recommendations';

  Future<List<String>> getGiftSuggestions(GiftPreference preference, {String? occasionId}) async {
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
        final suggestions = List<String>.from(data['gift_suggestions']);
        
        // We no longer automatically save the first suggestion
        // The user will explicitly select which recommendation to save
        print('Retrieved ${suggestions.length} gift suggestions');
        return suggestions;
      } else {
        throw Exception('Failed to get gift suggestions: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting gift suggestions: $e');
    }
  }
  
  // Save a gift recommendation to Supabase
  Future<void> saveRecommendation(GiftRecommendation recommendation) async {
    try {
      print('Saving recommendation for occasion: ${recommendation.occasionId}');
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        print('User not authenticated when saving recommendation');
        throw Exception('User not authenticated');
      }
      print('User ID: $userId');

      // Convert camelCase to snake_case for Supabase
      final recommendationData = {
        'id': recommendation.id,
        'user_id': userId,
        'occasion_id': recommendation.occasionId, // This is already a UUID string
        'title': recommendation.title,
        'description': recommendation.description,
        'price': recommendation.price,
        'image_url': recommendation.imageUrl,
        'created_at': recommendation.createdAt.toIso8601String(),
      };
      
      print('Recommendation data to save: $recommendationData');

      print('Recommendation data: $recommendationData');
      await _supabase.from(_tableName).upsert(recommendationData);
      print('Recommendation saved successfully');
    } catch (e) {
      print('Failed to save recommendation: $e');
      throw Exception('Failed to save recommendation: $e');
    }
  }

  // Get the latest recommendation for an occasion
  Future<GiftRecommendation?> getLatestRecommendation(String occasionId) async {
    try {
      print('Getting latest recommendation for occasion: $occasionId');
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        print('User not authenticated when getting recommendation');
        throw Exception('User not authenticated');
      }
      print('User ID: $userId');

      // Print the query we're about to execute
      print('Executing query: SELECT * FROM $_tableName WHERE user_id = $userId AND occasion_id = $occasionId ORDER BY created_at DESC LIMIT 1');
      
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .eq('occasion_id', occasionId)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      print('Recommendation response: $response');
      if (response != null) {
        final recommendation = GiftRecommendation.fromJson(response);
        print('Found recommendation: ${recommendation.title}');
        return recommendation;
      }
      print('No recommendation found for occasion: $occasionId');
      return null;
    } catch (e) {
      // Just return null instead of throwing an exception
      print('Error getting latest recommendation: $e');
      return null;
    }
  }

  // This method was removed as it's no longer needed
  // We now generate IDs directly in the GiftRecommendationsScreen

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
