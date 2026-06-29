// CREADO POR: DANIEL INNOVA

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/documento_repository.dart';
import '../models/documento_model.dart';
import '../models/categoria_legal_model.dart';

// Proveedor del repositorio
final documentoRepositoryProvider = Provider<DocumentoRepository>((ref) {
  return DocumentoRepository();
});

// Proveedor del estado asíncrono para documentos
final documentosProvider = FutureProvider<List<Documento>>((ref) async {
  final repository = ref.watch(documentoRepositoryProvider);
  return repository.getDocumentos();
});

// Proveedor del estado asíncrono para categorías
final categoriasLegalesProvider = FutureProvider<List<CategoriaLegal>>((ref) async {
  final repository = ref.watch(documentoRepositoryProvider);
  return repository.getCategorias();
});