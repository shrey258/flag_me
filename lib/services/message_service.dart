import 'dart:convert';
import 'package:http/http.dart' as http;

class MessageService {
  static const String baseUrl = 'http://172.20.10.9:8000';

  Future<String> generateMessage({
    required String name,
    required int age,
    required String occasion,
    required String gender,
    required String relationship,
    required int length,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/generate-message'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'age': age,
          'occasion': occasion,
          'gender': gender,
          'relationship': relationship,
          'length': length,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['message'];
      } else {
        throw Exception('Failed to generate message: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error generating message: $e');
    }
  }
}
