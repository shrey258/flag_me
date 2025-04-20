import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/message_service.dart';
import '../utils/responsive_helper.dart';

class MessageGeneratorScreen extends StatefulWidget {
  const MessageGeneratorScreen({super.key});

  @override
  State<MessageGeneratorScreen> createState() => _MessageGeneratorScreenState();
}

class _MessageGeneratorScreenState extends State<MessageGeneratorScreen> {
  // Helper method to build a section with a title and children
  Widget _buildSection(ThemeData theme, {required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.secondary,
          ),
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _occasionController = TextEditingController();
  
  String _gender = 'Male';
  String _relationship = 'Friend';
  int _messageLength = 100;
  
  bool _isLoading = false;
  String? _generatedMessage;
  String? _errorMessage;

  final List<String> _genderOptions = ['Male', 'Female', 'Other'];
  final List<String> _relationshipOptions = [
    'Friend', 
    'Best Friend', 
    'Lover', 
    'Brother/Sister', 
    'Parent', 
    'Child', 
    'Boss', 
    'Teacher', 
    'Relative', 
    'Professional'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _occasionController.dispose();
    super.dispose();
  }

  Future<void> _generateMessage() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final message = await MessageService().generateMessage(
        name: _nameController.text,
        age: int.parse(_ageController.text),
        occasion: _occasionController.text,
        gender: _gender,
        relationship: _relationship,
        length: _messageLength,
      );

      setState(() {
        _generatedMessage = message;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error generating message: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _copyToClipboard() {
    if (_generatedMessage != null) {
      Clipboard.setData(ClipboardData(text: _generatedMessage!));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Message copied to clipboard!',
            style: GoogleFonts.inter(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF1E1E1E),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSmallScreen = ResponsiveHelper.isSmallScreen(context);
    
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
                'Custom Message Generator',
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
                  // Header description
                  Text(
                    'Create Personalized Messages',
                    style: GoogleFonts.poppins(
                      fontSize: isSmallScreen ? 18 : 22,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Generate heartfelt, personalized messages for any occasion with our AI-powered message generator.',
                    style: GoogleFonts.inter(
                      fontSize: isSmallScreen ? 14 : 16,
                      color: theme.colorScheme.secondary.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Form
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
                            title: 'Recipient Details',
                            children: [
                        
                              TextFormField(
                                controller: _nameController,
                                decoration: InputDecoration(
                                  labelText: 'Recipient\'s Name',
                                  labelStyle: GoogleFonts.inter(),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  prefixIcon: const Icon(Icons.person_outline),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter recipient\'s name';
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
                                  prefixIcon: const Icon(Icons.cake_outlined),
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter recipient\'s age';
                                  }
                                  final age = int.tryParse(value);
                                  if (age == null || age < 1 || age > 120) {
                                    return 'Please enter a valid age (1-120)';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              
                              TextFormField(
                                controller: _occasionController,
                                decoration: InputDecoration(
                                  labelText: 'Occasion',
                                  labelStyle: GoogleFonts.inter(),
                                  hintText: 'E.g., Birthday, Anniversary, Graduation',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  prefixIcon: const Icon(Icons.celebration_outlined),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter the occasion';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          
                          _buildSection(
                            theme,
                            title: 'Additional Details',
                            children: [
                              DropdownButtonFormField<String>(
                                value: _gender,
                                decoration: InputDecoration(
                                  labelText: 'Gender',
                                  labelStyle: GoogleFonts.inter(),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  prefixIcon: const Icon(Icons.people_outline),
                                ),
                                items: _genderOptions.map((gender) {
                                  return DropdownMenuItem(
                                    value: gender,
                                    child: Text(
                                      gender,
                                      style: GoogleFonts.inter(),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      _gender = value;
                                    });
                                  }
                                },
                              ),
                              const SizedBox(height: 16),
                              
                              DropdownButtonFormField<String>(
                                value: _relationship,
                                decoration: InputDecoration(
                                  labelText: 'Relationship',
                                  labelStyle: GoogleFonts.inter(),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  prefixIcon: const Icon(Icons.favorite_border),
                                ),
                                items: _relationshipOptions.map((relationship) {
                                  return DropdownMenuItem(
                                    value: relationship,
                                    child: Text(
                                      relationship,
                                      style: GoogleFonts.inter(),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      _relationship = value;
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                        
                          _buildSection(
                            theme,
                            title: 'Message Length',
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '$_messageLength words',
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: theme.colorScheme.secondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Slider(
                                    value: _messageLength.toDouble(),
                                    min: 10,
                                    max: 500,
                                    divisions: 49,
                                    label: '$_messageLength words',
                                    activeColor: theme.colorScheme.primary,
                                    inactiveColor: theme.colorScheme.primary.withOpacity(0.2),
                                    onChanged: (value) {
                                      setState(() {
                                        _messageLength = value.round();
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          
                          // Generate button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _generateMessage,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 2,
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.auto_awesome),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Generate Message',
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
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
                  
                  const SizedBox(height: 32),
                  
                  // Generated message section
                  if (_generatedMessage != null || _errorMessage != null)
                    Container(
                      width: double.infinity,
                      constraints: BoxConstraints(
                        maxWidth: isSmallScreen ? double.infinity : 600,
                      ),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: _errorMessage != null
                            ? Colors.red.shade50
                            : theme.colorScheme.tertiary,
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _errorMessage != null
                                    ? 'Error'
                                    : 'Your Personalized Message',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: _errorMessage != null
                                      ? Colors.red.shade700
                                      : theme.colorScheme.secondary,
                                ),
                              ),
                              if (_generatedMessage != null)
                                IconButton(
                                  icon: const Icon(Icons.copy),
                                  onPressed: _copyToClipboard,
                                  tooltip: 'Copy to clipboard',
                                  color: theme.colorScheme.primary,
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _errorMessage ?? _generatedMessage!,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              height: 1.5,
                              color: _errorMessage != null
                                  ? Colors.red.shade700
                                  : theme.colorScheme.secondary,
                            ),
                          ),
                          if (_generatedMessage != null) ...[
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.refresh),
                                label: Text(
                                  'Regenerate Message',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                onPressed: _isLoading ? null : _generateMessage,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: theme.colorScheme.primary,
                                  side: BorderSide(
                                    color: theme.colorScheme.primary,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
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
          ),
        ],
      ),
    );
  }
}
