import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/responsive_helper.dart';
import '../providers/occasions_provider.dart';
import '../models/reminder.dart';
import '../models/enums.dart';
import '../widgets/hero_card.dart';
import '../models/occasion.dart';
import 'gift_preferences_screen.dart';

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
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          Icons.cake,
          size: ResponsiveHelper.isMobile(context) ? 48 : 64,
          color: Theme.of(context).colorScheme.primary,
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
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontSize: ResponsiveHelper.isMobile(context) ? 20 : 24,
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
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontSize: ResponsiveHelper.isMobile(context) ? 20 : 24,
          ),
        ),
        const SizedBox(height: 16),
        _buildGiftCard(context, occasion),
      ],
    );
  }

  Widget _buildGiftCard(BuildContext context, Occasion occasion) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.tertiary,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.card_giftcard,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Find the Perfect Gift',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: ResponsiveHelper.isMobile(context) ? 16 : 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Get personalized gift suggestions based on interests and preferences.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GiftPreferencesScreen(
                      occasionId: occasion.id,
                      occasion: occasion.description,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.search),
              label: const Text('Find Gift Ideas'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
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
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.tertiary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    value,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: ResponsiveHelper.isMobile(context) ? 14 : 16,
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
