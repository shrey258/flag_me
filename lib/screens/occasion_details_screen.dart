import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/responsive_helper.dart';
import '../providers/occasions_provider.dart';
import '../models/reminder.dart';
import '../models/enums.dart';
import 'gift_prefrence_screen.dart';
import '../widgets/hero_card.dart';
import '../models/occasion.dart';

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
                      SizedBox(
                        height: ResponsiveHelper.isMobile(context) ? 24 : 32,
                      ),
                      _buildDetailsSection(context, occasion),
                      SizedBox(
                        height: ResponsiveHelper.isMobile(context) ? 24 : 32,
                      ),
                      _buildGiftSuggestions(context),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primary.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GiftPreferenceScreen(
                  occasionId: occasion.id,
                  relationType: occasion.relationType,
                ),
              ),
            );
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          label: Row(
            children: [
              Icon(Icons.card_giftcard, color: Colors.black),
              SizedBox(width: 8),
              Text(
                'Select Gift',
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
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
      return 'Today!';
    } else {
      return 'Past';
    }
  }

  String _getNextReminder(List<Reminder> reminders) {
    final now = DateTime.now();
    final upcomingReminders = reminders
        .where(
          (reminder) => reminder.date.isAfter(now) && reminder.isActive,
        )
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    if (upcomingReminders.isEmpty) {
      return 'No upcoming reminders';
    }

    final nextReminder = upcomingReminders.first;
    return _formatDate(nextReminder.date);
  }

  Widget _buildDetailCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(ResponsiveHelper.isMobile(context) ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.bodyMedium),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: ResponsiveHelper.isMobile(context) ? 16 : 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGiftSuggestions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gift Suggestions',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontSize: ResponsiveHelper.isMobile(context) ? 20 : 24,
          ),
        ),
        SizedBox(height: 16),
        if (ResponsiveHelper.isMobile(context))
          Column(children: [_buildGiftCard(context), _buildGiftCard(context)])
        else
          Row(
            children: [
              Expanded(child: _buildGiftCard(context)),
              SizedBox(width: 16),
              Expanded(child: _buildGiftCard(context)),
            ],
          ),
      ],
    );
  }

  Widget _buildGiftCard(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(ResponsiveHelper.isMobile(context) ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Watch',
            style: GoogleFonts.poppins(
              fontSize: ResponsiveHelper.isMobile(context) ? 18 : 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text('Fossil Gen 6', style: Theme.of(context).textTheme.bodyLarge),
          SizedBox(height: 8),
          Text(
            '\$299',
            style: GoogleFonts.poppins(
              fontSize: ResponsiveHelper.isMobile(context) ? 16 : 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
