// CREADO POR: DANIEL INNOVA

import '../../../core/api/api_client.dart';
import '../models/documento_model.dart';
import '../models/categoria_legal_model.dart';
import 'package:dio/dio.dart';

class DocumentoRepository {
  Future<List<Documento>> getDocumentos() async {
    try {
      final response = await apiClient.get('/documentos-legales');
      final List data = response.data is List ? response.data : (response.data['data'] ?? []);
      return data.map((json) => Documento.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener los documentos: $e');
    }
  }

  Future<void> crearDocumento(FormData formData) async {
    try {
      await apiClient.post('/documentos-legales', data: formData);
    } catch (e) {
      throw Exception('Error al crear documento: $e');
    }
  }

  Future<void> actualizarDocumento(int id, FormData formData) async {
    try {
      await apiClient.put('/documentos-legales/$id', data: formData);
    } catch (e) {
      throw Exception('Error al actualizar documento: $e');
    }
  }

  Future<void> eliminarDocumento(int id) async {
    try {
      await apiClient.delete('/documentos-legales/$id');
    } catch (e) {
      throw Exception('Error al eliminar documento: $e');
    }
  }

  // CATEGORÍAS
  Future<List<CategoriaLegal>> getCategorias() async {
    try {
      final response = await apiClient.get('/categorias-legales');
      final List data = response.data is List ? response.data : (response.data['data'] ?? []);
      return data.map((json) => CategoriaLegal.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener categorías: $e');
    }
  }

  Future<void> crearCategoria(String nombre) async {
    try {
      await apiClient.post('/categorias-legales', data: {'nombre': nombre});
    } catch (e) {
      throw Exception('Error al crear categoría: $e');
    }
  }

  Future<void> actualizarCategoria(int id, String nombre) async {
    try {
      await apiClient.put('/categorias-legales/$id', data: {'nombre': nombre});
    } catch (e) {
      throw Exception('Error al actualizar categoría: $e');
    }
  }

  Future<void> eliminarCategoria(int id) async {
    try {
      await apiClient.delete('/categorias-legales/$id');
    } catch (e) {
      throw Exception('Error al eliminar categoría: $e');
    }
  }
}