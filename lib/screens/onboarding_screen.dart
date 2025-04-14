import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../main.dart';
import '../theme/retro_theme.dart';
import 'auth_screen.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Flag Me',
      subtitle: 'Never Miss a Moment',
      description: 'Keep track of important dates and stay connected with your loved ones.',
      icon: Icons.flag,
      iconBackground: RetroTheme.blackAccent,
      iconBorder: RetroTheme.goldPrimary,
    ),
    OnboardingPage(
      title: 'Explore Gift Ideas',
      subtitle: 'Perfect Presents',
      description: 'Discover personalized gift suggestions for any special occasion.',
      icon: Icons.card_giftcard,
      iconBackground: RetroTheme.blackAccent,
      iconBorder: RetroTheme.goldPrimary,
    ),
    OnboardingPage(
      title: 'Generate Messages',
      subtitle: 'Heartfelt Words',
      description: 'Create personalized messages for your friends and family with ease.',
      icon: Icons.edit_note,
      iconBackground: RetroTheme.blackAccent,
      iconBorder: RetroTheme.goldPrimary,
    ),
  ];

  // Mark onboarding as completed in SharedPreferences
  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    // Invalidate the provider to refresh the state
    if (mounted) {
      ref.invalidate(onboardingCompletedProvider);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RetroTheme.blackPrimary,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: Column(
                children: [
                  // Page indicator
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: _pages.length,
                    effect: WormEffect(
                      dotHeight: 10,
                      dotWidth: 10,
                      spacing: 16,
                      activeDotColor: RetroTheme.goldPrimary,
                      dotColor: RetroTheme.goldPrimary.withOpacity(0.3),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Navigation buttons
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentPage < _pages.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          // Mark onboarding as completed and navigate to auth screen
                          _completeOnboarding();
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => const AuthScreen(),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: RetroTheme.goldPrimary,
                        foregroundColor: RetroTheme.blackPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                      child: Text(
                        _currentPage < _pages.length - 1 ? 'Next' : 'Get Started',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  if (_currentPage < _pages.length - 1) ...[
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        // Mark onboarding as completed and skip to auth screen
                        _completeOnboarding();
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const AuthScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Skip',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: RetroTheme.textMuted,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with gold border
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: page.iconBackground,
              shape: BoxShape.circle,
              border: Border.all(
                color: page.iconBorder,
                width: 2.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: RetroTheme.goldPrimary.withOpacity(0.2),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              page.icon,
              size: 56,
              color: RetroTheme.goldPrimary,
            ),
          ),
          const SizedBox(height: 48),
          // Title
          Text(
            page.title,
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: RetroTheme.goldPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          // Subtitle
          Text(
            page.subtitle,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: RetroTheme.textLight,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          // Description
          Text(
            page.description,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: RetroTheme.textMuted,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color iconBackground;
  final Color iconBorder;

  OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.iconBackground,
    required this.iconBorder,
  });
}
