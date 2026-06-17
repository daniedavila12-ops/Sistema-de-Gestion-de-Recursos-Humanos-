// CREADO POR: DANIEL INNOVA

import '../../../core/api/api_client.dart';
import '../models/reporte_model.dart';

class ReporteRepository {
  Future<List<Reporte>> getReportes() async {
    try {
      final response = await apiClient.get('/reportes'); // Ajusta el endpoint según tu backend
      final List data = response.data['data'] ?? [];
      return data.map((json) => Reporte.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener los reportes: $e');
    }
  }
}