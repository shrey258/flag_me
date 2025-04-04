import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/responsive_helper.dart';
import '../widgets/hero_card.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _emailNotifications = false;
  String _reminderTime = '1 week';

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
                'Settings',
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
                      _buildHeaderCard(context),
                      SizedBox(
                        height: ResponsiveHelper.isMobile(context) ? 24 : 32,
                      ),
                      _buildSection(
                        context,
                        title: 'Notifications',
                        icon: Icons.notifications_outlined,
                        children: [
                          _buildSwitchTile(
                            context,
                            title: 'Enable Notifications',
                            subtitle:
                                'Receive reminders for upcoming occasions',
                            value: _notificationsEnabled,
                            onChanged: (value) {
                              setState(() => _notificationsEnabled = value);
                            },
                          ),
                          _buildSwitchTile(
                            context,
                            title: 'Email Notifications',
                            subtitle: 'Receive notifications via email',
                            value: _emailNotifications,
                            onChanged: (value) {
                              setState(() => _emailNotifications = value);
                            },
                          ),
                        ],
                      ),
                      SizedBox(
                        height: ResponsiveHelper.isMobile(context) ? 24 : 32,
                      ),
                      _buildSection(
                        context,
                        title: 'Appearance',
                        icon: Icons.palette_outlined,
                        children: [
                          _buildSwitchTile(
                            context,
                            title: 'Dark Theme',
                            subtitle: 'Enable dark mode for the application',
                            value: ref.watch(themeModeProvider) == ThemeMode.dark,
                            onChanged: (value) {
                              ref.read(themeModeProvider.notifier).setThemeMode(
                                    value ? ThemeMode.dark : ThemeMode.light,
                                  );
                            },
                          ),
                        ],
                      ),
                      SizedBox(
                        height: ResponsiveHelper.isMobile(context) ? 24 : 32,
                      ),
                      _buildSection(
                        context,
                        title: 'Preferences',
                        icon: Icons.settings_outlined,
                        children: [
                          _buildDropdownTile(
                            context,
                            title: 'Default Reminder Time',
                            value: _reminderTime,
                            items: [
                              '1 day',
                              '3 days',
                              '1 week',
                              '2 weeks',
                              '1 month',
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _reminderTime = value);
                              }
                            },
                          ),
                        ],
                      ),
                      SizedBox(
                        height: ResponsiveHelper.isMobile(context) ? 24 : 32,
                      ),
                      _buildSection(
                        context,
                        title: 'Account',
                        icon: Icons.account_circle_outlined,
                        children: [
                          ListTile(
                            title: Text(
                              'Sign Out',
                              style: GoogleFonts.poppins(
                                fontSize: ResponsiveHelper.isMobile(context) ? 16 : 18,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                            leading: Icon(
                              Icons.logout_rounded,
                              color: Theme.of(context).colorScheme.error,
                            ),
                            onTap: () async {
                              final shouldLogout = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text(
                                    'Sign Out',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  content: Text(
                                    'Are you sure you want to sign out?',
                                    style: GoogleFonts.inter(),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: Text(
                                        'Cancel',
                                        style: GoogleFonts.poppins(
                                          color: Theme.of(context).colorScheme.secondary,
                                        ),
                                      ),
                                    ),
                                    FilledButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      style: FilledButton.styleFrom(
                                        backgroundColor: Theme.of(context).colorScheme.error,
                                      ),
                                      child: Text(
                                        'Sign Out',
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );

                              if (shouldLogout == true) {
                                try {
                                  await ref.read(authStateProvider.notifier).signOut();
                                } catch (e) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Failed to sign out: $e'),
                                        backgroundColor: Theme.of(context).colorScheme.error,
                                      ),
                                    );
                                  }
                                }
                              }
                            },
                          ),
                        ],
                      ),
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

  Widget _buildHeaderCard(BuildContext context) {
    return HeroCard(
      icon: Icon(
        Icons.settings_outlined,
        size: ResponsiveHelper.isMobile(context) ? 48 : 64,
        color: Theme.of(context).colorScheme.secondary,
      ),
      title: 'Customize Your Experience',
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: ResponsiveHelper.isMobile(context) ? 24 : 28,
            ),
            SizedBox(width: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: ResponsiveHelper.isMobile(context) ? 20 : 24,
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: ResponsiveHelper.isMobile(context) ? 16 : 18,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
      activeColor: Theme.of(context).colorScheme.primary,
    );
  }

  Widget _buildDropdownTile(
    BuildContext context, {
    required String title,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return ListTile(
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: ResponsiveHelper.isMobile(context) ? 16 : 18,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: DropdownButton<String>(
        value: value,
        items: items.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
