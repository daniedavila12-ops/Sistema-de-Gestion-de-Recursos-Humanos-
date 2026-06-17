// CREADO POR: DANIEL INNOVA

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/api/api_client.dart';

final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;

  AuthState({this.isAuthenticated = false, this.isLoading = false, this.error});
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    // We can't await inside a synchronous build, but we can start the Future.
    // However, it's safer to just return the initial state and let the async check update it.
    _checkSession();
    return AuthState();
  }

  Future<void> _checkSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token != null) {
      state = AuthState(isAuthenticated: true);
    }
  }

  Future<bool> login(String email, String password) async {
    state = AuthState(isLoading: true);
    try {
      final response = await apiClient.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      final token = response.data['token'] ?? 'dummy_token';
      final userId = response.data['usuario']?['id']?.toString() ?? '1';
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      await prefs.setString('usuario_id', userId);

      state = AuthState(isAuthenticated: true, isLoading: false);
      return true;
    } catch (e) {
      state = AuthState(
        isAuthenticated: false,
        isLoading: false,
        error: 'Credenciales inválidas o error de conexión.',
      );
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    state = AuthState(isAuthenticated: false);
  }
}