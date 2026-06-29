// CREADO POR: DANIEL INNOVA

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/documento_provider.dart';

class GestionCategoriasDialog extends ConsumerStatefulWidget {
  const GestionCategoriasDialog({super.key});

  @override
  ConsumerState<GestionCategoriasDialog> createState() => _GestionCategoriasDialogState();
}

class _GestionCategoriasDialogState extends ConsumerState<GestionCategoriasDialog> {
  final _nuevaCategoriaController = TextEditingController();
  int? _editandoId;
  final _editCategoriaController = TextEditingController();

  @override
  void dispose() {
    _nuevaCategoriaController.dispose();
    _editCategoriaController.dispose();
    super.dispose();
  }

  Future<void> _agregarCategoria() async {
    final nombre = _nuevaCategoriaController.text.trim();
    if (nombre.isEmpty) return;

    try {
      await ref.read(documentoRepositoryProvider).crearCategoria(nombre);
      _nuevaCategoriaController.clear();
      ref.invalidate(categoriasLegalesProvider);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _guardarEdicionCategoria(int id) async {
    final nombre = _editCategoriaController.text.trim();
    if (nombre.isEmpty) return;

    try {
      await ref.read(documentoRepositoryProvider).actualizarCategoria(id, nombre);
      setState(() {
        _editandoId = null;
      });
      ref.invalidate(categoriasLegalesProvider);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _eliminarCategoria(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('¿Eliminar categoría?'),
        content: const Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(c, true), 
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      )
    );
    
    if (confirm == true) {
      try {
        await ref.read(documentoRepositoryProvider).eliminarCategoria(id);
        ref.invalidate(categoriasLegalesProvider);
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriasAsyncValue = ref.watch(categoriasLegalesProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('⚙️ Categorías', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nuevaCategoriaController,
                    decoration: InputDecoration(
                      hintText: 'Nueva categoría...',
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _agregarCategoria,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey.shade900,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Añadir', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: categoriasAsyncValue.when(
                data: (categorias) {
                  if (categorias.isEmpty) {
                    return const Center(child: Text('No hay categorías.', style: TextStyle(fontStyle: FontStyle.italic)));
                  }
                  return ListView.builder(
                    itemCount: categorias.length,
                    itemBuilder: (context, index) {
                      final cat = categorias[index];
                      if (_editandoId == cat.id) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _editCategoriaController,
                                  decoration: const InputDecoration(
                                    isDense: true,
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              IconButton(icon: const Icon(Icons.check, color: Colors.green), onPressed: () => _guardarEdicionCategoria(cat.id)),
                              IconButton(icon: const Icon(Icons.close, color: Colors.grey), onPressed: () => setState(() => _editandoId = null)),
                            ],
                          ),
                        );
                      }
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
                        child: ListTile(
                          title: Text(cat.nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                                onPressed: () {
                                  setState(() {
                                    _editandoId = cat.id;
                                    _editCategoriaController.text = cat.nombre;
                                  });
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                onPressed: () => _eliminarCategoria(cat.id),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text('Error: $error')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
