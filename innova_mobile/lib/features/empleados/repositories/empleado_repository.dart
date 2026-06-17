// CREADO POR: DANIEL INNOVA

import '../../../core/api/api_client.dart';
import '../models/empleado_model.dart';

class EmpleadoRepository {
  Future<List<Empleado>> getEmpleados() async {
    try {
      final response = await apiClient.get('/empleados/lista');
      final List data = response.data ?? [];
      return data.map((json) => Empleado.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener la lista de empleados: $e');
    }
  }
}