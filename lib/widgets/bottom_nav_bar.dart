import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/navigation_provider.dart';

class BottomNavBar extends ConsumerWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSection = ref.watch(navigationProvider);
    final items = ref.watch(navigationItemsProvider);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: items.map((item) {
              final isSelected = currentSection == item.section;
              return _NavBarItem(
                icon: item.icon,
                label: item.label,
                isSelected: isSelected,
                onTap: () {
                  ref.read(navigationProvider.notifier).navigate(item.section);
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatefulWidget {
  final String icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_NavBarItem> createState() => _NavBarItemState();
}

class _NavBarItemState extends State<_NavBarItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  IconData _getIconData() {
    switch (widget.icon) {
      case 'home':
        return widget.isSelected ? Icons.home : Icons.home_outlined;
      case 'card_giftcard':
        return widget.isSelected ? Icons.card_giftcard : Icons.card_giftcard_outlined;
      case 'search':
        return widget.isSelected ? Icons.search : Icons.search_outlined;
      case 'settings':
        return widget.isSelected ? Icons.settings : Icons.settings_outlined;
      default:
        return Icons.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getIconData(),
                color: widget.isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey[600],
                size: 22,
              ),
              const SizedBox(height: 2),
              Text(
                widget.label,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight:
                      widget.isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: widget.isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
