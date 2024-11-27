import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/responsive_helper.dart';
import '../widgets/hero_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
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
    return Padding(
      padding: EdgeInsets.all(ResponsiveHelper.isMobile(context) ? 16 : 20),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: ResponsiveHelper.isMobile(context) ? 16 : 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          DropdownButton<String>(
            value: value,
            items:
                items.map((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
