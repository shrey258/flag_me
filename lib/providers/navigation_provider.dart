import 'package:flutter_riverpod/flutter_riverpod.dart';

enum NavigationSection {
  home,
  wishList,
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
    case NavigationSection.wishList:
      return 'Wish List';
    case NavigationSection.settings:
      return 'Settings';
  }
});

final navigationIconProvider = Provider<({String icon, String label})>((ref) {
  final section = ref.watch(navigationProvider);
  switch (section) {
    case NavigationSection.home:
      return (icon: 'home', label: 'Home');
    case NavigationSection.wishList:
      return (icon: 'favorite', label: 'Wish List');
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
      section: NavigationSection.wishList,
      icon: 'favorite',
      label: 'Wish List',
    ),
    (
      section: NavigationSection.settings,
      icon: 'settings',
      label: 'Settings',
    ),
  ];
});
