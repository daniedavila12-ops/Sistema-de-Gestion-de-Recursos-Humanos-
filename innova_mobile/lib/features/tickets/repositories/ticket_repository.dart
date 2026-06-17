// CREADO POR: DANIEL INNOVA

import '../../../core/api/api_client.dart';
import '../models/ticket_model.dart';

class TicketRepository {
  Future<List<Ticket>> getTickets() async {
    try {
      final response = await apiClient.get('/tickets/lista');
      final List data = response.data is List ? response.data : (response.data['data'] ?? []);
      return data.map((json) => Ticket.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener los tickets: $e');
    }
  }

  Future<Ticket> getTicketById(int id) async {
    try {
      final response = await apiClient.get('/tickets/$id');
      return Ticket.fromJson(response.data);
    } catch (e) {
      throw Exception('Error al obtener el ticket: $e');
    }
  }

  Future<List<RespuestaTicket>> getRespuestas(int ticketId) async {
    try {
      final response = await apiClient.get('/tickets/$ticketId/respuestas');
      final List data = response.data is List ? response.data : (response.data['data'] ?? []);
      return data.map((json) => RespuestaTicket.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener las respuestas: $e');
    }
  }

  Future<bool> createTicket({
    required String tipo,
    required String descripcion,
    required String tema,
    required String prioridad,
    int? usuarioId,
    String? identidad,
  }) async {
    try {
      final response = await apiClient.post('/tickets/crear', data: {
        'usuario_id': usuarioId,
        'tipo': tipo,
        'descripcion': descripcion,
        'tema': tema,
        'prioridad': prioridad,
        'identidad': identidad,
      });
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      throw Exception('Error al crear el ticket: $e');
    }
  }

  Future<bool> addRespuesta({
    required int ticketId,
    required String mensaje,
    int? usuarioId,
  }) async {
    try {
      // Usando FormData si la API web espera multipart, o JSON si lo soporta.
      // La web usa FormData porque puede enviar archivo, aquí enviaremos JSON normal por simplicidad
      // O form data:
      // final formData = FormData.fromMap({
      //   'mensaje': mensaje,
      //   if (usuarioId != null) 'usuario_id': usuarioId,
      // });
      
      final response = await apiClient.post('/tickets/$ticketId/respuestas', data: {
        'mensaje': mensaje,
        'usuario_id': ?usuarioId,
      });
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      throw Exception('Error al enviar respuesta: $e');
    }
  }

  Future<bool> updateEstado(int ticketId, String estado) async {
    try {
      final response = await apiClient.put('/tickets/$ticketId/estado', data: {
        'estado': estado,
      });
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error al actualizar estado: $e');
    }
  }

  Future<bool> updatePrioridad(int ticketId, String prioridad) async {
    try {
      final response = await apiClient.put('/tickets/$ticketId/prioridad', data: {
        'prioridad': prioridad,
      });
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error al actualizar prioridad: $e');
    }
  }
}