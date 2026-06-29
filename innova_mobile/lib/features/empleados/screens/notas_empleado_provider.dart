import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import '../models/nota_model.dart';
import 'package:innova_mobile/core/constants/api_constants.dart';

const String _apiUrl = '${ApiConstants.baseUrl}/api';

// Provider para obtener las notas de un empleado específico
final notasEmpleadoProvider = FutureProvider.family<List<Nota>, int>((ref, empleadoId) async {
  final response = await http.get(Uri.parse('$_apiUrl/notas/empleado/$empleadoId'));

  if (response.statusCode == 200) {
    final List<dynamic> body = json.decode(response.body);
    return body.map((dynamic item) => Nota.fromJson(item)).toList();
  } else {
    throw Exception('Error al cargar el historial de notas del empleado.');
  }
});

// Provider para el repositorio que maneja las notas
final notaRepositoryProvider = Provider((ref) => NotaRepository());

class NotaRepository {
  Future<void> registrarNota(Map<String, String?> notaData, PlatformFile? documento) async {
    final request = http.MultipartRequest('POST', Uri.parse('$_apiUrl/notas/registrar'));

    notaData.forEach((key, value) {
      if (value != null) {
        request.fields[key] = value;
      }
    });

    if (documento != null && documento.path != null) {
      request.files.add(await http.MultipartFile.fromPath('documento', documento.path!));
    }

    final response = await request.send();

    if (response.statusCode != 200 && response.statusCode != 201) {
      final responseBody = await response.stream.bytesToString();
      throw Exception('Error al registrar la nota: $responseBody');
    }
  }

  Future<void> actualizarNota(int notaId, Map<String, String?> notaData, PlatformFile? documento) async {
    final request = http.MultipartRequest('PUT', Uri.parse('$_apiUrl/notas/$notaId'));

    notaData.forEach((key, value) {
      if (value != null) {
        request.fields[key] = value;
      }
    });

    if (documento != null && documento.path != null) {
      request.files.add(await http.MultipartFile.fromPath('documento', documento.path!));
    }

    final response = await request.send();

    if (response.statusCode != 200) {
      final responseBody = await response.stream.bytesToString();
      throw Exception('Error al actualizar la nota: $responseBody');
    }
  }

  Future<void> eliminarNota(int notaId) async {
    final response = await http.delete(Uri.parse('$_apiUrl/notas/$notaId'));

    if (response.statusCode != 200) {
      throw Exception('Error al eliminar la nota.');
    }
  }
}
