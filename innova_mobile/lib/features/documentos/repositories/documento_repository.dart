// CREADO POR: DANIEL INNOVA

import '../../../core/api/api_client.dart';
import '../models/documento_model.dart';

class DocumentoRepository {
  Future<List<Documento>> getDocumentos() async {
    try {
      // Ajusta esta ruta si en tu backend la biblioteca tiene otro endpoint
      final response = await apiClient.get('/biblioteca'); 
      final List data = response.data['data'] ?? [];
      return data.map((json) => Documento.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener los documentos: $e');
    }
  }
}