// CREADO POR: DANIEL INNOVA

import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'contrato_model.dart';
import 'package:innova_mobile/core/constants/api_constants.dart';

const String _apiUrl = '${ApiConstants.baseUrl}/api';

// Provider para obtener los contratos de un empleado específico
final contratosProvider = FutureProvider.family<List<Contrato>, int>((ref, empleadoId) async {
  // Asumiendo que existe un endpoint: GET /api/empleados/{empleadoId}/contratos
  final response = await http.get(Uri.parse('$_apiUrl/empleados/$empleadoId/contratos'));

  if (response.statusCode == 200) {
    final List<dynamic> body = json.decode(response.body);
    return body.map((dynamic item) => Contrato.fromJson(item)).toList();
  } else {
    throw Exception('Error al cargar los contratos del empleado.');
  }
});

// Provider para el repositorio que crea el contrato
final contratoRepositoryProvider = Provider((ref) => ContratoRepository());

class ContratoRepository {
  Future<void> createContrato(Map<String, String?> contratoData, PlatformFile? archivo) async {
    // El endpoint en la web es: POST /api/empleados/{id}/contratos
    final empleadoId = contratoData['empleadoId'];
    final request = http.MultipartRequest('POST', Uri.parse('$_apiUrl/empleados/$empleadoId/contratos'));

    contratoData.forEach((key, value) {
      if (value != null) {
        request.fields[key] = value;
      }
    });

    if (archivo != null && archivo.path != null) {
      request.files.add(await http.MultipartFile.fromPath('archivo', archivo.path!));
    }

    final response = await request.send();

    if (response.statusCode != 201 && response.statusCode != 200) {
      final responseBody = await response.stream.bytesToString();
      throw Exception('Error al registrar el contrato: $responseBody');
    }
  }
}