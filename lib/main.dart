import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'config/supabase_config.dart';
import 'models/occasion.dart';
import 'providers/auth_provider.dart';
import 'providers/navigation_provider.dart';
import 'providers/occasions_provider.dart';
import 'screens/add_occasion_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/occasion_details_screen.dart';
import 'screens/product_search_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/gift_preferences_screen.dart';
import 'screens/message_generator_screen.dart';
import 'utils/responsive_helper.dart';
import 'widgets/bottom_nav_bar.dart';
import 'widgets/hero_card.dart';
import 'providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load();
    print('Environment variables loaded');

    print('Initializing Supabase...');
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
      debug: true,
    );
    print('Supabase initialization completed');

    final client = Supabase.instance.client;
    print('Current session: ${client.auth.currentSession?.user.email}');
    
    client.auth.onAuthStateChange.listen((data) {
      print('Auth State Change:');
      print('Event: ${data.event}');
      print('User: ${data.session?.user.email}');
      print('Access Token: ${data.session?.accessToken}');
    });

    tz.initializeTimeZones();
    print('Timezone initialization completed');

    runApp(const ProviderScope(child: MyApp()));
  } catch (e, stackTrace) {
    print('Initialization error: $e');
    print('Stack trace: $stackTrace');
    rethrow;
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'Flag Me',
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        physics: const BouncingScrollPhysics(),
        scrollbars: true,
      ),
      theme: getLightTheme(),
      darkTheme: getDarkTheme(),
      themeMode: themeMode,
      home: switch (authState) {
        Authenticated _ => const MainScreen(),
        _ => const AuthScreen(),
      },
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
        return const GiftPreferencesScreen(key: PageStorageKey('gift_preferences'));
      case NavigationSection.messageGenerator:
        return const MessageGeneratorScreen(key: PageStorageKey('message_generator'));
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
          Icon(
            Icons.celebration_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'No occasions yet',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first occasion to get started!',
            style: Theme.of(context).textTheme.bodyMedium,
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
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: ResponsiveHelper.isMobile(context) ? 24 : 28,
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
                      color: Colors.red.shade100,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 16),
                      child: const Icon(Icons.delete, color: Colors.red),
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
                        color: Colors.red.shade100,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 16),
                        child: const Icon(Icons.delete, color: Colors.red),
                      ),
                      onDismissed: (direction) {
                        ref
                            .read(occasionsProvider.notifier)
                            .deleteOccasion(occasion.id);
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
            color: Theme.of(context).colorScheme.tertiary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.cake,
            color: Theme.of(context).colorScheme.primary,
            size: ResponsiveHelper.isMobile(context) ? 24 : 32,
          ),
        ),
        title: Text(
          occasion.personName,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: ResponsiveHelper.isMobile(context) ? 16 : 18,
          ),
        ),
        subtitle: Text(
          '${_getTimeUntil(occasion.date)} • ${occasion.relationType.name}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: ResponsiveHelper.isMobile(context) ? 14 : 16,
              ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Theme.of(context).colorScheme.primary,
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
