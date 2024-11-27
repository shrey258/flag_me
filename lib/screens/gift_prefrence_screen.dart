import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/gift_preference.dart';
import '../models/enums.dart';
import '../utils/responsive_helper.dart';
import 'package:uuid/uuid.dart';

class GiftPreferenceScreen extends ConsumerStatefulWidget {
  final String occasionId;
  final RelationType relationType;

  const GiftPreferenceScreen({
    super.key,
    required this.occasionId,
    required this.relationType,
  });

  @override
  ConsumerState<GiftPreferenceScreen> createState() => _GiftPreferenceScreenState();
}

class _GiftPreferenceScreenState extends ConsumerState<GiftPreferenceScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form state
  RangeValues _budgetRange = const RangeValues(0, 1000);
  final Set<GiftCategory> _selectedCategories = {};
  final Set<GiftCategory> _excludedCategories = {};
  final Set<String> _selectedColors = {};
  final Map<String, String> _selectedSizes = {};
  final List<String> _interests = [];
  final TextEditingController _interestsController = TextEditingController();

  @override
  void dispose() {
    _interestsController.dispose();
    super.dispose();
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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildBudgetSection(),
                        SizedBox(height: ResponsiveHelper.isMobile(context) ? 24 : 32),
                        _buildCategoriesSection(),
                        SizedBox(height: ResponsiveHelper.isMobile(context) ? 24 : 32),
                        _buildColorsSection(),
                        SizedBox(height: ResponsiveHelper.isMobile(context) ? 24 : 32),
                        _buildSizesSection(),
                        SizedBox(height: ResponsiveHelper.isMobile(context) ? 24 : 32),
                        _buildInterestsSection(),
                        SizedBox(height: ResponsiveHelper.isMobile(context) ? 32 : 40),
                        _buildSubmitButton(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
        fontSize: ResponsiveHelper.isMobile(context) ? 20 : 24,
      ),
    );
  }

  Widget _buildBudgetSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Budget Range'),
        const SizedBox(height: 12),
        RangeSlider(
          values: _budgetRange,
          min: 0,
          max: 1000,
          divisions: 20,
          activeColor: Theme.of(context).colorScheme.primary,
          inactiveColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
          labels: RangeLabels(
            '\$${_budgetRange.start.round()}',
            '\$${_budgetRange.end.round()}',
          ),
          onChanged: (RangeValues values) {
            setState(() {
              _budgetRange = values;
            });
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '\$${_budgetRange.start.round()}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              '\$${_budgetRange.end.round()}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoriesSection() {
    final availableCategories = GiftCategoryExtension.getCategoriesByRelationType()[widget.relationType] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Gift Categories'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: availableCategories.map((category) {
            return FilterChip(
              label: Text(category.displayName),
              selected: _selectedCategories.contains(category),
              onSelected: (bool selected) {
                setState(() {
                  if (selected) {
                    _selectedCategories.add(category);
                    _excludedCategories.remove(category);
                  } else {
                    _selectedCategories.remove(category);
                    _excludedCategories.add(category);
                  }
                });
              },
              backgroundColor: Colors.white,
              selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              checkmarkColor: Theme.of(context).colorScheme.primary,
              labelStyle: Theme.of(context).textTheme.bodyMedium,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildColorsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Preferred Colors'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: GiftPreference.getCommonColors().map((color) {
            return FilterChip(
              label: Text(color),
              selected: _selectedColors.contains(color),
              onSelected: (bool selected) {
                setState(() {
                  if (selected) {
                    _selectedColors.add(color);
                  } else {
                    _selectedColors.remove(color);
                  }
                });
              },
              backgroundColor: Colors.white,
              selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              checkmarkColor: Theme.of(context).colorScheme.primary,
              labelStyle: Theme.of(context).textTheme.bodyMedium,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSizesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Sizes'),
        const SizedBox(height: 12),
        ...GiftPreference.getSizeCategories().entries.map(
          (entry) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.key,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: entry.value.map((size) {
                  final isSelected = _selectedSizes[entry.key] == size;
                  return ChoiceChip(
                    label: Text(size),
                    selected: isSelected,
                    onSelected: (bool selected) {
                      setState(() {
                        if (selected) {
                          _selectedSizes[entry.key] = size;
                        } else {
                          _selectedSizes.remove(entry.key);
                        }
                      });
                    },
                    backgroundColor: Colors.white,
                    selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInterestsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Interests'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _interestsController,
                decoration: InputDecoration(
                  labelText: 'Add interests (e.g., reading, cooking)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onFieldSubmitted: (value) {
                  if (value.isNotEmpty) {
                    setState(() {
                      _interests.add(value);
                      _interestsController.clear();
                    });
                  }
                },
              ),
            ),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                if (_interestsController.text.isNotEmpty) {
                  setState(() {
                    _interests.add(_interestsController.text);
                    _interestsController.clear();
                  });
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _interests.map((interest) {
            return Chip(
              label: Text(interest),
              onDeleted: () {
                setState(() {
                  _interests.remove(interest);
                });
              },
              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
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
      child: ElevatedButton(
        onPressed: _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          elevation: 0,
          padding: EdgeInsets.symmetric(
            vertical: ResponsiveHelper.isMobile(context) ? 16 : 20,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          'Save Preferences',
          style: GoogleFonts.poppins(
            fontSize: ResponsiveHelper.isMobile(context) ? 16 : 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final preference = GiftPreference(
        id: const Uuid().v4(),
        occasionId: widget.occasionId,
        relationType: widget.relationType,
        minBudget: _budgetRange.start,
        maxBudget: _budgetRange.end,
        preferredColors: _selectedColors.toList(),
        sizes: _selectedSizes,
        interests: _interests,
        selectedCategories: _selectedCategories.toList(),
        excludedCategories: _excludedCategories.toList(),
        lastUpdated: DateTime.now(),
      );

      print('Created preference: $preference');
      Navigator.pop(context);
    }
  }
}
