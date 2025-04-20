import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/gift_service.dart';
import '../models/gift_preference.dart';

final giftServiceProvider = Provider((ref) => GiftService());

final giftSuggestionsProvider = FutureProvider.family<List<String>, GiftPreference>(
  (ref, preference) async {
    final giftService = ref.read(giftServiceProvider);
    return giftService.getGiftSuggestions(preference);
  },
);

final productSearchProvider = FutureProvider.family<List<ProductSearchResult>, String>(
  (ref, query) async {
    final giftService = ref.read(giftServiceProvider);
    return giftService.searchProducts(query);
  },
);
