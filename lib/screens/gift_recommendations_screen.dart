import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/gift_preference.dart';
import '../services/gift_service.dart';
import 'product_search_screen.dart';

class GiftRecommendationsScreen extends ConsumerStatefulWidget {
  final String occasionId;
  final GiftPreference preference;

  const GiftRecommendationsScreen({
    super.key,
    required this.occasionId,
    required this.preference,
  });

  @override
  ConsumerState<GiftRecommendationsScreen> createState() =>
      _GiftRecommendationsScreenState();
}

class _GiftRecommendationsScreenState
    extends ConsumerState<GiftRecommendationsScreen> {
  bool _isLoading = false;
  List<String> _suggestions = [];
  final GiftService _giftService = GiftService();

  @override
  void initState() {
    super.initState();
    _fetchSuggestions();
  }

  Future<void> _fetchSuggestions() async {
    setState(() => _isLoading = true);
    try {
      final suggestions = await _giftService.getGiftSuggestions(widget.preference);
      setState(() {
        _suggestions = suggestions;
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

  void _searchProducts(String suggestion) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductSearchScreen(
          searchQuery: suggestion,
          occasionId: widget.occasionId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            floating: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Gift Suggestions',
                style: GoogleFonts.playfairDisplay(
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
            ),
          ),
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_suggestions.isEmpty)
            const SliverFillRemaining(
              child: Center(child: Text('No suggestions found')),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final suggestion = _suggestions[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8.0),
                      child: ListTile(
                        title: Text(suggestion),
                        trailing: const Icon(Icons.search),
                        onTap: () => _searchProducts(suggestion),
                      ),
                    );
                  },
                  childCount: _suggestions.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
