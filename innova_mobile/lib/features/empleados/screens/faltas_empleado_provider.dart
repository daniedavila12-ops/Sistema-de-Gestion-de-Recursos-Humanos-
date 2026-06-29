import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import '../models/falta_model.dart';
import 'package:innova_mobile/core/constants/api_constants.dart';

const String _apiUrl = '${ApiConstants.baseUrl}/api';

// Provider para obtener las faltas de un empleado específico
final faltasEmpleadoProvider = FutureProvider.family<List<Falta>, int>((ref, empleadoId) async {
  final response = await http.get(Uri.parse('$_apiUrl/faltas/empleado/$empleadoId'));

  if (response.statusCode == 200) {
    final List<dynamic> body = json.decode(response.body);
    return body.map((dynamic item) => Falta.fromJson(item)).toList();
  } else {
    throw Exception('Error al cargar el historial de faltas del empleado.');
  }
});

// Provider para el repositorio que maneja las faltas
final faltaRepositoryProvider = Provider((ref) => FaltaRepository());

class FaltaRepository {
  Future<void> registrarFalta(Map<String, String?> faltaData, PlatformFile? documento) async {
    final request = http.MultipartRequest('POST', Uri.parse('$_apiUrl/faltas/registrar'));

    faltaData.forEach((key, value) {
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
      throw Exception('Error al registrar la falta: $responseBody');
    }
  }

  Future<void> actualizarFalta(int faltaId, Map<String, String?> faltaData, PlatformFile? documento) async {
    final request = http.MultipartRequest('PUT', Uri.parse('$_apiUrl/faltas/$faltaId'));

    faltaData.forEach((key, value) {
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
      throw Exception('Error al actualizar la falta: $responseBody');
    }
  }

  Future<void> eliminarFalta(int faltaId) async {
    final response = await http.delete(Uri.parse('$_apiUrl/faltas/$faltaId'));

    if (response.statusCode != 200) {
      throw Exception('Error al eliminar la falta.');
    }
  }
}
