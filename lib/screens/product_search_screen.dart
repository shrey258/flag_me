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

  // Platform filter values
  bool _showPlatformFilter = false;
  final Map<String, bool> _selectedPlatforms = {
    'Amazon': true,
    'Flipkart': true,
  };

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
    if (_searchController.text.isEmpty) {
      return;
    }

    setState(() {
      _isLoading = true;
      _products = [];
    });

    try {
      // Get selected platforms
      List<String> platforms = _selectedPlatforms.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();

      // Only apply budget filter if it's visible
      double? minPrice;
      double? maxPrice;
      if (_showBudgetFilter) {
        minPrice = double.tryParse(_minBudgetController.text);
        maxPrice = double.tryParse(_maxBudgetController.text);
      }

      final results = await _giftService.searchProducts(
        _searchController.text,
        minPrice: minPrice,
        maxPrice: maxPrice,
        platforms: platforms.isEmpty ? null : platforms,
      );

      setState(() {
        _products = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error searching products: $e')),
      );
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
      backgroundColor: theme.colorScheme.surface,
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
                  if (_showBudgetFilter) _buildFilterSection(),
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
                  childAspectRatio: isSmallScreen ? 0.8 : 0.75,
                  mainAxisExtent: 320,
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

  Widget _buildFilterSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Budget Filter Toggle
        ListTile(
          title: Text(
            'Budget Filter',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          trailing: Switch(
            value: _showBudgetFilter,
            activeColor: Theme.of(context).colorScheme.primary,
            onChanged: (value) {
              setState(() {
                _showBudgetFilter = value;
              });
            },
          ),
        ),
        
        // Budget Range Slider
        if (_showBudgetFilter) _buildBudgetRangeFilter(),
        
        // Platform Filter Toggle
        ListTile(
          title: Text(
            'Website Filter',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          subtitle: Text(
            'Select websites to search',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.7),
            ),
          ),
          trailing: Switch(
            value: _showPlatformFilter,
            activeColor: Theme.of(context).colorScheme.primary,
            onChanged: (value) {
              setState(() {
                _showPlatformFilter = value;
                
                // If turning off platform filter, reset all platforms to true
                if (!value) {
                  _selectedPlatforms['Amazon'] = true;
                  _selectedPlatforms['Flipkart'] = true;
                }
              });
            },
          ),
        ),
        
        // Platform Checkboxes
        if (_showPlatformFilter)
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 8.0),
            child: Column(
              children: _selectedPlatforms.entries.map((entry) {
                return CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    entry.key,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  value: entry.value,
                  activeColor: _getPlatformColor(entry.key),
                  controlAffinity: ListTileControlAffinity.leading,
                  dense: true,
                  onChanged: (bool? value) {
                    setState(() {
                      _selectedPlatforms[entry.key] = value ?? false;
                      
                      // Ensure at least one platform is selected
                      if (!_selectedPlatforms.values.contains(true)) {
                        // If no platforms are selected, select the current one
                        _selectedPlatforms[entry.key] = true;
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ),
        if (_showPlatformFilter)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ElevatedButton(
              onPressed: _searchProducts,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: Theme.of(context).brightness == Brightness.dark ? 4 : 2,
              ),
              child: Text(
                'Apply Filters',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        const SizedBox(height: 16),
        
        // Apply Filter Button
        Center(
          child: ElevatedButton(
            onPressed: _searchProducts,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: Theme.of(context).brightness == Brightness.dark ? 4 : 2,
            ),
            child: Text(
              'Apply Filters',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetRangeFilter() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
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
              color: Theme.of(context).colorScheme.onSurface,
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
              activeTrackColor: Theme.of(context).colorScheme.primary,
              inactiveTrackColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              thumbColor: Theme.of(context).colorScheme.primary,
              overlayColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              valueIndicatorColor: Theme.of(context).colorScheme.primary,
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
                  color: Theme.of(context).colorScheme.secondary.withOpacity(0.7),
                ),
              ),
              Text(
                '₹${_maxBudgetValue.toInt()}',
                style: GoogleFonts.inter(
                  color: Theme.of(context).colorScheme.secondary.withOpacity(0.7),
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
                backgroundColor: Theme.of(context).colorScheme.primary,
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
    );
  }

  Widget _buildProductCard(ThemeData theme, ProductSearchResult product) {
    final isDarkMode = theme.brightness == Brightness.dark;
    return Card(
      elevation: isDarkMode ? 4 : 3,
      shadowColor: theme.colorScheme.primary.withOpacity(isDarkMode ? 0.4 : 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _launchUrl(product.url),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image with constrained height and error handling
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: SizedBox(
                    height: 180, // Fixed height for consistency
                    
                    width: double.infinity,
                    child: product.imageUrl != null
                        ? Image.network(
                            product.imageUrl!,
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: theme.colorScheme.tertiary,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.image_not_supported,
                                        size: 40,
                                        color: theme.colorScheme.onTertiary.withOpacity(0.5),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Image not available',
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          color: theme.colorScheme.onTertiary.withOpacity(0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          )
                        : Container(
                            color: theme.colorScheme.tertiary,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image_not_supported,
                                    size: 40,
                                    color: theme.colorScheme.onTertiary.withOpacity(0.5),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Image not available',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: theme.colorScheme.onTertiary.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                  ),
                ),
                // Platform badge in top-right corner
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getPlatformColor(product.platform),
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      product.platform,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            // Product details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Title with proper overflow handling
                    Expanded(
                      child: Text(
                        product.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Product Price
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '₹${product.price.toStringAsFixed(0)}',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        Icon(
                          Icons.shopping_cart_outlined,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                          size: 20,
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
    );
  }

  // Helper method to get platform-specific colors
  Color _getPlatformColor(String platform) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    switch (platform) {
      case 'Amazon':
        return isDarkMode ? Colors.orange[700]! : Colors.orange[800]!;
      case 'Flipkart':
        return isDarkMode ? Colors.blue[600]! : Colors.blue[800]!;
      case 'Myntra':
        return isDarkMode ? Colors.pink[400]! : Colors.pink[700]!;
      default:
        return isDarkMode ? Colors.grey[600]! : Colors.grey[700]!;
    }
  }
}
