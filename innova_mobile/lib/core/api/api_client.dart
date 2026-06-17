// CREADO POR: DANIEL INNOVA
// MODIFICADO: DANIEL INNOVA

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  final Dio dio;

  ApiClient()
      : dio = Dio(BaseOptions(
          // ¡PUERTO CORREGIDO A 3007!
          // Nota: 10.0.2.2 funciona si estás probando en el Emulador de Android.
          // Si usas un celular físico conectado por cable o Wi-Fi, 
          // cambia 10.0.2.2 por la IP de tu computadora (ej. 192.168.1.X)
          baseUrl: 'http://10.0.2.2:3007/api', 
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        )) {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        return handler.next(e);
      },
    ));
  }
}

// Instancia global para usar en los providers
final apiClient = ApiClient().dio;