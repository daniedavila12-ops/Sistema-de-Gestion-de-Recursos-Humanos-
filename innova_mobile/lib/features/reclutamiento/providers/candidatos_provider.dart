import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:innova_mobile/core/constants/api_constants.dart';
import 'package:innova_mobile/features/auth/providers/auth_provider.dart';
import '../models/candidato_model.dart';

class CandidatosState {
  final List<Candidato> candidatos;
  final bool isLoading;
  final String? error;

  CandidatosState({
    this.candidatos = const [],
    this.isLoading = false,
    this.error,
  });

  CandidatosState copyWith({
    List<Candidato>? candidatos,
    bool? isLoading,
    String? error,
  }) {
    return CandidatosState(
      candidatos: candidatos ?? this.candidatos,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class CandidatosNotifier extends StateNotifier<CandidatosState> {
  final Ref ref;

  CandidatosNotifier(this.ref) : super(CandidatosState()) {
    fetchCandidatos();
  }

  Future<void> fetchCandidatos() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final token = ref.read(authProvider).token;
      if (token == null) {
        state = state.copyWith(isLoading: false, error: 'No autorizado');
        return;
      }

      final url = Uri.parse('${ApiConstants.baseUrl}/api/candidatos');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final candidatos = data.map((item) => Candidato.fromJson(item)).toList();
        state = state.copyWith(candidatos: candidatos, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false, error: 'Error al cargar los candidatos');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> actualizarEstado(int id, String nuevoEstado) async {
    try {
      final token = ref.read(authProvider).token;
      if (token == null) return false;

      final url = Uri.parse('${ApiConstants.baseUrl}/api/candidatos/$id/estado');
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'estado': nuevoEstado}),
      );

      if (response.statusCode == 200) {
        // Actualizar el estado localmente
        final updatedCandidatos = state.candidatos.map((c) {
          if (c.id == id) {
            return c.copyWith(estado: nuevoEstado);
          }
          return c;
        }).toList();
        state = state.copyWith(candidatos: updatedCandidatos);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}

final candidatosProvider = StateNotifierProvider<CandidatosNotifier, CandidatosState>((ref) {
  return CandidatosNotifier(ref);
});
