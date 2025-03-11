import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});

sealed class AuthState {
  const AuthState();
}

class Initial extends AuthState {
  const Initial();
}

class Loading extends AuthState {
  const Loading();
}

class Authenticated extends AuthState {
  final User user;
  const Authenticated(this.user);
}

class Error extends AuthState {
  final String message;
  const Error(this.message);
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const Initial()) {
    _authService.authStateChanges.listen((event) {
      if (event.session != null) {
        state = Authenticated(event.session!.user);
      } else {
        state = const Initial();
      }
    });
  }

  Future<void> signIn(String email, String password) async {
    try {
      state = const Loading();
      final response = await _authService.signIn(email: email, password: password);
      state = Authenticated(response.user!);
    } catch (e) {
      state = Error(e.toString());
    }
  }

  Future<void> signUp(String email, String password) async {
    try {
      state = const Loading();
      final response = await _authService.signUp(email: email, password: password);
      state = Authenticated(response.user!);
    } catch (e) {
      state = Error(e.toString());
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      state = const Loading();
      final response = await _authService.signInWithGoogle();
      state = Authenticated(response.user!);
    } catch (e) {
      state = Error(e.toString());
    }
  }

  Future<void> signOut() async {
    try {
      state = const Loading();
      await _authService.signOut();
      state = const Initial();
    } catch (e) {
      state = Error(e.toString());
    }
  }
}
