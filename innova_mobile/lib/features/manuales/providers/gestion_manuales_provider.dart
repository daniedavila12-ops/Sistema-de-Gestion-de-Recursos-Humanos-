// CREADO POR: DANIEL INNOVA

import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../models/manual_model.dart';
import '../../auth/providers/auth_provider.dart';
import 'package:innova_mobile/core/constants/api_constants.dart';

final manualesSearchQueryProvider = StateProvider<String>((ref) => '');

class GestionManualesNotifier extends StateNotifier<AsyncValue<List<Manual>>> {
  final Ref ref;

  GestionManualesNotifier(this.ref) : super(const AsyncValue.loading()) {
    fetchManuales();
  }

  final String _apiUrl = '${ApiConstants.baseUrl}/api/biblioteca';

  Future<void> fetchManuales() async {
    state = const AsyncValue.loading();
    try {
      final response = await http.get(Uri.parse(_apiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final manuales = data.map((m) => Manual.fromJson(m)).toList();
        state = AsyncValue.data(manuales);
      } else {
        throw Exception('Error al cargar la biblioteca: ${response.statusCode}');
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> eliminarManual(int id) async {
    try {
      final response = await http.delete(Uri.parse('$_apiUrl/$id'));
      if (response.statusCode == 200) {
        if (state.hasValue) {
          final updated = state.value!.where((m) => m.id != id).toList();
          state = AsyncValue.data(updated);
        }
      } else {
        throw Exception('Error al eliminar manual');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> subirManual({
    required String titulo,
    required String categoria,
    required String descripcion,
    File? archivoPdf,
    int? editandoId,
  }) async {
    try {
      final url = editandoId != null ? '$_apiUrl/$editandoId' : '$_apiUrl/subir';
      final method = editandoId != null ? 'PUT' : 'POST';

      var request = http.MultipartRequest(method, Uri.parse(url));

      request.fields['titulo'] = titulo;
      request.fields['categoria'] = categoria;
      request.fields['descripcion'] = descripcion;

      final user = ref.read(authProvider).user;
      final userId = user?.id.toString() ?? '1';

      if (editandoId != null) {
        request.fields['modificadoPor'] = userId;
      } else {
        request.fields['creadoPor'] = userId;
      }

      if (archivoPdf != null) {
        final stream = http.ByteStream(archivoPdf.openRead());
        final length = await archivoPdf.length();
        final multipartFile = http.MultipartFile(
          'archivo',
          stream,
          length,
          filename: archivoPdf.path.split(Platform.pathSeparator).last,
        );
        request.files.add(multipartFile);
      }

      final response = await request.send();
      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchManuales();
      } else {
        final respStr = await response.stream.bytesToString();
        throw Exception('Error del servidor: $respStr');
      }
    } catch (e) {
      throw Exception('Error al guardar manual: $e');
    }
  }
}

final gestionManualesProvider = StateNotifierProvider<GestionManualesNotifier, AsyncValue<List<Manual>>>((ref) {
  return GestionManualesNotifier(ref);
});

final filteredManualesProvider = Provider<AsyncValue<List<Manual>>>((ref) {
  final manualesAsync = ref.watch(gestionManualesProvider);
  final query = ref.watch(manualesSearchQueryProvider).toLowerCase();

  return manualesAsync.whenData((manuales) {
    if (query.isEmpty) return manuales;
    return manuales.where((m) {
      return m.titulo.toLowerCase().contains(query) ||
             (m.descripcion?.toLowerCase().contains(query) ?? false) ||
             (m.categoria?.toLowerCase().contains(query) ?? false);
    }).toList();
  });
});
