// CREADO POR: DANIEL INNOVA

import '../../../../core/api/api_client.dart';
import '../vacacion_model.dart';

class AsistenciaRepository {
  Future<List<Vacacion>> getVacaciones() async {
    try {
      final response = await apiClient.get('/vacaciones'); // Ajustar ruta según backend
      final List data = response.data['data'] ?? [];
      return data.map((json) => Vacacion.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener las vacaciones: $e');
    }
  }
}