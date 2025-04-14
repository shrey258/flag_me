import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'config/supabase_config.dart';
import 'models/occasion.dart';
import 'providers/auth_provider.dart';
import 'providers/navigation_provider.dart';
import 'providers/occasions_provider.dart';
import 'screens/add_occasion_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/gift_preferences_screen.dart';
import 'screens/message_generator_screen.dart';
import 'screens/occasion_details_screen.dart';
import 'screens/product_search_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/onboarding_screen.dart';
import 'theme/retro_theme.dart';
import 'utils/responsive_helper.dart';
import 'widgets/bottom_nav_bar.dart';
import 'widgets/hero_card.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await dotenv.load();
    
    // Initialize Supabase
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );
    
    runApp(const ProviderScope(child: MyApp()));
  } catch (e, stackTrace) {
    print('Initialization error: $e');
    print('Stack trace: $stackTrace');
    rethrow;
  }
}

// Provider for onboarding state
final onboardingCompletedProvider = FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('onboarding_completed') ?? false;
});

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final onboardingCompleted = ref.watch(onboardingCompletedProvider);

    return MaterialApp(
      title: 'Flag Me',
      debugShowCheckedModeBanner: false,
      theme: RetroTheme.getTheme(),
      home: onboardingCompleted.when(
        data: (completed) {
          if (!completed) {
            return const OnboardingScreen();
          }
          
          return switch (authState) {
            Initial() => const AuthScreen(),
            Loading() => const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
            Authenticated(user: _) => const MainScreen(),
            Error() => const AuthScreen(),
          };
        },
        loading: () => const Scaffold(
          backgroundColor: RetroTheme.blackPrimary,
          body: Center(child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(RetroTheme.goldPrimary),
          )),
        ),
        error: (_, __) => const AuthScreen(),
      ),
    );
  }
}

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSection = ref.watch(navigationProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: KeyedSubtree(
          key: ValueKey<NavigationSection>(currentSection),
          child: _buildCurrentSection(currentSection),
        ),
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
      floatingActionButton: currentSection == NavigationSection.home
          ? _buildAddOccasionButton(context)
          : null,
      bottomNavigationBar: const BottomNavBar(),
    );
  }

  Widget _buildCurrentSection(NavigationSection section) {
    switch (section) {
      case NavigationSection.home:
        return const HomePage(key: PageStorageKey('home_page'));
      case NavigationSection.productSearch:
        return const ProductSearchScreen(key: PageStorageKey('product_search'));
      case NavigationSection.giftPreferences:
        return const GiftPreferencesScreen(
            key: PageStorageKey('gift_preferences'));
      case NavigationSection.messageGenerator:
        return const MessageGeneratorScreen(
            key: PageStorageKey('message_generator'));
      case NavigationSection.settings:
        return const SettingsScreen(key: PageStorageKey('settings'));
    }
  }

  Widget _buildAddOccasionButton(BuildContext context) {
    return Container(
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
              builder: (context) => const AddOccasionScreen(),
            ),
          );
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        label: Row(
          children: [
            const Icon(Icons.add, color: Colors.black),
            const SizedBox(width: 8),
            Text(
              'Add Occasion',
              style: GoogleFonts.poppins(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final occasions = ref.watch(upcomingOccasionsProvider);

    return CustomScrollView(
      slivers: [
        SliverAppBar.large(
          floating: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              'Flag Me',
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
                    _buildHeroCard(context),
                    const SizedBox(height: 32),
                    occasions.isEmpty
                        ? _buildEmptyState(context)
                        : _buildUpcomingOccasionsSection(
                            context,
                            occasions,
                            ref,
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroCard(BuildContext context) {
    return HeroCard(
      icon: Image.asset(
        'assets/logo.png',
        width: ResponsiveHelper.isMobile(context) ? 120 : 160,
        height: ResponsiveHelper.isMobile(context) ? 120 : 160,
      ),
      title: 'Never Miss a Special Moment',
      subtitle:
          'Track important dates and find the perfect gifts for your loved ones',
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: RetroTheme.blackAccent,
              shape: BoxShape.circle,
              border: Border.all(color: RetroTheme.goldPrimary, width: 1),
            ),
            child: Icon(
              Icons.celebration_outlined,
              size: 48,
              color: RetroTheme.goldPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No occasions yet',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: RetroTheme.textLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first occasion to get started!',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: RetroTheme.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingOccasionsSection(
    BuildContext context,
    List<Occasion> occasions,
    WidgetRef ref,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upcoming Occasions',
          style: GoogleFonts.poppins(
            fontSize: ResponsiveHelper.isMobile(context) ? 24 : 28,
            fontWeight: FontWeight.w600,
            color: RetroTheme.goldPrimary,
          ),
        ),
        const SizedBox(height: 16),
        if (ResponsiveHelper.isMobile(context))
          Column(
            children: occasions
                .map(
                  (occasion) => Dismissible(
                    key: Key(occasion.id),
                    background: Container(
                      color: RetroTheme.blackAccent,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 16),
                      child: Icon(Icons.delete, color: RetroTheme.errorColor),
                    ),
                    onDismissed: (direction) {
                      ref
                          .read(occasionsProvider.notifier)
                          .deleteOccasion(occasion.id);
                    },
                    child: _buildOccasionCard(context, occasion),
                  ),
                )
                .toList(),
          )
        else
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: occasions
                .map(
                  (occasion) => SizedBox(
                    width: (ResponsiveHelper.getCardWidth(context) - 16) / 2,
                    child: Dismissible(
                      key: Key(occasion.id),
                      background: Container(
                        decoration: BoxDecoration(
                          color: RetroTheme.blackAccent,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: RetroTheme.errorColor.withOpacity(0.5), width: 1),
                        ),
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left: 16),
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: RetroTheme.errorColor),
                            const SizedBox(width: 8),
                            Text(
                              'Delete',
                              style: GoogleFonts.poppins(
                                color: RetroTheme.errorColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      secondaryBackground: Container(
                        decoration: BoxDecoration(
                          color: RetroTheme.blackAccent,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: RetroTheme.goldPrimary.withOpacity(0.5), width: 1),
                        ),
                        padding: const EdgeInsets.only(right: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'View Details',
                              style: GoogleFonts.poppins(
                                color: RetroTheme.goldPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(Icons.arrow_forward_ios, color: RetroTheme.goldPrimary),
                          ],
                        ),
                      ),
                      dismissThresholds: const {DismissDirection.endToStart: 0.5, DismissDirection.startToEnd: 0.5},
                      direction: DismissDirection.horizontal,
                      confirmDismiss: (direction) async {
                        if (direction == DismissDirection.endToStart) {
                          return await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                backgroundColor: RetroTheme.blackLight,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                title: Row(
                                  children: [
                                    Icon(Icons.warning_amber_rounded, color: RetroTheme.errorColor),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Delete Occasion',
                                      style: GoogleFonts.poppins(
                                        color: RetroTheme.textLight,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                content: Text(
                                  'Are you sure you want to delete ${occasion.personName}\'s ${occasion.description}?',
                                  style: GoogleFonts.inter(
                                    color: RetroTheme.textLight,
                                  ),
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(false),
                                    child: Text(
                                      'Cancel',
                                      style: GoogleFonts.poppins(
                                        color: RetroTheme.goldPrimary,
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: RetroTheme.errorColor,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    onPressed: () => Navigator.of(context).pop(true),
                                    child: Text(
                                      'Delete',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        } else if (direction == DismissDirection.startToEnd) {
                          // Navigate to occasion details screen (left-to-right swipe)
                          if (context.mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OccasionDetailsScreen(
                                  occasionId: occasion.id,
                                  relationType: occasion.relationType,
                                ),
                              ),
                            );
                          }
                          return false; // Don't dismiss the item
                        }
                        return false;
                      },
                      onDismissed: (direction) async {
                        try {
                          // Show loading indicator
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.0,
                                      valueColor: AlwaysStoppedAnimation<Color>(RetroTheme.textLight),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text('Deleting occasion...'),
                                ],
                              ),
                              backgroundColor: RetroTheme.blackAccent,
                              duration: const Duration(seconds: 1),
                            ),
                          );
                          
                          // Delete occasion from Supabase
                          await ref
                              .read(occasionsProvider.notifier)
                              .deleteOccasion(occasion.id);
                              
                          // Show success message
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Occasion deleted successfully'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } catch (e) {
                          // Show error message
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to delete occasion: $e'),
                                backgroundColor: RetroTheme.errorColor,
                              ),
                            );
                          }
                        }
                      },
                      child: _buildOccasionCard(context, occasion),
                    ),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }

  Widget _buildOccasionCard(BuildContext context, Occasion occasion) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: RetroTheme.blackLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: RetroTheme.goldPrimary.withOpacity(0.5), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(
          ResponsiveHelper.isMobile(context) ? 16 : 24,
        ),
        leading: Container(
          width: ResponsiveHelper.isMobile(context) ? 48 : 64,
          height: ResponsiveHelper.isMobile(context) ? 48 : 64,
          decoration: BoxDecoration(
            color: RetroTheme.blackAccent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: RetroTheme.goldPrimary, width: 1),
          ),
          child: Icon(
            Icons.cake,
            color: RetroTheme.goldPrimary,
            size: ResponsiveHelper.isMobile(context) ? 24 : 32,
          ),
        ),
        title: Text(
          occasion.personName,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: ResponsiveHelper.isMobile(context) ? 16 : 18,
            color: RetroTheme.textLight,
          ),
        ),
        subtitle: Text(
          '${_getTimeUntil(occasion.date)} • ${occasion.relationType.name}',
          style: GoogleFonts.poppins(
            fontSize: ResponsiveHelper.isMobile(context) ? 14 : 16,
            color: RetroTheme.goldPrimary,
            fontWeight: FontWeight.w400,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: RetroTheme.goldPrimary,
          size: ResponsiveHelper.isMobile(context) ? 24 : 28,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OccasionDetailsScreen(
                occasionId: occasion.id,
                relationType: occasion.relationType,
              ),
            ),
          );
        },
      ),
    );
  }

  String _getTimeUntil(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);

    if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return 'In $months ${months == 1 ? 'month' : 'months'}';
    } else if (difference.inDays > 0) {
      return 'In ${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'}';
    } else if (difference.inDays == 0) {
      return 'Today';
    } else {
      return 'Past';
    }
  }
}
