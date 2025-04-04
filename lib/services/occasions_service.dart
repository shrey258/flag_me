import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/occasion.dart';
import '../models/reminder.dart';
import '../models/enums.dart';

final occasionsServiceProvider = Provider<OccasionsService>((ref) => OccasionsService());

class OccasionsService {
  final _supabase = Supabase.instance.client;
  final String _tableName = 'occasions';

  // Create a new occasion in Supabase
  Future<Occasion> createOccasion(Occasion occasion) async {
    try {
      // Get the current user ID
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Convert camelCase to snake_case for Supabase
      final occasionData = {
        'id': occasion.id,
        'user_id': userId,
        'person_name': occasion.personName,
        'date': occasion.date.toIso8601String(),
        'relation_type': occasion.relationType.name,
        'description': occasion.description,
        'reminders': occasion.reminders.map((r) => r.toJson()).toList(),
        'created_at': DateTime.now().toIso8601String(),
      };

      print('Saving occasion data: $occasionData'); // Debug print

      // Insert the occasion into Supabase
      final response = await _supabase
          .from(_tableName)
          .insert(occasionData)
          .select()
          .single();

      print('Supabase response: $response'); // Debug print

      // Convert snake_case back to camelCase for Dart model
      return Occasion(
        id: response['id'],
        personName: response['person_name'],
        date: DateTime.parse(response['date']),
        relationType: _getRelationTypeFromString(response['relation_type']),
        description: response['description'],
        reminders: _parseReminders(response['reminders']),
      );
    } catch (e) {
      print('Error creating occasion: $e');
      throw Exception('Failed to create occasion: $e');
    }
  }

  // Get all occasions for the current user
  Future<List<Occasion>> getOccasions() async {
    try {
      // Get the current user ID
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Fetch occasions for the current user
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .order('date');

      print('Fetched occasions: $response'); // Debug print

      // Convert the response to a list of Occasion objects with manual mapping
      return response.map<Occasion>((json) => Occasion(
        id: json['id'],
        personName: json['person_name'],
        date: DateTime.parse(json['date']),
        relationType: _getRelationTypeFromString(json['relation_type']),
        description: json['description'],
        reminders: _parseReminders(json['reminders']),
      )).toList();
    } catch (e) {
      print('Error fetching occasions: $e');
      throw Exception('Failed to fetch occasions: $e');
    }
  }

  // Update an existing occasion
  Future<Occasion> updateOccasion(Occasion occasion) async {
    try {
      // Get the current user ID
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Convert camelCase to snake_case for Supabase
      final occasionData = {
        'person_name': occasion.personName,
        'date': occasion.date.toIso8601String(),
        'relation_type': occasion.relationType.name,
        'description': occasion.description,
        'reminders': occasion.reminders.map((r) => r.toJson()).toList(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Update the occasion in Supabase
      final response = await _supabase
          .from(_tableName)
          .update(occasionData)
          .eq('id', occasion.id)
          .eq('user_id', userId) // Ensure the user owns this occasion
          .select()
          .single();

      // Convert snake_case back to camelCase for Dart model
      return Occasion(
        id: response['id'],
        personName: response['person_name'],
        date: DateTime.parse(response['date']),
        relationType: _getRelationTypeFromString(response['relation_type']),
        description: response['description'],
        reminders: _parseReminders(response['reminders']),
      );
    } catch (e) {
      print('Error updating occasion: $e');
      throw Exception('Failed to update occasion: $e');
    }
  }

  // Delete an occasion
  Future<void> deleteOccasion(String occasionId) async {
    try {
      // Get the current user ID
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Delete the occasion from Supabase
      await _supabase
          .from(_tableName)
          .delete()
          .eq('id', occasionId)
          .eq('user_id', userId); // Ensure the user owns this occasion
    } catch (e) {
      print('Error deleting occasion: $e');
      throw Exception('Failed to delete occasion: $e');
    }
  }

  // Add a reminder to an occasion
  Future<Occasion> addReminder(String occasionId, Reminder reminder) async {
    try {
      // Get the current user ID
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // First, get the current occasion
      final occasionResponse = await _supabase
          .from(_tableName)
          .select()
          .eq('id', occasionId)
          .eq('user_id', userId)
          .single();

      // Convert to Occasion object with manual mapping
      final occasion = Occasion(
        id: occasionResponse['id'],
        personName: occasionResponse['person_name'],
        date: DateTime.parse(occasionResponse['date']),
        relationType: _getRelationTypeFromString(occasionResponse['relation_type']),
        description: occasionResponse['description'],
        reminders: _parseReminders(occasionResponse['reminders']),
      );

      // Add the new reminder
      final updatedReminders = [...occasion.reminders, reminder];

      // Update the occasion in Supabase
      final response = await _supabase
          .from(_tableName)
          .update({
            'reminders': updatedReminders.map((r) => r.toJson()).toList(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', occasionId)
          .eq('user_id', userId)
          .select()
          .single();

      // Return the updated occasion with manual mapping
      return Occasion(
        id: response['id'],
        personName: response['person_name'],
        date: DateTime.parse(response['date']),
        relationType: _getRelationTypeFromString(response['relation_type']),
        description: response['description'],
        reminders: _parseReminders(response['reminders']),
      );
    } catch (e) {
      print('Error adding reminder: $e');
      throw Exception('Failed to add reminder: $e');
    }
  }

  // Remove a reminder from an occasion
  Future<Occasion> removeReminder(String occasionId, String reminderId) async {
    try {
      // Get the current user ID
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // First, get the current occasion
      final occasionResponse = await _supabase
          .from(_tableName)
          .select()
          .eq('id', occasionId)
          .eq('user_id', userId)
          .single();

      // Convert to Occasion object with manual mapping
      final occasion = Occasion(
        id: occasionResponse['id'],
        personName: occasionResponse['person_name'],
        date: DateTime.parse(occasionResponse['date']),
        relationType: _getRelationTypeFromString(occasionResponse['relation_type']),
        description: occasionResponse['description'],
        reminders: _parseReminders(occasionResponse['reminders']),
      );

      // Remove the specified reminder
      final updatedReminders = occasion.reminders.where((r) => r.id != reminderId).toList();

      // Update the occasion in Supabase
      final response = await _supabase
          .from(_tableName)
          .update({
            'reminders': updatedReminders.map((r) => r.toJson()).toList(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', occasionId)
          .eq('user_id', userId)
          .select()
          .single();

      // Return the updated occasion with manual mapping
      return Occasion(
        id: response['id'],
        personName: response['person_name'],
        date: DateTime.parse(response['date']),
        relationType: _getRelationTypeFromString(response['relation_type']),
        description: response['description'],
        reminders: _parseReminders(response['reminders']),
      );
    } catch (e) {
      print('Error removing reminder: $e');
      throw Exception('Failed to remove reminder: $e');
    }
  }
  
  // Helper method to parse relation type from string
  RelationType _getRelationTypeFromString(String type) {
    switch (type.toLowerCase()) {
      case 'professional':
        return RelationType.professional;
      case 'personal':
        return RelationType.personal;
      case 'family':
        return RelationType.family;
      default:
        return RelationType.personal;
    }
  }

  // Helper method to parse reminders from JSON
  List<Reminder> _parseReminders(dynamic remindersJson) {
    if (remindersJson == null) return [];
    
    try {
      if (remindersJson is List) {
        return remindersJson
            .map<Reminder>((json) => Reminder.fromJson(json))
            .toList();
      }
    } catch (e) {
      print('Error parsing reminders: $e');
    }
    return [];
  }
}
