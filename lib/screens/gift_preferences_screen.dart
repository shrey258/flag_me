
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/gift_preference.dart';
import 'gift_recommendations_screen.dart';

class GiftPreferencesScreen extends ConsumerStatefulWidget {
  final String occasionId;
  final String occasion;

  const GiftPreferencesScreen({
    super.key,
    required this.occasionId,
    required this.occasion,
  });

  @override
  ConsumerState<GiftPreferencesScreen> createState() => _GiftPreferencesScreenState();
}

class _GiftPreferencesScreenState extends ConsumerState<GiftPreferencesScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _interestsController = TextEditingController();
  final TextEditingController _additionalNotesController = TextEditingController();
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
        occasion: widget.occasion,
        budget: _selectedBudget,
        relationship: _selectedRelationship,
        additionalNotes: _additionalNotesController.text,
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GiftRecommendationsScreen(
            occasionId: widget.occasionId,
            preference: preference,
          ),
        ),
      );
    }
  }

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
                'Gift Preferences',
                style: GoogleFonts.playfairDisplay(
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _ageController,
                      decoration: const InputDecoration(labelText: 'Age'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedGender,
                      decoration: const InputDecoration(labelText: 'Gender'),
                      items: _genderOptions.map((gender) => DropdownMenuItem(
                        value: gender,
                        child: Text(gender),
                      )).toList(),
                      onChanged: (value) => setState(() => _selectedGender = value),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _interestsController,
                            decoration: const InputDecoration(labelText: 'Add Interest'),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: _addInterest,
                        ),
                      ],
                    ),
                    Wrap(
                      spacing: 8,
                      children: _interests.map((interest) => Chip(
                        label: Text(interest),
                        onDeleted: () => _removeInterest(interest),
                      )).toList(),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedBudget,
                      decoration: const InputDecoration(labelText: 'Budget'),
                      items: _budgetOptions.map((budget) => DropdownMenuItem(
                        value: budget,
                        child: Text(budget.toUpperCase()),
                      )).toList(),
                      onChanged: (value) => setState(() => _selectedBudget = value),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedRelationship,
                      decoration: const InputDecoration(labelText: 'Relationship'),
                      items: _relationshipOptions.map((relationship) => DropdownMenuItem(
                        value: relationship,
                        child: Text(relationship),
                      )).toList(),
                      onChanged: (value) => setState(() => _selectedRelationship = value),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _additionalNotesController,
                      decoration: const InputDecoration(labelText: 'Additional Notes'),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _getGiftSuggestions,
                      child: const Text('Get Gift Suggestions'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _ageController.dispose();
    _interestsController.dispose();
    _additionalNotesController.dispose();
    super.dispose();
  }
}
