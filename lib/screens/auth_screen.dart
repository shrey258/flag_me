import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../utils/responsive_helper.dart';

enum AuthMode { login, signup }

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  AuthMode _authMode = AuthMode.login;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _switchAuthMode() {
    setState(() {
      _authMode = _authMode == AuthMode.login ? AuthMode.signup : AuthMode.login;
      _emailController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        print('Submitting auth form - Mode: $_authMode');
        print('Email: ${_emailController.text.trim()}');
        
        if (_authMode == AuthMode.login) {
          await ref.read(authStateProvider.notifier).signIn(
                _emailController.text.trim(),
                _passwordController.text,
              );
        } else {
          await ref.read(authStateProvider.notifier).signUp(
                _emailController.text.trim(),
                _passwordController.text,
              );
        }
      } catch (e) {
        print('Auth form submission error: $e');
        if (mounted) {
          String errorMessage = 'Authentication failed';
          
          if (e.toString().contains('Invalid login credentials')) {
            errorMessage = 'Invalid email or password. Please check your credentials and try again.';
          } else if (e.toString().contains('Email not confirmed')) {
            errorMessage = 'Please verify your email address before logging in.';
          } else if (e.toString().contains('User already registered')) {
            errorMessage = 'An account with this email already exists. Please try logging in.';
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Theme.of(context).colorScheme.error,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      await ref.read(authStateProvider.notifier).signInWithGoogle();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authStateProvider);
    final isSmallScreen = ResponsiveHelper.isMobile(context);
    final containerWidth = ResponsiveHelper.getCardWidth(context);
    final padding = ResponsiveHelper.getScreenPadding(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.tertiary.withOpacity(0.1),
              theme.colorScheme.background,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: padding,
              child: Container(
                constraints: BoxConstraints(maxWidth: containerWidth),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo and Title
                    Center(
                      child: Container(
                        width: isSmallScreen ? 200 : 260,
                        height: isSmallScreen ? 200 : 260,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.primary.withOpacity(0.15),
                              blurRadius: 40,
                              offset: const Offset(0, 20),
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 28 : 32),
                    Text(
                      'Flag Me',
                      style: GoogleFonts.poppins(
                        fontSize: isSmallScreen ? 32 : 36,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.secondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _authMode == AuthMode.login
                          ? 'Welcome!'
                          : 'Create your account',
                      style: GoogleFonts.inter(
                        fontSize: isSmallScreen ? 14 : 16,
                        color: theme.colorScheme.secondary.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Error Message
                    if (authState case Error(:final message))
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          message,
                          style: GoogleFonts.inter(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    // Form
                    Container(
                      padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
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
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // Email Field
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              enabled: authState is! Loading,
                              style: GoogleFonts.inter(
                                fontSize: isSmallScreen ? 14 : 16,
                                color: theme.colorScheme.secondary,
                              ),
                              decoration: InputDecoration(
                                labelText: 'Email',
                                labelStyle: GoogleFonts.inter(
                                  color: theme.colorScheme.secondary.withOpacity(0.7),
                                ),
                                hintText: 'Enter your email',
                                hintStyle: GoogleFonts.inter(
                                  color: theme.colorScheme.secondary.withOpacity(0.5),
                                ),
                                prefixIcon: Icon(
                                  Icons.email_outlined,
                                  color: theme.colorScheme.primary,
                                  size: isSmallScreen ? 20 : 22,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: theme.colorScheme.primary.withOpacity(0.3),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: theme.colorScheme.primary,
                                    width: 2,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                    color: Colors.red,
                                    width: 1,
                                  ),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                    color: Colors.red,
                                    width: 2,
                                  ),
                                ),
                                errorStyle: GoogleFonts.inter(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                                filled: true,
                                fillColor: theme.colorScheme.surface,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                if (!value.contains('@') || !value.contains('.')) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Password Field
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              enabled: authState is! Loading,
                              style: GoogleFonts.inter(
                                fontSize: isSmallScreen ? 14 : 16,
                                color: theme.colorScheme.secondary,
                              ),
                              decoration: InputDecoration(
                                labelText: 'Password',
                                labelStyle: GoogleFonts.inter(
                                  color: theme.colorScheme.secondary.withOpacity(0.7),
                                ),
                                hintText: 'Enter your password',
                                hintStyle: GoogleFonts.inter(
                                  color: theme.colorScheme.secondary.withOpacity(0.5),
                                ),
                                prefixIcon: Icon(
                                  Icons.lock_outline,
                                  color: theme.colorScheme.primary,
                                  size: isSmallScreen ? 20 : 22,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: theme.colorScheme.primary,
                                    size: isSmallScreen ? 20 : 22,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: theme.colorScheme.primary.withOpacity(0.3),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: theme.colorScheme.primary,
                                    width: 2,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                    color: Colors.red,
                                    width: 1,
                                  ),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                    color: Colors.red,
                                    width: 2,
                                  ),
                                ),
                                errorStyle: GoogleFonts.inter(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                                filled: true,
                                fillColor: theme.colorScheme.surface,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Confirm Password Field (Sign Up only)
                            if (_authMode == AuthMode.signup) ...[
                              TextFormField(
                                controller: _confirmPasswordController,
                                obscureText: _obscureConfirmPassword,
                                enabled: authState is! Loading,
                                style: GoogleFonts.inter(
                                  fontSize: isSmallScreen ? 14 : 16,
                                  color: theme.colorScheme.secondary,
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Confirm Password',
                                  labelStyle: GoogleFonts.inter(
                                    color: theme.colorScheme.secondary.withOpacity(0.7),
                                  ),
                                  hintText: 'Confirm your password',
                                  hintStyle: GoogleFonts.inter(
                                    color: theme.colorScheme.secondary.withOpacity(0.5),
                                  ),
                                  prefixIcon: Icon(
                                    Icons.lock_outline,
                                    color: theme.colorScheme.primary,
                                    size: isSmallScreen ? 20 : 22,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureConfirmPassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: theme.colorScheme.primary,
                                      size: isSmallScreen ? 20 : 22,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscureConfirmPassword = !_obscureConfirmPassword;
                                      });
                                    },
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      color: theme.colorScheme.primary.withOpacity(0.3),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      color: theme.colorScheme.primary,
                                      width: 2,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: const BorderSide(
                                      color: Colors.red,
                                      width: 1,
                                    ),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: const BorderSide(
                                      color: Colors.red,
                                      width: 2,
                                    ),
                                  ),
                                  errorStyle: GoogleFonts.inter(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                  filled: true,
                                  fillColor: theme.colorScheme.surface,
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please confirm your password';
                                  }
                                  if (value != _passwordController.text) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                            ],

                            // Submit Button
                            Container(
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    theme.colorScheme.primary,
                                    theme.colorScheme.primary.withOpacity(0.8),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.colorScheme.primary.withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: authState is Loading ? null : _submitForm,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  foregroundColor: Colors.black,
                                  elevation: 0,
                                  minimumSize: const Size.fromHeight(56),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: authState is Loading
                                    ? SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            theme.colorScheme.onPrimary,
                                          ),
                                        ),
                                      )
                                    : Text(
                                        _authMode == AuthMode.login ? 'Login' : 'Sign Up',
                                        style: GoogleFonts.poppins(
                                          fontSize: isSmallScreen ? 16 : 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // OR Divider
                            Row(
                              children: [
                                Expanded(
                                  child: Divider(
                                    color: theme.colorScheme.secondary.withOpacity(0.2),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    'OR',
                                    style: GoogleFonts.inter(
                                      color: theme.colorScheme.secondary.withOpacity(0.5),
                                      fontSize: isSmallScreen ? 12 : 14,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    color: theme.colorScheme.secondary.withOpacity(0.2),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Social Sign In Buttons
                            OutlinedButton.icon(
                              onPressed: authState is Loading ? null : _signInWithGoogle,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: theme.colorScheme.secondary,
                                side: BorderSide(
                                  color: theme.colorScheme.primary.withOpacity(0.3),
                                ),
                                padding: EdgeInsets.symmetric(
                                  vertical: isSmallScreen ? 12 : 16,
                                  horizontal: 24,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              icon: Image.asset(
                                'assets/google_logo.png',
                                height: isSmallScreen ? 20 : 24,
                              ),
                              label: Text(
                                'Continue with Google',
                                style: GoogleFonts.inter(
                                  fontSize: isSmallScreen ? 14 : 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Switch Auth Mode Button
                            TextButton(
                              onPressed: authState is Loading ? null : _switchAuthMode,
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: Text(
                                _authMode == AuthMode.login
                                    ? 'Don\'t have an account? Sign Up'
                                    : 'Already have an account? Login',
                                style: GoogleFonts.inter(
                                  fontSize: isSmallScreen ? 14 : 15,
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w500,
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
          ),
        ),
      ),
    );
  }
}
