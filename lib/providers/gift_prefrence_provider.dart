import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/gift_preference.dart';

class GiftPreferenceNotifier extends StateNotifier<List<GiftPreference>> {
  GiftPreferenceNotifier() : super([]);

  void savePreference(GiftPreference preference) {
    state = [...state, preference];
    // TODO: Implement API call to save preference
  }

  GiftPreference? getPreferenceByOccasionId(String occasionId) {
    try {
      return state.firstWhere((pref) => pref.occasion == occasionId);
    } catch (e) {
      return null;
    }
  }
}

final giftPreferenceProvider =
    StateNotifierProvider<GiftPreferenceNotifier, List<GiftPreference>>((ref) {
  return GiftPreferenceNotifier();
});

final preferenceByOccasionProvider = Provider.family<GiftPreference?, String>(
  (ref, occasionId) {
    final preferences = ref.watch(giftPreferenceProvider);
    try {
      return preferences.firstWhere((pref) => pref.occasion == occasionId);
    } catch (e) {
      return null;
    }
  },
);