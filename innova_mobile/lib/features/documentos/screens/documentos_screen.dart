// CREADO POR: DANIEL INNOVA

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/documento_provider.dart';
import '../widgets/documento_card.dart';
import 'documento_form_screen.dart';
import 'package:innova_mobile/core/constants/api_constants.dart';

class DocumentosScreen extends ConsumerStatefulWidget {
  const DocumentosScreen({super.key});

  @override
  ConsumerState<DocumentosScreen> createState() => _DocumentosScreenState();
}

class _DocumentosScreenState extends ConsumerState<DocumentosScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final documentosAsyncValue = ref.watch(documentosProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ARCHIVERO LEGAL', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header description and search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Repositorio seguro de documentos legales y normativas.',
                  style: TextStyle(color: Colors.black54, fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 16),
                TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Buscar documento por título, categoría o descripción...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: documentosAsyncValue.when(
              data: (documentos) {
                final filteredDocs = documentos.where((doc) {
                  return doc.titulo.toLowerCase().contains(_searchQuery) ||
                         doc.categoria.toLowerCase().contains(_searchQuery) ||
                         doc.descripcion.toLowerCase().contains(_searchQuery);
                }).toList();

                if (filteredDocs.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('🗄️', style: TextStyle(fontSize: 60)),
                        SizedBox(height: 16),
                        Text(
                          'El archivero está vacío o no hay resultados.',
                          style: TextStyle(color: Colors.black54, fontStyle: FontStyle.italic, fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => ref.refresh(documentosProvider.future),
                  child: ListView.builder(
                    itemCount: filteredDocs.length,
                    padding: const EdgeInsets.only(top: 8, bottom: 80),
                    itemBuilder: (context, index) {
                      final doc = filteredDocs[index];
                      // Obtener baseURL temporalmente (debería venir de config o provider)
                      const apiBase = ApiConstants.baseUrl; // Ajustar según backend real en móvil (ej. 10.0.2.2)
                      
                      return DocumentoCard(
                        documento: doc,
                        apiBaseUrl: apiBase,
                        onEdit: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DocumentoFormScreen(documentoToEdit: doc),
                            ),
                          );
                        },
                        onDelete: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (c) => AlertDialog(
                              title: const Text('¿Eliminar documento?'),
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
                              await ref.read(documentoRepositoryProvider).eliminarDocumento(doc.id);
                              ref.invalidate(documentosProvider);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Documento eliminado')));
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                              }
                            }
                          }
                        },
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Accediendo al archivero...', style: TextStyle(color: Colors.black54, fontStyle: FontStyle.italic))
                  ],
                ),
              ),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 60),
                    const SizedBox(height: 16),
                    Text('Error de conexión:\n$error', textAlign: TextAlign.center, style: const TextStyle(color: Colors.black87)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.refresh(documentosProvider.future),
                      child: const Text('Reintentar'),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('SUBIR DOCUMENTO', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const DocumentoFormScreen(),
            ),
          );
        },
      ),
    );
  }
}