import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';

class Departamento {
  final int id;
  final String nombre;

  Departamento({required this.id, required this.nombre});

  factory Departamento.fromJson(Map<String, dynamic> json) {
    return Departamento(
      id: json['id'],
      nombre: json['nombre'],
    );
  }
}

final departamentosProvider = FutureProvider.autoDispose<List<Departamento>>((ref) async {
  final response = await apiClient.get('/departamentos/lista');
  final List data = response.data is List ? response.data : (response.data['data'] ?? []);
  return data.map((json) => Departamento.fromJson(json)).toList();
});
