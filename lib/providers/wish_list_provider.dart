import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/wish_list_item.dart';

enum WishListSort {
  dateAdded,
  priceHighToLow,
  priceLowToHigh,
  rating,
}

class WishListNotifier extends StateNotifier<List<WishListItem>> {
  WishListNotifier() : super([]);

  void addItem(WishListItem item) {
    if (!state.contains(item)) {
      state = [...state, item];
      _persistData();
    }
  }

  void removeItem(String id) {
    state = state.where((item) => item.id != id).toList();
    _persistData();
  }

  void updateItem(WishListItem updatedItem) {
    state = state.map((item) {
      if (item.id == updatedItem.id) {
        return updatedItem;
      }
      return item;
    }).toList();
    _persistData();
  }

  void updateNotes(String itemId, String notes) {
    state = state.map((item) {
      if (item.id == itemId) {
        return item.copyWith(notes: notes);
      }
      return item;
    }).toList();
    _persistData();
  }

  List<WishListItem> getItemsByOccasion(String occasionId) {
    return state.where((item) => item.occasionId == occasionId).toList();
  }

  void sortItems(WishListSort sortType) {
    final sortedItems = List<WishListItem>.from(state);
    switch (sortType) {
      case WishListSort.dateAdded:
        sortedItems.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
        break;
      case WishListSort.priceHighToLow:
        sortedItems.sort((a, b) => b.price.compareTo(a.price));
        break;
      case WishListSort.priceLowToHigh:
        sortedItems.sort((a, b) => a.price.compareTo(b.price));
        break;
      case WishListSort.rating:
        sortedItems.sort((a, b) => b.rating.compareTo(a.rating));
        break;
    }
    state = sortedItems;
  }

  double getTotalValue() {
    return state.fold(0, (sum, item) => sum + item.price);
  }

  void _persistData() {
    // TODO: Implement local storage persistence
    // This will be implemented when we add local storage functionality
  }

  void loadPersistedData() {
    // TODO: Implement loading from local storage
    // This will be implemented when we add local storage functionality
  }
}

final wishListProvider =
    StateNotifierProvider<WishListNotifier, List<WishListItem>>((ref) {
  return WishListNotifier();
});

final wishListSortProvider = StateProvider<WishListSort>((ref) {
  return WishListSort.dateAdded;
});

final filteredWishListProvider = Provider<List<WishListItem>>((ref) {
  final items = ref.watch(wishListProvider);
  final sortType = ref.watch(wishListSortProvider);
  
  final sortedItems = List<WishListItem>.from(items);
  
  switch (sortType) {
    case WishListSort.dateAdded:
      sortedItems.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
      break;
    case WishListSort.priceHighToLow:
      sortedItems.sort((a, b) => b.price.compareTo(a.price));
      break;
    case WishListSort.priceLowToHigh:
      sortedItems.sort((a, b) => a.price.compareTo(b.price));
      break;
    case WishListSort.rating:
      sortedItems.sort((a, b) => b.rating.compareTo(a.rating));
      break;
  }
  
  return sortedItems;
});

final wishListByOccasionProvider =
    Provider.family<List<WishListItem>, String>((ref, occasionId) {
  final items = ref.watch(wishListProvider);
  return items.where((item) => item.occasionId == occasionId).toList();
});

final wishListTotalValueProvider = Provider<double>((ref) {
  final items = ref.watch(wishListProvider);
  return items.fold(0, (sum, item) => sum + item.price);
});

final wishListItemCountProvider = Provider<int>((ref) {
  return ref.watch(wishListProvider).length;
});
