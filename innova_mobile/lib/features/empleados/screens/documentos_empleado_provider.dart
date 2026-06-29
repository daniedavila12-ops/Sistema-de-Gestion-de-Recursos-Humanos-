import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import '../models/documento_empleado_model.dart';
import 'package:innova_mobile/core/constants/api_constants.dart';

const String _apiUrl = '${ApiConstants.baseUrl}/api';

// Provider para obtener los documentos de un empleado específico
final documentosEmpleadoProvider = FutureProvider.family<List<DocumentoEmpleado>, int>((ref, empleadoId) async {
  final response = await http.get(Uri.parse('$_apiUrl/documentos/empleado/$empleadoId'));

  if (response.statusCode == 200) {
    final List<dynamic> body = json.decode(response.body);
    return body.map((dynamic item) => DocumentoEmpleado.fromJson(item)).toList();
  } else {
    throw Exception('Error al cargar el historial de documentos del empleado.');
  }
});

// Provider para el repositorio que maneja los documentos
final documentoRepositoryProvider = Provider((ref) => DocumentoRepository());

class DocumentoRepository {
  Future<void> registrarDocumento(Map<String, String?> docData, PlatformFile? archivo) async {
    final request = http.MultipartRequest('POST', Uri.parse('$_apiUrl/documentos/registrar'));

    docData.forEach((key, value) {
      if (value != null) {
        request.fields[key] = value;
      }
    });

    if (archivo != null && archivo.path != null) {
      request.files.add(await http.MultipartFile.fromPath('archivo', archivo.path!));
    }

    final response = await request.send();

    if (response.statusCode != 200 && response.statusCode != 201) {
      final responseBody = await response.stream.bytesToString();
      throw Exception('Error al subir documento: $responseBody');
    }
  }

  Future<void> actualizarDocumento(int docId, Map<String, String?> docData, PlatformFile? archivo) async {
    final request = http.MultipartRequest('PUT', Uri.parse('$_apiUrl/documentos/$docId'));

    docData.forEach((key, value) {
      if (value != null) {
        request.fields[key] = value;
      }
    });

    if (archivo != null && archivo.path != null) {
      request.files.add(await http.MultipartFile.fromPath('archivo', archivo.path!));
    }

    final response = await request.send();

    if (response.statusCode != 200) {
      final responseBody = await response.stream.bytesToString();
      throw Exception('Error al actualizar documento: $responseBody');
    }
  }

  Future<void> eliminarDocumento(int docId) async {
    final response = await http.delete(Uri.parse('$_apiUrl/documentos/$docId'));

    if (response.statusCode != 200) {
      throw Exception('Error al eliminar el documento.');
    }
  }
}
