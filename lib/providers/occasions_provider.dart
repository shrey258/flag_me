import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/reminder.dart';
import '../models/occasion.dart';
import '../services/occasions_service.dart';

class OccasionsNotifier extends StateNotifier<List<Occasion>> {
  final OccasionsService _occasionsService;
  
  OccasionsNotifier(this._occasionsService) : super([]) {
    // Load occasions when the provider is initialized
    _loadOccasions();
  }
  
  // Load occasions from Supabase
  Future<void> _loadOccasions() async {
    try {
      final occasions = await _occasionsService.getOccasions();
      state = occasions;
    } catch (e) {
      print('Error loading occasions: $e');
      // Keep the state empty if there's an error
    }
  }

  Future<void> addReminder(String occasionId, Reminder reminder) async {
    try {
      // First update locally for immediate UI feedback
      state = state.map((occasion) {
        if (occasion.id == occasionId) {
          return occasion.copyWith(
            reminders: [...occasion.reminders, reminder],
          );
        }
        return occasion;
      }).toList();
      
      // Then persist to Supabase
      await _occasionsService.addReminder(occasionId, reminder);
    } catch (e) {
      print('Error adding reminder: $e');
      // Reload occasions to ensure UI is in sync with backend
      await _loadOccasions();
    }
  }

  Future<void> removeReminder(String occasionId, String reminderId) async {
    try {
      // First update locally for immediate UI feedback
      state = state.map((occasion) {
        if (occasion.id == occasionId) {
          return occasion.copyWith(
            reminders: occasion.reminders
                .where((reminder) => reminder.id != reminderId)
                .toList(),
          );
        }
        return occasion;
      }).toList();
      
      // Then persist to Supabase
      await _occasionsService.removeReminder(occasionId, reminderId);
    } catch (e) {
      print('Error removing reminder: $e');
      // Reload occasions to ensure UI is in sync with backend
      await _loadOccasions();
    }
  }

  Future<void> addOccasion(Occasion occasion) async {
    try {
      print('Adding occasion: ${occasion.personName}'); // Debug print
      
      // First update locally for immediate UI feedback
      state = [...state, occasion];
      print('Current state length: ${state.length}'); // Debug print
      
      // Then persist to Supabase
      await _occasionsService.createOccasion(occasion);
    } catch (e) {
      print('Error adding occasion: $e');
      // Reload occasions to ensure UI is in sync with backend
      await _loadOccasions();
    }
  }

  Future<void> deleteOccasion(String id) async {
    try {
      // First update locally for immediate UI feedback
      state = state.where((occasion) => occasion.id != id).toList();
      
      // Then persist to Supabase
      await _occasionsService.deleteOccasion(id);
    } catch (e) {
      print('Error deleting occasion: $e');
      // Reload occasions to ensure UI is in sync with backend
      await _loadOccasions();
    }
  }

  Future<void> updateOccasion(Occasion occasion) async {
    try {
      // First update locally for immediate UI feedback
      state = state.map((o) => o.id == occasion.id ? occasion : o).toList();
      
      // Then persist to Supabase
      await _occasionsService.updateOccasion(occasion);
    } catch (e) {
      print('Error updating occasion: $e');
      // Reload occasions to ensure UI is in sync with backend
      await _loadOccasions();
    }
  }


  Occasion? getOccasionById(String id) {
    try {
      return state.firstWhere((occasion) => occasion.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Occasion> getUpcomingOccasions() {
    final now = DateTime.now();
    return state.where((occasion) => occasion.date.isAfter(now)).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }
}

final occasionsProvider =
    StateNotifierProvider<OccasionsNotifier, List<Occasion>>((ref) {
      final occasionsService = ref.watch(occasionsServiceProvider);
      return OccasionsNotifier(occasionsService);
    });

final upcomingOccasionsProvider = Provider<List<Occasion>>((ref) {
  final occasions = ref.watch(occasionsProvider);
  final now = DateTime.now();
  return occasions.where((occasion) => occasion.date.isAfter(now)).toList()
    ..sort((a, b) => a.date.compareTo(b.date));
});

final occasionByIdProvider = Provider.family<Occasion?, String>((ref, id) {
  final occasions = ref.watch(occasionsProvider);
  try {
    return occasions.firstWhere((occasion) => occasion.id == id);
  } catch (e) {
    return null;
  }
});
