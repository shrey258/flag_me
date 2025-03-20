import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/gift_service.dart';
import '../utils/responsive_helper.dart';

class ProductSearchScreen extends StatefulWidget {
  final String? searchQuery;

  const ProductSearchScreen({
    super.key,
    this.searchQuery,
  });

  @override
  State<ProductSearchScreen> createState() => _ProductSearchScreenState();
}

class _ProductSearchScreenState extends State<ProductSearchScreen> {
  bool _isLoading = false;
  List<ProductSearchResult> _products = [];
  final GiftService _giftService = GiftService();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.searchQuery != null) {
      _searchController.text = widget.searchQuery!;
      _searchProducts();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchProducts() async {
    if (_searchController.text.trim().isEmpty) return;
    
    setState(() => _isLoading = true);
    try {
      final products = await _giftService.searchProducts(_searchController.text);
      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open $url')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSmallScreen = ResponsiveHelper.isMobile(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            floating: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Product Search',
                style: GoogleFonts.poppins(
                  color: theme.colorScheme.secondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withOpacity(0.08),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search,
                          color: theme.colorScheme.secondary.withOpacity(0.7),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            style: GoogleFonts.inter(
                              color: theme.colorScheme.secondary,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Search for products...',
                              hintStyle: GoogleFonts.inter(
                                color: theme.colorScheme.secondary.withOpacity(0.5),
                              ),
                              border: InputBorder.none,
                            ),
                            onSubmitted: (_) => _searchProducts(),
                          ),
                        ),
                        if (_searchController.text.isNotEmpty)
                          IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: theme.colorScheme.secondary.withOpacity(0.7),
                            ),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Search Results',
                    style: GoogleFonts.poppins(
                      fontSize: isSmallScreen ? 20 : 24,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_products.isEmpty && _searchController.text.isNotEmpty)
            SliverFillRemaining(
              child: Center(
                child: Text(
                  'No products found for "${_searchController.text}"',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else if (_products.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search,
                      size: 64,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Enter a search term to find products',
                      style: theme.textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isSmallScreen ? 1 : 2,
                  mainAxisSpacing: 16.0,
                  crossAxisSpacing: 16.0,
                  childAspectRatio: isSmallScreen ? 1.5 : 1.2,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final product = _products[index];
                    return _buildProductCard(theme, product);
                  },
                  childCount: _products.length,
                ),
              ),
            ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
        ],
      ),
    );
  }

  Widget _buildProductCard(ThemeData theme, ProductSearchResult product) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
            spreadRadius: 4,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _launchUrl(product.url),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (product.imageUrl != null)
                  Expanded(
                    flex: 3,
                    child: Image.network(
                      product.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Center(
                        child: Icon(Icons.image_not_supported),
                      ),
                    ),
                  ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.title,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.secondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        Text(
                          product.platform,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
