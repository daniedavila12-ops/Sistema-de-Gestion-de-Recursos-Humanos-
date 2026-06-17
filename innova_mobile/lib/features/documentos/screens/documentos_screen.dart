// CREADO POR: DANIEL INNOVA

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/documento_provider.dart';
import '../../../shared/widgets/innova_card.dart';

class DocumentosScreen extends ConsumerWidget {
  const DocumentosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final documentosAsyncValue = ref.watch(documentosProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Biblioteca y Documentos'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
      ),
      body: documentosAsyncValue.when(
        data: (documentos) {
          if (documentos.isEmpty) {
            return const Center(child: Text('No hay documentos en la biblioteca.'));
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(documentosProvider.future),
            child: ListView.builder(
              itemCount: documentos.length,
              itemBuilder: (context, index) {
                final doc = documentos[index];
                return InnovaCard(
                  title: doc.titulo,
                  subtitle: 'Tipo: ${doc.tipo}',
                  icon: Icons.folder_shared,
                  onTap: () {
                    // Lógica para abrir la URL o descargar el archivo
                  },
                );
              },
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 60),
              const SizedBox(height: 16),
              Text('Error de conexión:\n$error', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(documentosProvider.future),
                child: const Text('Reintentar'),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue.shade800,
        child: const Icon(Icons.upload_file, color: Colors.white),
        onPressed: () {
          // Lógica para subir un nuevo documento
        },
      ),
    );
  }
}