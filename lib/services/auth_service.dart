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
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
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
      await _supabase.auth.signOut();
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  User? get currentUser => _supabase.auth.currentUser;

  AuthException _handleAuthError(dynamic error) {
    if (error is AuthException) {
      return error;
    } else if (error is String) {
      return AuthException(error);
    }
    return AuthException('An unexpected error occurred');
  }
}
