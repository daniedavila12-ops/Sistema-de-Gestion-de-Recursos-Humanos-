// CREADO POR: DANIEL INNOVA

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/documento_repository.dart';
import '../models/documento_model.dart';

// Proveedor del repositorio
final documentoRepositoryProvider = Provider<DocumentoRepository>((ref) {
  return DocumentoRepository();
});

// Proveedor del estado asíncrono
final documentosProvider = FutureProvider<List<Documento>>((ref) async {
  final repository = ref.watch(documentoRepositoryProvider);
  return repository.getDocumentos();
});