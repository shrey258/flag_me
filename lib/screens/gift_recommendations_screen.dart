import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/gift_preference.dart';
import '../models/gift_recommendation.dart';
import '../utils/responsive_helper.dart';
import '../services/gift_service.dart';
import 'product_search_screen.dart';

class GiftRecommendationsScreen extends ConsumerStatefulWidget {
  final GiftPreference preference;
  final String? occasionId; // Optional occasion ID to associate recommendations with
  
  const GiftRecommendationsScreen({
    super.key, 
    required this.preference,
    this.occasionId,
  });

  @override
  ConsumerState<GiftRecommendationsScreen> createState() => _GiftRecommendationsScreenState();
}

class _GiftRecommendationsScreenState extends ConsumerState<GiftRecommendationsScreen> {
  final GiftService _giftService = GiftService();
  bool _isLoading = false;
  List<String> _recommendations = [];
  String? _error;
  
  // Helper method to save a recommendation
  Future<void> _saveRecommendation(String title, String description) async {
    if (widget.occasionId == null) return;
    
    try {
      print('Saving recommendation: $title for occasion: ${widget.occasionId}');
      
      // Create recommendation object
      final recommendation = GiftRecommendation(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        occasionId: widget.occasionId!,
        title: title,
        description: description,
        price: widget.preference.maxBudget != null ? 
          (widget.preference.minBudget! + 
           (widget.preference.maxBudget! - widget.preference.minBudget!) * 0.7) : null,
        imageUrl: null,
        createdAt: DateTime.now(),
      );
      
      // Save to database
      await _giftService.saveRecommendation(recommendation);
      print('Successfully saved recommendation');
    } catch (e) {
      print('Error saving recommendation: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchRecommendations();
  }

  Future<void> _fetchRecommendations() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Pass the occasionId if available to store the recommendations
      final recommendations = await _giftService.getGiftSuggestions(
        widget.preference,
        occasionId: widget.occasionId,
      );
      setState(() {
        _recommendations = recommendations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
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
                'Gift Recommendations',
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
                  Text(
                    'Perfect Gifts for ${widget.preference.occasion}',
                    style: GoogleFonts.poppins(
                      fontSize: isSmallScreen ? 20 : 24,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Based on your preferences, we think these gifts would be perfect',
                    style: GoogleFonts.inter(
                      fontSize: isSmallScreen ? 14 : 16,
                      color: theme.colorScheme.secondary.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else if (_error != null)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load recommendations',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _fetchRecommendations,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          else if (_recommendations.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 64,
                      color: theme.colorScheme.secondary.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No recommendations found',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isSmallScreen ? 1 : 2,
                  mainAxisSpacing: 16.0,
                  crossAxisSpacing: 16.0,
                  childAspectRatio: isSmallScreen ? 1.5 : 1.2,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final recommendation = _recommendations[index];
                    return _buildRecommendationCard(
                      theme,
                      {
                        'title': recommendation,
                        'description': 'Click to search for this gift idea',
                        'price': 0.0,
                        'rating': 0.0,
                      },
                    );
                  },
                  childCount: _recommendations.length,
                ),
              ),
            ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Text(
                    'Not finding what you\'re looking for?',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductSearchScreen(
                            minBudget: widget.preference.minBudget,
                            maxBudget: widget.preference.maxBudget,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.search),
                    label: Text(
                      'Browse More Gifts',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(ThemeData theme, Map<String, dynamic> recommendation) {
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
            onTap: () async {
              // If we have an occasionId, save this recommendation
              if (widget.occasionId != null) {
                final title = recommendation['title'];
                final description = recommendation['description'];
                
                // Create and save the recommendation
                await _saveRecommendation(title, description);
                
                // Show confirmation to user
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Saved "$title" as recommendation'),
                      backgroundColor: theme.colorScheme.primary,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              }
              
              // Navigate to product search
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductSearchScreen(
                    searchQuery: recommendation['title'],
                    minBudget: widget.preference.minBudget,
                    maxBudget: widget.preference.maxBudget,
                  ),
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.card_giftcard,
                        size: 48,
                        color: theme.colorScheme.primary,
                      ),
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
                          recommendation['title'],
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.secondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          recommendation['description'],
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: theme.colorScheme.secondary.withOpacity(0.7),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
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
