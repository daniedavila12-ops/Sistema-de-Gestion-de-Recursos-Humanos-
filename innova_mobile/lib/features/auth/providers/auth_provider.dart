// CREADO POR: DANIEL INNOVA

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';

import '../../../core/api/api_client.dart';
import '../models/usuario_model.dart';
import '../models/permiso_granular_model.dart'; // Importar el modelo de permisos

final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;
  final String? token;
  final Usuario? user;
  final Map<String, PermisoGranular> permisos;

  bool get isAdmin => user?.rolId == 1;

  AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.error,
    this.token,
    this.user,
    this.permisos = const {},
  });

  bool hasAccess(String module) {
    if (isAdmin) return true;
    return permisos.containsKey(module) && permisos[module]!.puedeVer;
  }

  bool hasPermission(String modulo, String accion) {
    if (isAdmin) return true;
    if (!permisos.containsKey(modulo)) return false;
    final p = permisos[modulo]!;
    switch (accion) {
      case 'puedeCrear': return p.puedeCrear;
      case 'puedeEditar': return p.puedeEditar;
      case 'puedeEliminar': return p.puedeEliminar;
      case 'puedeVer': return p.puedeVer;
      default: return false;
    }
  }

  // Es útil tener un método copyWith para actualizar el estado
  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
    String? token,
    Usuario? user,
    Map<String, PermisoGranular>? permisos,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      token: token ?? this.token,
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
        
        Map<String, PermisoGranular> permisosMap = {};
        if (permisosString != null) {
          final decoded = jsonDecode(permisosString);
          if (decoded is Map<String, dynamic>) {
            decoded.forEach((key, value) {
              permisosMap[key] = PermisoGranular.fromJson(value);
            });
          }
        }
        
        state = AuthState(isAuthenticated: true, token: token, user: user, permisos: permisosMap);
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
      Map<String, PermisoGranular> permisosMap = {};
      try {
        final permRes = await apiClient.get('/permisos-granulares/${user.rolId}?usuario_id=${user.id}');
        if (permRes.data is Map) {
          final Map<String, dynamic> dataMap = permRes.data;
          dataMap.forEach((key, value) {
            if (value is Map<String, dynamic>) {
              // El backend devuelve: { "Empleados": { "puedeVer": 1, ... } }
              final jsonToParse = {
                'nombre': key,
                ...value
              };
              final p = PermisoGranular.fromJson(jsonToParse);
              permisosMap[p.moduloNombre] = p;
            }
          });
        }
      } catch (e) {
        debugPrint("Error obteniendo permisos granulares: $e");
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      await prefs.setString('user_data', jsonEncode(userData)); // Guardar datos del usuario
      
      // Save map as json by converting values to json
      final mapToJson = permisosMap.map((key, value) => MapEntry(key, value.toJson()));
      await prefs.setString('auth_permisos', jsonEncode(mapToJson)); // Guardar permisos

      state = AuthState(isAuthenticated: true, token: token, user: user, permisos: permisosMap);
      return true;
    } catch (e) {
      debugPrint("Error de login detallado: $e");
      state = AuthState(
        isAuthenticated: false,
        error: 'Correo o contraseña incorrectos',
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