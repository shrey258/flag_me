import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

class AuthService {
  final _supabase = Supabase.instance.client;

  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      print('Starting sign in process for email: $email');
      print('Current auth state before sign in: ${_supabase.auth.currentSession}');

      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      print('Sign in response received');
      print('User: ${response.user?.email}');
      print('Session: ${response.session?.accessToken}');

      if (response.user == null) {
        print('Sign in failed: No user returned');
        throw AuthException('Failed to get user after sign in');
      }

      // Verify session is stored
      final currentSession = await _supabase.auth.currentSession;
      print('Current session after sign in: $currentSession');

      return response;
    } catch (e) {
      print('Sign in error details:');
      print('Error type: ${e.runtimeType}');
      print('Error message: $e');
      if (e is AuthException) {
        print('Supabase error message: ${e.message}');
      }
      throw _handleAuthError(e);
    }
  }

  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    try {
      print('Starting sign up process for email: $email');
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      print('Sign up response received');
      print('User: ${response.user?.email}');
      print('Session: ${response.session?.accessToken}');

      return response;
    } catch (e) {
      print('Sign up error: $e');
      throw _handleAuthError(e);
    }
  }

  Future<AuthResponse> signInWithGoogle() async {
    try {
      // Start OAuth flow
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: Uri.base.origin,
      );

      // For web, we need to wait for the OAuth redirect
      final authState = await _supabase.auth.onAuthStateChange.firstWhere(
        (state) => state.event == AuthChangeEvent.signedIn,
        orElse: () => throw AuthException('Google sign-in timeout'),
      );

      if (authState.session == null) {
        throw AuthException('Failed to get session after Google sign-in');
      }

      return AuthResponse(
        user: authState.session!.user,
        session: authState.session,
      );
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  Future<void> signOut() async {
    try {
      print('Starting sign out process');
      print('Current session before sign out: ${_supabase.auth.currentSession}');
      
      await _supabase.auth.signOut();
      
      print('Sign out completed');
      print('Current session after sign out: ${_supabase.auth.currentSession}');
    } catch (e) {
      print('Sign out error: $e');
      throw _handleAuthError(e);
    }
  }

  User? get currentUser => _supabase.auth.currentUser;

  AuthException _handleAuthError(dynamic error) {
    print('Handling auth error');
    print('Error type: ${error.runtimeType}');
    print('Error details: $error');

    if (error is AuthException) {
      print('Supabase auth error: ${error.message}');
      return error;
    } else if (error is String) {
      return AuthException(error);
    }
    return AuthException('An unexpected error occurred: ${error.toString()}');
  }

  // Helper method to check current auth state
  Future<void> checkAuthState() async {
    print('\n--- Current Auth State ---');
    print('Current user: ${currentUser?.email}');
    print('Has session: ${_supabase.auth.currentSession != null}');
    if (_supabase.auth.currentSession != null) {
      print('Session expires at: ${_supabase.auth.currentSession?.expiresAt}');
    }
    print('------------------------\n');
  }
}
