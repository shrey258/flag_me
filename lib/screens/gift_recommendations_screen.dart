import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/enums.dart';
import '../utils/responsive_helper.dart';
import '../providers/gift_recommendations_provider.dart';
import '../widgets/loading_overlay.dart';
import '../widgets/search_bar.dart';
import '../widgets/product_card.dart';

class GiftRecommendationsScreen extends ConsumerStatefulWidget {
  final String occasionId;
  final RelationType relationType;

  const GiftRecommendationsScreen({
    super.key,
    required this.occasionId,
    required this.relationType,
  });

  @override
  ConsumerState<GiftRecommendationsScreen> createState() =>
      _GiftRecommendationsScreenState();
}

class _GiftRecommendationsScreenState
    extends ConsumerState<GiftRecommendationsScreen>
    with SingleTickerProviderStateMixin {
  String _searchQuery = '';
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => FilterBottomSheet(
        filters: const [
          'Price: \$0-50',
          'Price: \$51-100',
          'Price: \$101+',
          'Rating: 4★+',
          'Free Shipping',
        ],
        selectedFilters: ref.watch(filterProvider),
        onFilterToggle: (filter) {
          ref.read(filterProvider.notifier).update((state) {
            final newState = Set<String>.from(state);
            if (newState.contains(filter)) {
              newState.remove(filter);
            } else {
              newState.add(filter);
            }
            return newState;
          });
        },
        onApply: () => Navigator.pop(context),
        onReset: () {
          ref.read(filterProvider.notifier).state = {};
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(filteredProductsProvider);
    final filteredProducts = products.where((product) {
      return product['name']
              .toString()
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          product['store']
              .toString()
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());
    }).toList();

    return LoadingOverlay(
      isLoading: _isLoading,
      message: 'Loading recommendations...',
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: CustomScrollView(
          slivers: [
            SliverAppBar.large(
              floating: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'Gift Recommendations',
                  style: GoogleFonts.poppins(
                    color: Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: ResponsiveHelper.getScreenPadding(context),
              sliver: SliverToBoxAdapter(
                child: Column(
                  children: [
                    CustomSearchBar(
                      hint: 'Search gifts...',
                      onSearch: (query) {
                        setState(() {
                          _searchQuery = query;
                        });
                      },
                      onFilterTap: _showFilterOptions,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            if (filteredProducts.isEmpty)
              SliverFillRemaining(
                child: _buildEmptyState(context),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: ResponsiveHelper.isMobile(context) ? 2 : 3,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return FadeTransition(
                        opacity: _fadeAnimation,
                        child: ProductCard(
                          product: filteredProducts[index],
                          occasionId: widget.occasionId,
                        ),
                      );
                    },
                    childCount: filteredProducts.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'No recommendations found',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters or search query',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
