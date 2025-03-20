import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/responsive_helper.dart';
import '../models/gift_preference.dart';
import 'gift_recommendations_screen.dart';

class GiftPreferencesScreen extends ConsumerStatefulWidget {
  const GiftPreferencesScreen({super.key});

  @override
  ConsumerState<GiftPreferencesScreen> createState() => _GiftPreferencesScreenState();
}

class _GiftPreferencesScreenState extends ConsumerState<GiftPreferencesScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _interestsController = TextEditingController();
  final TextEditingController _additionalNotesController = TextEditingController();
  final TextEditingController _occasionController = TextEditingController();
  String? _selectedGender;
  String? _selectedBudget;
  String? _selectedRelationship;
  final List<String> _interests = [];

  final List<String> _budgetOptions = ['low', 'medium', 'high'];
  final List<String> _relationshipOptions = [
    'friend',
    'family',
    'partner',
    'colleague',
    'other'
  ];
  final List<String> _genderOptions = ['male', 'female', 'non-binary', 'other'];

  void _addInterest() {
    if (_interestsController.text.isNotEmpty) {
      setState(() {
        _interests.add(_interestsController.text);
        _interestsController.clear();
      });
    }
  }

  void _removeInterest(String interest) {
    setState(() {
      _interests.remove(interest);
    });
  }

  void _getGiftSuggestions() {
    if (_formKey.currentState!.validate()) {
      final preference = GiftPreference(
        age: int.tryParse(_ageController.text),
        gender: _selectedGender,
        interests: _interests,
        occasion: _occasionController.text,
        budget: _selectedBudget,
        relationship: _selectedRelationship,
        additionalNotes: _additionalNotesController.text,
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GiftRecommendationsScreen(
            preference: preference,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSmallScreen = ResponsiveHelper.isMobile(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            floating: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Gift Preferences',
                style: GoogleFonts.poppins(
                  color: theme.colorScheme.secondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tell us about your gift recipient',
                    style: GoogleFonts.poppins(
                      fontSize: isSmallScreen ? 18 : 22,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Help us find the perfect gift by providing some details',
                    style: GoogleFonts.inter(
                      fontSize: isSmallScreen ? 14 : 16,
                      color: theme.colorScheme.secondary.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Form(
                    key: _formKey,
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withOpacity(0.08),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSection(
                            theme,
                            title: 'Basic Information',
                            children: [
                              TextFormField(
                                controller: _occasionController,
                                decoration: InputDecoration(
                                  labelText: 'Occasion',
                                  labelStyle: GoogleFonts.inter(),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter an occasion';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _ageController,
                                decoration: InputDecoration(
                                  labelText: 'Age',
                                  labelStyle: GoogleFonts.inter(),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                              const SizedBox(height: 16),
                              DropdownButtonFormField<String>(
                                value: _selectedGender,
                                decoration: InputDecoration(
                                  labelText: 'Gender',
                                  labelStyle: GoogleFonts.inter(),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                items: _genderOptions.map((gender) => DropdownMenuItem(
                                  value: gender,
                                  child: Text(
                                    gender.toUpperCase(),
                                    style: GoogleFonts.inter(),
                                  ),
                                )).toList(),
                                onChanged: (value) => setState(() => _selectedGender = value),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          _buildSection(
                            theme,
                            title: 'Interests & Preferences',
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _interestsController,
                                      decoration: InputDecoration(
                                        labelText: 'Add Interest',
                                        labelStyle: GoogleFonts.inter(),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: IconButton(
                                      icon: const Icon(Icons.add, color: Colors.black),
                                      onPressed: _addInterest,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _interests.map((interest) => Chip(
                                  label: Text(
                                    interest,
                                    style: GoogleFonts.inter(color: Colors.black),
                                  ),
                                  backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                                  deleteIcon: const Icon(Icons.close, size: 18),
                                  onDeleted: () => _removeInterest(interest),
                                )).toList(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          _buildSection(
                            theme,
                            title: 'Gift Details',
                            children: [
                              DropdownButtonFormField<String>(
                                value: _selectedBudget,
                                decoration: InputDecoration(
                                  labelText: 'Budget Range',
                                  labelStyle: GoogleFonts.inter(),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                items: _budgetOptions.map((budget) => DropdownMenuItem(
                                  value: budget,
                                  child: Text(
                                    budget.toUpperCase(),
                                    style: GoogleFonts.inter(),
                                  ),
                                )).toList(),
                                onChanged: (value) => setState(() => _selectedBudget = value),
                              ),
                              const SizedBox(height: 16),
                              DropdownButtonFormField<String>(
                                value: _selectedRelationship,
                                decoration: InputDecoration(
                                  labelText: 'Relationship',
                                  labelStyle: GoogleFonts.inter(),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                items: _relationshipOptions.map((relationship) => DropdownMenuItem(
                                  value: relationship,
                                  child: Text(
                                    relationship.toUpperCase(),
                                    style: GoogleFonts.inter(),
                                  ),
                                )).toList(),
                                onChanged: (value) => setState(() => _selectedRelationship = value),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _additionalNotesController,
                                decoration: InputDecoration(
                                  labelText: 'Additional Notes',
                                  labelStyle: GoogleFonts.inter(),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                maxLines: 3,
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _getGiftSuggestions,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Get Gift Suggestions',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(ThemeData theme, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.secondary,
          ),
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  @override
  void dispose() {
    _ageController.dispose();
    _interestsController.dispose();
    _additionalNotesController.dispose();
    _occasionController.dispose();
    super.dispose();
  }
}
