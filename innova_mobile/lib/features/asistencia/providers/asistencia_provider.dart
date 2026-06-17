// CREADO POR: DANIEL INNOVA

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/repositories/asistencia_repository.dart';
import '../models/vacacion_model.dart';

// Proveedor del repositorio
final asistenciaRepositoryProvider = Provider<AsistenciaRepository>((ref) {
  return AsistenciaRepository();
});

// Proveedor del estado asíncrono
final vacacionesProvider = FutureProvider<List<Vacacion>>((ref) async {
  final repository = ref.watch(asistenciaRepositoryProvider);
  return repository.getVacaciones();
});