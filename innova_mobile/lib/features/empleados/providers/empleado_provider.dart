// CREADO POR: DANIEL INNOVA

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/empleado_repository.dart';
import '../models/empleado_model.dart';

// Proveedor del repositorio
final empleadoRepositoryProvider = Provider<EmpleadoRepository>((ref) {
  return EmpleadoRepository();
});

// Proveedor del estado asíncrono
final empleadosProvider = FutureProvider<List<Empleado>>((ref) async {
  final repository = ref.watch(empleadoRepositoryProvider);
  return repository.getEmpleados();
});