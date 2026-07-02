import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:innova_mobile/core/constants/api_constants.dart';

class VacacionEmpleado {
  final int id;
  final String periodo;
  final String tipoSolicitud;
  final String? tipoPermiso;
  final double diasVacaciones;
  final double diasPagados;
  final double diasPendientes;
  final String? fechaInicio;
  final String? fechaFinal;
  final String? fechaRegreso;
  final String? observaciones;
  final String? fechaSolicitud;
  final double diasCorrespondientes;
  final String? autorizadoPor;
  final String? documento;
  final String? creadoPorNombre;
  final String? fechaCreacion;
  final String? modificadoPorNombre;
  final String? fechaModificacion;

  VacacionEmpleado({
    required this.id,
    required this.periodo,
    required this.tipoSolicitud,
    this.tipoPermiso,
    required this.diasVacaciones,
    required this.diasPagados,
    required this.diasPendientes,
    this.fechaInicio,
    this.fechaFinal,
    this.fechaRegreso,
    this.observaciones,
    this.fechaSolicitud,
    this.diasCorrespondientes = 0.0,
    this.autorizadoPor,
    this.documento,
    this.creadoPorNombre,
    this.fechaCreacion,
    this.modificadoPorNombre,
    this.fechaModificacion,
  });

  factory VacacionEmpleado.fromJson(Map<String, dynamic> json) {
    return VacacionEmpleado(
      id: json['id'] ?? 0,
      periodo: json['periodo'] ?? 'N/A',
      tipoSolicitud: json['tipoSolicitud'] ?? 'Normal',
      tipoPermiso: json['tipoPermiso'],
      diasVacaciones: double.tryParse(json['diasVacaciones']?.toString() ?? '0') ?? 0.0,
      diasPagados: double.tryParse(json['diasPagados']?.toString() ?? '0') ?? 0.0,
      diasPendientes: double.tryParse(json['diasPendientes']?.toString() ?? '0') ?? 0.0,
      fechaInicio: json['fechaInicio'] ?? json['fecha_inicio'],
      fechaFinal: json['fechaFinal'] ?? json['fecha_final'],
      fechaRegreso: json['fechaRegreso'] ?? json['fecha_regreso'],
      observaciones: json['observaciones'],
      fechaSolicitud: json['fechaSolicitud'] ?? json['fecha_solicitud'],
      diasCorrespondientes: double.tryParse(json['diasCorrespondientes']?.toString() ?? '0') ?? 0.0,
      autorizadoPor: json['autorizadoPor'] ?? json['autorizado_por'],
      documento: json['documento'],
      creadoPorNombre: json['creadoPorNombre'],
      fechaCreacion: json['fechaCreacion'] ?? json['fecha_creacion'],
      modificadoPorNombre: json['modificadoPorNombre'],
      fechaModificacion: json['fechaModificacion'] ?? json['fecha_modificacion'],
    );
  }
}

final vacacionesEmpleadoProvider = FutureProvider.family<List<VacacionEmpleado>, int>((ref, empleadoId) async {
  try {
    final res = await apiClient.get('/vacaciones/empleado/$empleadoId');
    final List<dynamic> records = res.data;
    
    // Convert to models
    var vacaciones = records.map((e) => VacacionEmpleado.fromJson(e)).toList();
    
    // Sort descending by ID (newest first)
    vacaciones.sort((a, b) => b.id.compareTo(a.id));
    
    return vacaciones;
  } catch (e) {
    throw Exception('Error al cargar historial de vacaciones: $e');
  }
});

// Provider para el repositorio que maneja las vacaciones
final vacacionRepositoryProvider = Provider((ref) => VacacionRepository());

class VacacionRepository {
  static const String _apiUrl = '${ApiConstants.baseUrl}/api';

  Future<void> registrarVacacion(Map<String, String?> vacacionData, PlatformFile? documento) async {
    final request = http.MultipartRequest('POST', Uri.parse('$_apiUrl/vacaciones/registrar'));

    vacacionData.forEach((key, value) {
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
      throw Exception('Error al registrar las vacaciones: $responseBody');
    }
  }

  Future<void> actualizarVacacion(int vacacionId, Map<String, String?> vacacionData, PlatformFile? documento) async {
    final request = http.MultipartRequest('PUT', Uri.parse('$_apiUrl/vacaciones/$vacacionId'));

    vacacionData.forEach((key, value) {
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
      throw Exception('Error al actualizar las vacaciones: $responseBody');
    }
  }

  Future<void> eliminarVacacion(int vacacionId) async {
    final response = await http.delete(Uri.parse('$_apiUrl/vacaciones/$vacacionId'));

    if (response.statusCode != 200) {
      throw Exception('Error al eliminar las vacaciones.');
    }
  }
}
