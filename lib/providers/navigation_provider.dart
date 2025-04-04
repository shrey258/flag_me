import 'package:flutter_riverpod/flutter_riverpod.dart';

enum NavigationSection {
  home,
  productSearch,
  giftPreferences,
  messageGenerator,
  settings,
}

class NavigationNotifier extends StateNotifier<NavigationSection> {
  NavigationNotifier() : super(NavigationSection.home);

  void navigate(NavigationSection section) {
    state = section;
  }
}

final navigationProvider =
    StateNotifierProvider<NavigationNotifier, NavigationSection>((ref) {
  return NavigationNotifier();
});

final navigationLabelProvider = Provider<String>((ref) {
  final section = ref.watch(navigationProvider);
  switch (section) {
    case NavigationSection.home:
      return 'Home';
    case NavigationSection.productSearch:
      return 'Product Search';
    case NavigationSection.giftPreferences:
      return 'Gift Preferences';
    case NavigationSection.messageGenerator:
      return 'Message Generator';
    case NavigationSection.settings:
      return 'Settings';
  }
});

final navigationIconProvider = Provider<({String icon, String label})>((ref) {
  final section = ref.watch(navigationProvider);
  switch (section) {
    case NavigationSection.home:
      return (icon: 'home', label: 'Home');
    case NavigationSection.productSearch:
      return (icon: 'search', label: 'Product Search');
    case NavigationSection.giftPreferences:
      return (icon: 'card_giftcard', label: 'Gift Preferences');
    case NavigationSection.messageGenerator:
      return (icon: 'message', label: 'Message Generator');
    case NavigationSection.settings:
      return (icon: 'settings', label: 'Settings');
  }
});

final navigationItemsProvider = Provider<List<({
  NavigationSection section,
  String icon,
  String label,
})>>((ref) {
  return [
    (
      section: NavigationSection.home,
      icon: 'home',
      label: 'Home',
    ),
    (
      section: NavigationSection.productSearch,
      icon: 'search',
      label: 'Product Search',
    ),
    (
      section: NavigationSection.giftPreferences,
      icon: 'card_giftcard',
      label: 'Gift Preferences',
    ),
    (
      section: NavigationSection.messageGenerator,
      icon: 'message',
      label: 'Message Generator',
    ),
    (
      section: NavigationSection.settings,
      icon: 'settings',
      label: 'Settings',
    ),
  ];
});
