import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/reminder.dart';
import '../models/occasion.dart';

class OccasionsNotifier extends StateNotifier<List<Occasion>> {
  OccasionsNotifier() : super([]);

  void addReminder(String occasionId, Reminder reminder) {
    state =
        state.map((occasion) {
          if (occasion.id == occasionId) {
            return Occasion(
              id: occasion.id,
              personName: occasion.personName,
              date: occasion.date,
              relationType: occasion.relationType,
              description: occasion.description,
              reminders: [...occasion.reminders, reminder],
            );
          }
          return occasion;
        }).toList();
  }

  void removeReminder(String occasionId, String reminderId) {
    state =
        state.map((occasion) {
          if (occasion.id == occasionId) {
            return Occasion(
              id: occasion.id,
              personName: occasion.personName,
              date: occasion.date,
              relationType: occasion.relationType,
              description: occasion.description,
              reminders:
                  occasion.reminders
                      .where((reminder) => reminder.id != reminderId)
                      .toList(),
            );
          }
          return occasion;
        }).toList();
  }

   void addOccasion(Occasion occasion) {
    print('Adding occasion: ${occasion.personName}'); // Debug print
    state = [...state, occasion];
    print('Current state length: ${state.length}'); // Debug print
  }

  void deleteOccasion(String id) {
    state = state.where((occasion) => occasion.id != id).toList();
  }

  void updateOccasion(Occasion occasion) {
    state = state.map((o) => o.id == occasion.id ? occasion : o).toList();
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
      return OccasionsNotifier();
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
