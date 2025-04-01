import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/gift_service.dart';
import '../utils/responsive_helper.dart';

class ProductSearchScreen extends StatefulWidget {
  final String? searchQuery;
  final double? minBudget;
  final double? maxBudget;

  const ProductSearchScreen({
    super.key,
    this.searchQuery,
    this.minBudget,
    this.maxBudget,
  });

  @override
  State<ProductSearchScreen> createState() => _ProductSearchScreenState();
}

class _ProductSearchScreenState extends State<ProductSearchScreen> {
  bool _isLoading = false;
  List<ProductSearchResult> _products = [];
  final GiftService _giftService = GiftService();
  final _searchController = TextEditingController();
  
  // Budget range values
  RangeValues? _budgetRange;
  static const double _minBudgetValue = 0;
  static const double _maxBudgetValue = 500000;
  bool _showBudgetFilter = false;
  
  // Text controllers for manual budget entry
  final TextEditingController _minBudgetController = TextEditingController();
  final TextEditingController _maxBudgetController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.minBudget != null && widget.maxBudget != null) {
      _budgetRange = RangeValues(widget.minBudget!, widget.maxBudget!);
      _minBudgetController.text = widget.minBudget!.toInt().toString();
      _maxBudgetController.text = widget.maxBudget!.toInt().toString();
      _showBudgetFilter = true;
    } else {
      _budgetRange = const RangeValues(1000, 5000);
      _minBudgetController.text = '1000';
      _maxBudgetController.text = '5000';
    }
    
    if (widget.searchQuery != null) {
      _searchController.text = widget.searchQuery!;
      _searchProducts();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _minBudgetController.dispose();
    _maxBudgetController.dispose();
    super.dispose();
  }

  Future<void> _searchProducts() async {
    if (_searchController.text.trim().isEmpty) return;
    
    setState(() => _isLoading = true);
    try {
      final products = await _giftService.searchProducts(
        _searchController.text,
        minPrice: _showBudgetFilter ? _budgetRange!.start : null,
        maxPrice: _showBudgetFilter ? _budgetRange!.end : null,
      );
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
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch URL')),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Search Results',
                        style: GoogleFonts.poppins(
                          fontSize: isSmallScreen ? 20 : 24,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.filter_list,
                          color: _showBudgetFilter 
                              ? theme.colorScheme.primary 
                              : theme.colorScheme.secondary.withOpacity(0.7),
                        ),
                        onPressed: () {
                          setState(() {
                            _showBudgetFilter = !_showBudgetFilter;
                          });
                        },
                      ),
                    ],
                  ),
                  if (_showBudgetFilter) ...[
                    const SizedBox(height: 16),
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
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Budget Range: ₹${_budgetRange!.start.toInt()} - ₹${_budgetRange!.end.toInt()}',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Manual budget entry text fields
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _minBudgetController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: 'Min Budget (₹)',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  ),
                                  onChanged: (value) {
                                    if (value.isNotEmpty) {
                                      final minValue = double.tryParse(value) ?? _minBudgetValue;
                                      setState(() {
                                        _budgetRange = RangeValues(
                                          minValue.clamp(_minBudgetValue, _budgetRange!.end),
                                          _budgetRange!.end
                                        );
                                      });
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextField(
                                  controller: _maxBudgetController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: 'Max Budget (₹)',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  ),
                                  onChanged: (value) {
                                    if (value.isNotEmpty) {
                                      final maxValue = double.tryParse(value) ?? _maxBudgetValue;
                                      setState(() {
                                        _budgetRange = RangeValues(
                                          _budgetRange!.start,
                                          maxValue.clamp(_budgetRange!.start, _maxBudgetValue)
                                        );
                                      });
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 16),
                          SliderTheme(
                            data: SliderThemeData(
                              activeTrackColor: theme.colorScheme.primary,
                              inactiveTrackColor: theme.colorScheme.primary.withOpacity(0.2),
                              thumbColor: theme.colorScheme.primary,
                              overlayColor: theme.colorScheme.primary.withOpacity(0.2),
                              valueIndicatorColor: theme.colorScheme.primary,
                              valueIndicatorTextStyle: GoogleFonts.inter(
                                color: Colors.black,
                              ),
                            ),
                            child: RangeSlider(
                              values: _budgetRange!,
                              min: _minBudgetValue,
                              max: _maxBudgetValue,
                              divisions: 100,
                              labels: RangeLabels(
                                '₹${_budgetRange!.start.toInt()}',
                                '₹${_budgetRange!.end.toInt()}',
                              ),
                              onChanged: (RangeValues values) {
                                setState(() {
                                  _budgetRange = values;
                                  _minBudgetController.text = values.start.toInt().toString();
                                  _maxBudgetController.text = values.end.toInt().toString();
                                });
                              },
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '₹${_minBudgetValue.toInt()}',
                                style: GoogleFonts.inter(
                                  color: theme.colorScheme.secondary.withOpacity(0.7),
                                ),
                              ),
                              Text(
                                '₹${_maxBudgetValue.toInt()}',
                                style: GoogleFonts.inter(
                                  color: theme.colorScheme.secondary.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _searchProducts,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Apply Filter',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          // Loading state
          if (_isLoading)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(child: CircularProgressIndicator()),
              ),
            )
          // Empty state with search query
          else if (_products.isEmpty && _searchController.text.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Center(
                  child: Text(
                    'No products found for "${_searchController.text}"',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                ),
              ),
            )
          // Empty state without search query
          else if (_products.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
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
              ),
            )
          // Product grid
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
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '₹${product.price.toStringAsFixed(2)}',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            Text(
                              product.platform,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: theme.colorScheme.secondary.withOpacity(0.7),
                              ),
                            ),
                          ],
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
