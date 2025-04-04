import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/responsive_helper.dart';
import '../providers/occasions_provider.dart';
import '../models/reminder.dart';
import '../models/enums.dart';
import '../widgets/hero_card.dart';
import '../models/occasion.dart';
import '../models/gift_recommendation.dart';
import '../theme/retro_theme.dart';
import '../services/gift_service.dart';
import 'gift_preferences_screen.dart';
import 'product_search_screen.dart';

// Provider for the latest gift recommendation
final latestRecommendationProvider = FutureProvider.autoDispose.family<GiftRecommendation?, String>((ref, occasionId) async {
  print('Fetching latest recommendation for occasion: $occasionId');
  final giftService = GiftService();
  return await giftService.getLatestRecommendation(occasionId);
});

class OccasionDetailsScreen extends ConsumerWidget {
  final String occasionId;
  final RelationType relationType;

  const OccasionDetailsScreen({
    super.key,
    required this.occasionId,
    required this.relationType,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final occasion = ref.watch(occasionByIdProvider(occasionId));

    if (occasion == null) {
      return Scaffold(body: Center(child: Text('Occasion not found')));
    }

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
                'Occasion Details',
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
              child: Center(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: ResponsiveHelper.getCardWidth(context),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildOccasionHeader(context, occasion),
                      const SizedBox(height: 32),
                      _buildDetailsSection(context, occasion),
                      const SizedBox(height: 32),
                      _buildGiftSuggestions(context, occasion),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOccasionHeader(BuildContext context, Occasion occasion) {
    return HeroCard(
      icon: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: RetroTheme.blackAccent,
          shape: BoxShape.circle,
          border: Border.all(color: RetroTheme.goldPrimary, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(
          Icons.cake,
          size: ResponsiveHelper.isMobile(context) ? 48 : 64,
          color: RetroTheme.goldPrimary,
        ),
      ),
      title: '${occasion.personName}\'s ${occasion.description}',
      subtitle: occasion.relationType.name,
    );
  }

  Widget _buildDetailsSection(BuildContext context, Occasion occasion) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Details',
          style: GoogleFonts.poppins(
            fontSize: ResponsiveHelper.isMobile(context) ? 20 : 24,
            fontWeight: FontWeight.w600,
            color: RetroTheme.goldPrimary,
          ),
        ),
        SizedBox(height: 16),
        _buildDetailCard(
          context,
          icon: Icons.calendar_today,
          title: 'Date',
          value: _formatDate(occasion.date),
        ),
        _buildDetailCard(
          context,
          icon: Icons.timer,
          title: 'Time Remaining',
          value: _getTimeUntil(occasion.date),
        ),
        if (occasion.reminders.isNotEmpty)
          _buildDetailCard(
            context,
            icon: Icons.notifications,
            title: 'Next Reminder',
            value: _getNextReminder(occasion.reminders),
          ),
      ],
    );
  }

  Widget _buildGiftSuggestions(BuildContext context, Occasion occasion) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gift Ideas',
          style: GoogleFonts.poppins(
            fontSize: ResponsiveHelper.isMobile(context) ? 20 : 24,
            fontWeight: FontWeight.w600,
            color: RetroTheme.goldPrimary,
          ),
        ),
        SizedBox(height: 16),
        _buildLastRecommendation(context),
        SizedBox(height: 24),
        _buildGiftCard(context, occasion),
      ],
    );
  }

  Widget _buildLastRecommendation(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      final recommendationAsync = ref.watch(latestRecommendationProvider(occasionId));
      
      return recommendationAsync.when(
        data: (recommendation) {
          if (recommendation == null) {
            return Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: RetroTheme.blackLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: RetroTheme.goldPrimary.withOpacity(0.3), width: 1),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: RetroTheme.blackAccent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: RetroTheme.goldPrimary, width: 1),
                    ),
                    child: Icon(
                      Icons.card_giftcard,
                      color: RetroTheme.goldPrimary,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Last Recommendation',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: RetroTheme.goldPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'No recommendations available yet',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                            fontSize: ResponsiveHelper.isMobile(context) ? 14 : 16,
                            color: RetroTheme.textLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
          
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductSearchScreen(
                    searchQuery: recommendation.title,
                    minBudget: null,
                    maxBudget: null,
                  ),
                ),
              );
            },
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: RetroTheme.blackLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: RetroTheme.goldPrimary.withOpacity(0.3), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: RetroTheme.blackAccent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: RetroTheme.goldPrimary, width: 1),
                        ),
                        child: Icon(
                          Icons.card_giftcard,
                          color: RetroTheme.goldPrimary,
                          size: 20,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Last Recommendation',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: RetroTheme.goldPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              recommendation.title,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: ResponsiveHelper.isMobile(context) ? 14 : 16,
                                color: RetroTheme.textLight,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: RetroTheme.goldPrimary,
                        size: 16,
                      ),
                    ],
                  ),
                  if (recommendation.description.isNotEmpty) ...[  
                    SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.only(left: 44),
                      child: Text(
                        recommendation.description,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: RetroTheme.textLight.withOpacity(0.7),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                  if (recommendation.price != null) ...[  
                    SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.only(left: 44),
                      child: Text(
                        '₹${recommendation.price!.toStringAsFixed(2)}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: RetroTheme.goldPrimary,
                        ),
                      ),
                    ),
                  ],
                  SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(left: 44),
                    child: Text(
                      'Generated on ${_formatDate(recommendation.createdAt)}',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: RetroTheme.textLight.withOpacity(0.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => Container(
          height: 100,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: RetroTheme.blackLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: RetroTheme.goldPrimary.withOpacity(0.3), width: 1),
          ),
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(RetroTheme.goldPrimary),
            ),
          ),
        ),
        error: (error, stack) => Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: RetroTheme.blackLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: RetroTheme.errorColor.withOpacity(0.3), width: 1),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: RetroTheme.blackAccent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: RetroTheme.errorColor, width: 1),
                ),
                child: Icon(
                  Icons.error_outline,
                  color: RetroTheme.errorColor,
                  size: 20,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Error Loading Recommendation',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: RetroTheme.errorColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Please try again later',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        fontSize: ResponsiveHelper.isMobile(context) ? 14 : 16,
                        color: RetroTheme.textLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildGiftCard(BuildContext context, Occasion occasion) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: RetroTheme.blackLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: RetroTheme.goldPrimary.withOpacity(0.5), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: RetroTheme.blackAccent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: RetroTheme.goldPrimary, width: 1),
                  ),
                  child: Icon(
                    Icons.card_giftcard,
                    color: RetroTheme.goldPrimary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'Find the Perfect Gift',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: ResponsiveHelper.isMobile(context) ? 16 : 18,
                    color: RetroTheme.textLight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Get personalized gift suggestions based on interests and preferences.',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: RetroTheme.textMuted,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: Consumer(builder: (context, widgetRef, _) {
                return ElevatedButton.icon(
                  onPressed: () async {
                    // Navigate and wait for result
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GiftPreferencesScreen(
                          occasionId: occasion.id,
                          occasionName: occasion.description,
                        ),
                      ),
                    );
                    
                    // Refresh the recommendation data
                    if (context.mounted) {
                      // Force a refresh by invalidating the provider
                      print('Refreshing recommendations for occasion: $occasionId');
                      widgetRef.invalidate(latestRecommendationProvider(occasionId));
                    }
                  },
                  icon: const Icon(Icons.search),
                  label: const Text('Find Gift Ideas'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: RetroTheme.goldPrimary,
                    foregroundColor: RetroTheme.blackAccent,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    textStyle: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: RetroTheme.blackLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: RetroTheme.goldPrimary.withOpacity(0.3), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: RetroTheme.blackAccent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: RetroTheme.goldPrimary, width: 1),
              ),
              child: Icon(
                icon,
                color: RetroTheme.goldPrimary,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: RetroTheme.goldPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    value,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: ResponsiveHelper.isMobile(context) ? 14 : 16,
                      color: RetroTheme.textLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _getTimeUntil(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);

    if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} away';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} away';
    } else if (difference.inDays == 0) {
      return 'Today';
    } else {
      return 'Past';
    }
  }

  String _getNextReminder(List<Reminder> reminders) {
    final now = DateTime.now();
    final upcomingReminders = reminders
        .where((reminder) => reminder.date.isAfter(now))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    if (upcomingReminders.isEmpty) {
      return 'No upcoming reminders';
    }

    final nextReminder = upcomingReminders.first;
    final difference = nextReminder.date.difference(now);

    if (difference.inDays > 0) {
      return 'In ${difference.inDays} days';
    } else if (difference.inHours > 0) {
      return 'In ${difference.inHours} hours';
    } else {
      return 'In ${difference.inMinutes} minutes';
    }
  }
}
