import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/enums.dart';

final sampleProductsProvider = Provider<List<Map<String, dynamic>>>((ref) => [
  // Electronics
  {
    'name': 'Apple AirPods Pro (2nd Generation)',
    'price': 249.99,
    'rating': 4.8,
    'store': 'Amazon',
    'category': GiftCategory.electronics,
    'image': 'https://images.unsplash.com/photo-1588156979435-379b9d802b0a?w=800&auto=format&fit=crop&q=60&ixlib=rb-4.0.3',
  },
  {
    'name': 'Kindle Paperwhite Signature Edition',
    'price': 189.99,
    'rating': 4.7,
    'store': 'Amazon',
    'category': GiftCategory.electronics,
    'image': 'https://images.unsplash.com/photo-1592434134753-a70f1a7b2f38?w=800&auto=format&fit=crop&q=60&ixlib=rb-4.0.3',
  },
  // Books & Stationery
  {
    'name': 'Premium Leather Journal',
    'price': 35.99,
    'rating': 4.6,
    'store': 'Barnes & Noble',
    'category': GiftCategory.stationery,
    'image': 'https://images.unsplash.com/photo-1577375729152-4c8b5fcda381',
  },
  {
    'name': 'Mont Blanc Fountain Pen',
    'price': 299.99,
    'rating': 4.9,
    'store': 'Mont Blanc',
    'category': GiftCategory.stationery,
    'image': 'https://images.unsplash.com/photo-1579723985163-28f30af7093b',
  },
  // Watches
  {
    'name': 'Fossil Gen 6 Smartwatch',
    'price': 299.00,
    'rating': 4.5,
    'store': 'Fossil',
    'category': GiftCategory.watches,
    'image': 'https://images.unsplash.com/photo-1523275335684-37898b6baf30',
  },
  // Home Decor
  {
    'name': 'Handcrafted Ceramic Vase Set',
    'price': 89.99,
    'rating': 4.7,
    'store': 'Pottery Barn',
    'category': GiftCategory.homeDecor,
    'image': 'https://images.unsplash.com/photo-1578500494198-246f612d3b3d',
  },
  // Fashion
  {
    'name': 'Premium Leather Wallet',
    'price': 79.99,
    'rating': 4.6,
    'store': 'Nordstrom',
    'category': GiftCategory.fashionAccessories,
    'image': 'https://images.unsplash.com/photo-1627123424574-724758594e93',
  },
  // Jewelry
  {
    'name': 'Sterling Silver Necklace',
    'price': 129.99,
    'rating': 4.8,
    'store': 'Tiffany & Co',
    'category': GiftCategory.jewelry,
    'image': 'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338',
  },
  // Kitchen
  {
    'name': 'Smart Coffee Maker',
    'price': 199.99,
    'rating': 4.5,
    'store': 'Williams Sonoma',
    'category': GiftCategory.kitchenAppliances,
    'image': 'https://images.unsplash.com/photo-1520970014086-2208d157c9e2',
  },
  // Experience Gifts
  {
    'name': 'Spa Day Package',
    'price': 150.00,
    'rating': 4.9,
    'store': 'Spa & Wellness',
    'category': GiftCategory.experienceGifts,
    'image': 'https://images.unsplash.com/photo-1544161515-4ab6ce6db874',
  },
]);

final filterProvider = StateProvider<Set<String>>((ref) => {});

final filteredProductsProvider = Provider<List<Map<String, dynamic>>>((ref) {
  final products = ref.watch(sampleProductsProvider);
  final filters = ref.watch(filterProvider);
  
  if (filters.isEmpty) return products;
  
  return products.where((product) {
    for (final filter in filters) {
      switch (filter) {
        case 'Price: \$0-50':
          if (product['price'] > 50) return false;
          break;
        case 'Price: \$51-100':
          if (product['price'] < 51 || product['price'] > 100) return false;
          break;
        case 'Price: \$101+':
          if (product['price'] <= 100) return false;
          break;
        case 'Rating: 4★+':
          if (product['rating'] < 4.0) return false;
          break;
        case 'Free Shipping':
          if (product['freeShipping'] != true) return false;
          break;
      }
    }
    return true;
  }).toList();
});

final categoryFilterProvider = StateProvider<Set<GiftCategory>>((ref) => {});

final priceRangeProvider = StateProvider<RangeValues>((ref) => const RangeValues(0, 1000));

final productsByCategoryProvider = Provider.family<List<Map<String, dynamic>>, GiftCategory>((ref, category) {
  final products = ref.watch(sampleProductsProvider);
  return products.where((product) => product['category'] == category).toList();
});

final productsByPriceRangeProvider = Provider<List<Map<String, dynamic>>>((ref) {
  final products = ref.watch(sampleProductsProvider);
  final priceRange = ref.watch(priceRangeProvider);
  
  return products.where((product) {
    final price = product['price'] as double;
    return price >= priceRange.start && price <= priceRange.end;
  }).toList();
});
