import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/responsive_helper.dart';
import '../models/gift_preference.dart';
import 'gift_recommendations_screen.dart';

class GiftPreferencesScreen extends ConsumerStatefulWidget {
  final String? occasionId; // Optional occasion ID when coming from occasion details
  final String? occasionName; // Optional occasion name to pre-fill
  
  const GiftPreferencesScreen({
    super.key, 
    this.occasionId,
    this.occasionName,
  });

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
  String? _selectedRelationship;
  final List<String> _interests = [];

  // Budget range values
  RangeValues _budgetRange = const RangeValues(1000, 5000);
  static const double _minBudgetValue = 0;
  static const double _maxBudgetValue = 500000;

  // Text controllers for manual budget entry
  final TextEditingController _minBudgetController = TextEditingController(text: '1000');
  final TextEditingController _maxBudgetController = TextEditingController(text: '5000');

  // Platform selection
  bool _showPlatformFilter = false;
  final Map<String, bool> _selectedPlatforms = {
    'Amazon': true,
    'Flipkart': true,
    'Myntra': true,
  };

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

  @override
  void initState() {
    super.initState();
    // Pre-fill occasion field if provided
    if (widget.occasionName != null) {
      _occasionController.text = widget.occasionName!;
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Get selected platforms
      List<String> platforms = _selectedPlatforms.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();

      final preference = GiftPreference(
        age: _ageController.text.isNotEmpty ? int.parse(_ageController.text) : null,
        gender: _selectedGender,
        interests: _interests,
        occasion: _occasionController.text.isEmpty ? null : _occasionController.text,
        minBudget: double.tryParse(_minBudgetController.text),
        maxBudget: double.tryParse(_maxBudgetController.text),
        relationship: _selectedRelationship,
        additionalNotes: _additionalNotesController.text.isEmpty
            ? null
            : _additionalNotesController.text,
        platforms: platforms.isEmpty ? null : platforms,
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GiftRecommendationsScreen(
            preference: preference,
            occasionId: widget.occasionId,
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
      backgroundColor: theme.colorScheme.surface,
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
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Budget Range: ₹${_budgetRange.start.toInt()} - ₹${_budgetRange.end.toInt()}',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: theme.colorScheme.secondary,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  // Manual budget entry text fields
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: _minBudgetController,
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                            labelText: 'Min Budget (₹)',
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          ),
                                          onChanged: (value) {
                                            if (value.isNotEmpty) {
                                              final minValue = double.tryParse(value) ?? _minBudgetValue;
                                              setState(() {
                                                _budgetRange = RangeValues(
                                                  minValue.clamp(_minBudgetValue, _budgetRange.end),
                                                  _budgetRange.end
                                                );
                                              });
                                            }
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: TextField(
                                          controller: _maxBudgetController,
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                            labelText: 'Max Budget (₹)',
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          ),
                                          onChanged: (value) {
                                            if (value.isNotEmpty) {
                                              final maxValue = double.tryParse(value) ?? _maxBudgetValue;
                                              setState(() {
                                                _budgetRange = RangeValues(
                                                  _budgetRange.start,
                                                  maxValue.clamp(_budgetRange.start, _maxBudgetValue)
                                                );
                                              });
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  
                                  const SizedBox(height: 16),
                                  SliderTheme(
                                    data: SliderThemeData(
                                      activeTrackColor: theme.colorScheme.primary,
                                      inactiveTrackColor: theme.colorScheme.primary.withOpacity(0.2),
                                      thumbColor: theme.colorScheme.primary,
                                      overlayColor: theme.colorScheme.primary.withOpacity(0.2),
                                      valueIndicatorColor: theme.colorScheme.primary,
                                      valueIndicatorTextStyle: GoogleFonts.inter(
                                        color: Colors.black,
                                      ),
                                    ),
                                    child: RangeSlider(
                                      values: _budgetRange,
                                      min: _minBudgetValue,
                                      max: _maxBudgetValue,
                                      divisions: 100,
                                      labels: RangeLabels(
                                        '₹${_budgetRange.start.toInt()}',
                                        '₹${_budgetRange.end.toInt()}',
                                      ),
                                      onChanged: (RangeValues values) {
                                        setState(() {
                                          _budgetRange = values;
                                          _minBudgetController.text = values.start.toInt().toString();
                                          _maxBudgetController.text = values.end.toInt().toString();
                                        });
                                      },
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '₹${_minBudgetValue.toInt()}',
                                        style: GoogleFonts.inter(
                                          color: theme.colorScheme.secondary.withOpacity(0.7),
                                        ),
                                      ),
                                      Text(
                                        '₹${_maxBudgetValue.toInt()}',
                                        style: GoogleFonts.inter(
                                          color: theme.colorScheme.secondary.withOpacity(0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
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
                          _buildSection(
                            theme,
                            title: 'Shopping Preferences',
                            children: [
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(
                                  'E-commerce Platforms',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                subtitle: Text(
                                  'Select websites to search for gifts',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: theme.colorScheme.secondary.withOpacity(0.7),
                                  ),
                                ),
                                trailing: Switch(
                                  value: _showPlatformFilter,
                                  activeColor: const Color(0xFFD4AF37),
                                  onChanged: (value) {
                                    setState(() {
                                      _showPlatformFilter = value;
                                    });
                                  },
                                ),
                              ),
                              if (_showPlatformFilter)
                                Padding(
                                  padding: const EdgeInsets.only(left: 16.0, top: 8.0),
                                  child: Column(
                                    children: _selectedPlatforms.entries.map((entry) {
                                      return CheckboxListTile(
                                        contentPadding: EdgeInsets.zero,
                                        title: Text(
                                          entry.key,
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        value: entry.value,
                                        activeColor: _getPlatformColor(entry.key),
                                        controlAffinity: ListTileControlAffinity.leading,
                                        dense: true,
                                        onChanged: (bool? value) {
                                          setState(() {
                                            _selectedPlatforms[entry.key] = value ?? false;
                                          });
                                        },
                                      );
                                    }).toList(),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _submitForm,
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

  Color _getPlatformColor(String platform) {
    switch (platform) {
      case 'Amazon':
        return Colors.orange[800]!;
      case 'Flipkart':
        return Colors.blue[800]!;
      case 'Myntra':
        return Colors.pink[700]!;
      default:
        return Colors.grey[700]!;
    }
  }

  @override
  void dispose() {
    _ageController.dispose();
    _interestsController.dispose();
    _additionalNotesController.dispose();
    _occasionController.dispose();
    _minBudgetController.dispose();
    _maxBudgetController.dispose();
    super.dispose();
  }
}
