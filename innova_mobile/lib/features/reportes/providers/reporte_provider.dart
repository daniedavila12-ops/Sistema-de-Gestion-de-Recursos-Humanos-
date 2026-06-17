// CREADO POR: DANIEL INNOVA

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/reporte_repository.dart';
import '../models/reporte_model.dart';

// Proveedor del repositorio
final reporteRepositoryProvider = Provider<ReporteRepository>((ref) {
  return ReporteRepository();
});

// Proveedor del estado asíncrono
final reportesProvider = FutureProvider<List<Reporte>>((ref) async {
  final repository = ref.watch(reporteRepositoryProvider);
  return repository.getReportes();
});