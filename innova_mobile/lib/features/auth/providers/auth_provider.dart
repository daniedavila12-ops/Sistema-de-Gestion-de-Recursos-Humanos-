// CREADO POR: DANIEL INNOVA

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';

import '../../../core/api/api_client.dart';
import '../models/usuario_model.dart'; // Importar el modelo de usuario

final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;
  final Usuario? user;
  final List<String> permisos;

  bool get isAdmin => user?.rolId == 1;

  AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.error,
    this.user,
    this.permisos = const [],
  });

  bool hasAccess(String module) {
    if (isAdmin) return true;
    return permisos.contains(module);
  }

  // Es útil tener un método copyWith para actualizar el estado
  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
    Usuario? user,
    List<String>? permisos,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      user: user ?? this.user,
      permisos: permisos ?? this.permisos,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    _checkSession();
    return AuthState();
  }

  Future<void> _checkSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final userString = prefs.getString('user_data');
    final permisosString = prefs.getString('auth_permisos');

    if (token != null && userString != null) {
      try {
        final userData = jsonDecode(userString);
        final user = Usuario.fromJson(userData);
        
        List<String> permisos = [];
        if (permisosString != null) {
          final decoded = jsonDecode(permisosString);
          if (decoded is List) {
            permisos = decoded.cast<String>();
          } else if (decoded == 'ALL') {
            // isAdmin manejará el ALL internamente, pero guardamos vacía o un indicador
            permisos = ['ALL'];
          }
        }
        
        state = AuthState(isAuthenticated: true, user: user, permisos: permisos);
      } catch (e) {
        // Si hay un error al decodificar, limpiar la sesión
        await prefs.remove('auth_token');
        await prefs.remove('user_data');
        await prefs.remove('auth_permisos');
        state = AuthState();
      }
    } else {
      state = AuthState();
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await apiClient.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      final token = response.data['token'];
      final userData = response.data['usuario'];
      final user = Usuario.fromJson(userData);

      // Obtener permisos dinámicos del rol
      List<String> permisos = [];
      try {
        final permRes = await apiClient.get('/dashboard-permisos/${user.rolId}');
        if (permRes.data is List) {
          permisos = List<String>.from(permRes.data);
        } else if (permRes.data == 'ALL') {
          permisos = ['ALL'];
        }
      } catch (e) {
        debugPrint("Error obteniendo permisos: $e");
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      await prefs.setString('user_data', jsonEncode(userData)); // Guardar datos del usuario
      await prefs.setString('auth_permisos', jsonEncode(permisos)); // Guardar permisos

      state = AuthState(isAuthenticated: true, user: user, permisos: permisos);
      return true;
    } catch (e) {
      debugPrint("Error de login detallado: $e");
      state = AuthState(
        isAuthenticated: false,
        error: 'Error: ${e.toString()}',
      );
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data'); // Limpiar también los datos del usuario
    await prefs.remove('auth_permisos'); // Limpiar permisos
    state = AuthState(); // Restablecer al estado inicial
  }
}