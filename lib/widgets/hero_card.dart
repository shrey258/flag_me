import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/responsive_helper.dart';

class HeroCard extends StatelessWidget {
  final Widget icon;
  final String title;
  final String? subtitle;
  final Widget? additionalContent;
  final EdgeInsetsGeometry? padding;

  const HeroCard({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.additionalContent,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ??
          EdgeInsets.all(ResponsiveHelper.isMobile(context) ? 24 : 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
            Theme.of(context).colorScheme.tertiary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          icon,
          SizedBox(height: ResponsiveHelper.isMobile(context) ? 16 : 24),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: ResponsiveHelper.isMobile(context) ? 24 : 32,
              fontWeight: FontWeight.bold,
              color: Colors.black, // Changed to black for better contrast
            ),
            textAlign: TextAlign.center,
          ),
          if (subtitle != null) ...[
            SizedBox(height: 12),
            Text(
              subtitle!,
              style: GoogleFonts.inter(
                fontSize: ResponsiveHelper.isMobile(context) ? 16 : 18,
                fontWeight: FontWeight.w500,
                color: Colors.black, // Changed to black for better contrast
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (additionalContent != null) ...[
            SizedBox(height: ResponsiveHelper.isMobile(context) ? 16 : 24),
            additionalContent!,
          ],
        ],
      ),
    );
  }
}
