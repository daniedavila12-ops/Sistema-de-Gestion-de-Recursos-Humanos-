// CREADO POR: DANIEL INNOVA

import '../../../core/api/api_client.dart';
import '../models/reporte_incidencia_model.dart';
import '../../auth/models/usuario_model.dart';
import 'package:dio/dio.dart';

class ReporteIncidenciaRepository {
  Future<List<ReporteIncidencia>> getReportes() async {
    try {
      final response = await apiClient.get('/reportes-incidencia/lista');
      final List data = response.data is List ? response.data : (response.data['data'] ?? []);
      return data.map((json) => ReporteIncidencia.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener los reportes: $e');
    }
  }

  Future<ReporteIncidencia> getReporteById(int id) async {
    try {
      final response = await apiClient.get('/reportes-incidencia/$id');
      return ReporteIncidencia.fromJson(response.data);
    } catch (e) {
      throw Exception('Error al obtener el reporte: $e');
    }
  }

  Future<bool> createReporte({
    required String jefeReporta,
    required String identidad,
    required String categoria,
    required String prioridad,
    required String tema,
    required String descripcion,
    String? archivoPath,
  }) async {
    try {
      Map<String, dynamic> dataMap = {
        'jefe_reporta': jefeReporta,
        'identidad': identidad,
        'categoria': categoria,
        'prioridad': prioridad,
        'tema': tema,
        'descripcion': descripcion,
      };

      if (archivoPath != null && archivoPath.isNotEmpty) {
        dataMap['archivo'] = await MultipartFile.fromFile(archivoPath);
      }

      final formData = FormData.fromMap(dataMap);

      final response = await apiClient.post(
        '/reportes-incidencia/crear',
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );
      
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      throw Exception('Error al crear el reporte: $e');
    }
  }

  Future<List<CategoriaReporte>> getCategorias() async {
    try {
      final response = await apiClient.get('/reportes-incidencia/categorias/lista');
      final List data = response.data is List ? response.data : (response.data['data'] ?? []);
      return data.map((json) => CategoriaReporte.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener categorías: $e');
    }
  }

  Future<bool> addCategoria(String nombre) async {
    try {
      final response = await apiClient.post('/reportes-incidencia/categorias', data: {'nombre': nombre});
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      throw Exception('Error al agregar categoría: $e');
    }
  }

  Future<bool> updateCategoria(int id, String nombre, bool activa) async {
    try {
      final response = await apiClient.put('/reportes-incidencia/categorias/$id', data: {
        'nombre': nombre,
        'activa': activa,
      });
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      throw Exception('Error al actualizar categoría: $e');
    }
  }

  Future<List<RespuestaReporteIncidencia>> getRespuestas(int reporteId) async {
    try {
      final response = await apiClient.get('/reportes-incidencia/$reporteId/respuestas');
      final List data = response.data is List ? response.data : (response.data['data'] ?? []);
      return data.map((json) => RespuestaReporteIncidencia.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener respuestas: $e');
    }
  }

  Future<bool> addRespuesta(int reporteId, String respuesta, {int? usuarioId, String? archivoPath}) async {
    try {
      Map<String, dynamic> dataMap = {
        'mensaje': respuesta,
      };
      if (usuarioId != null) {
        dataMap['usuario_id'] = usuarioId;
      }
      
      if (archivoPath != null && archivoPath.isNotEmpty) {
        dataMap['archivo'] = await MultipartFile.fromFile(archivoPath);
      }
      
      final formData = FormData.fromMap(dataMap);
      final response = await apiClient.post(
        '/reportes-incidencia/$reporteId/respuestas', 
        data: formData,
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      throw Exception('Error al enviar respuesta: $e');
    }
  }

  Future<bool> updateEstado(int reporteId, String estado) async {
    try {
      final response = await apiClient.put(
        '/reportes-incidencia/$reporteId/estado', 
        data: {'estado': estado},
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      throw Exception('Error al cambiar estado: $e');
    }
  }

  Future<bool> asignarReporte(int reporteId, int usuarioId) async {
    try {
      final response = await apiClient.put(
        '/reportes-incidencia/$reporteId/asignar', 
        data: {'usuario_id': usuarioId},
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      throw Exception('Error al asignar reporte: $e');
    }
  }

  Future<List<Usuario>> getUsuariosRRHH() async {
    try {
      final response = await apiClient.get('/usuarios');
      final List data = response.data is List ? response.data : (response.data['data'] ?? []);
      return data
          .map((json) => Usuario.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener usuarios RRHH: $e');
    }
  }
}
