import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../auth/providers/auth_provider.dart';
import '../../../core/api/api_client.dart';
import 'package:innova_mobile/core/constants/api_constants.dart';

// Parámetros para el fetch (meses)
class DashboardFilters {
  final int mesCumpleaneros;
  final String mesVencimiento;

  DashboardFilters({
    required this.mesCumpleaneros,
    required this.mesVencimiento,
  });

  DashboardFilters copyWith({
    int? mesCumpleaneros,
    String? mesVencimiento,
  }) {
    return DashboardFilters(
      mesCumpleaneros: mesCumpleaneros ?? this.mesCumpleaneros,
      mesVencimiento: mesVencimiento ?? this.mesVencimiento,
    );
  }
}

final dashboardFiltersProvider = StateProvider<DashboardFilters>((ref) {
  return DashboardFilters(
    mesCumpleaneros: DateTime.now().month,
    mesVencimiento: 'proximos',
  );
});

final dashboardStatsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final authState = ref.watch(authProvider);
  final user = authState.user;
  if (user == null) return {};

  final response = await apiClient.get('/stats/resumen', queryParameters: {
    'usuario_id': user.id,
    'nombre': user.nombre,
    'rol_id': user.rolId,
  });

  if (response.statusCode == 200) {
    return response.data;
  } else {
    throw Exception('Error al cargar las estadísticas del dashboard');
  }
});

final dashboardListsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final filters = ref.watch(dashboardFiltersProvider);
  final mesC = filters.mesCumpleaneros;
  final mesV = filters.mesVencimiento;

  final response = await http.get(Uri.parse('${ApiConstants.baseUrl}/api/stats/dashboard-lists?mes=$mesC&mesVencimiento=$mesV'));

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Error al cargar las listas del dashboard');
  }
});
