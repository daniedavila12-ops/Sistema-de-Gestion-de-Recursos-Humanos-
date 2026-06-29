// CREADO POR: DANIEL INNOVA

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/gestion_manuales_provider.dart';
import 'manual_form_dialog.dart';

class GestionManualesScreen extends ConsumerWidget {
  const GestionManualesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final manualesAsync = ref.watch(filteredManualesProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Gestión de Manuales'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header / Search
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Administración de Biblioteca Digital',
                  style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 12),
                TextField(
                  onChanged: (val) => ref.read(manualesSearchQueryProvider.notifier).state = val,
                  decoration: InputDecoration(
                    hintText: 'Buscar manual...',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // List
          Expanded(
            child: manualesAsync.when(
              data: (manuales) {
                if (manuales.isEmpty) {
                  return const Center(
                    child: Text('No se encontraron manuales', style: TextStyle(color: Colors.grey)),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => ref.read(gestionManualesProvider.notifier).fetchManuales(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: manuales.length,
                    itemBuilder: (context, index) {
                      final m = manuales[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('#${m.id.toString().padLeft(3, '0')}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 13)),
                                        const SizedBox(height: 4),
                                        Text(m.titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                                        const SizedBox(height: 4),
                                        Text(m.descripcion ?? '', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                  // Actions
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.blue),
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (_) => ManualFormDialog(manualToEdit: m),
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () async {
                                          final confirm = await showDialog<bool>(
                                            context: context,
                                            builder: (ctx) => AlertDialog(
                                              title: const Text('Eliminar Manual'),
                                              content: const Text('¿Estás seguro de que deseas eliminar este manual? Esta acción no se puede deshacer.'),
                                              actions: [
                                                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('CANCELAR')),
                                                ElevatedButton(
                                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                                  onPressed: () => Navigator.pop(ctx, true), 
                                                  child: const Text('ELIMINAR', style: TextStyle(color: Colors.white)),
                                                ),
                                              ],
                                            )
                                          );

                                          if (confirm == true) {
                                            try {
                                              await ref.read(gestionManualesProvider.notifier).eliminarManual(m.id);
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Manual eliminado')));
                                              }
                                            } catch (e) {
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                                              }
                                            }
                                          }
                                        },
                                      ),
                                    ],
                                  )
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
                                    child: Text(m.categoria ?? 'General', style: TextStyle(color: Colors.blue.shade700, fontSize: 10, fontWeight: FontWeight.bold)),
                                  ),
                                  const SizedBox(width: 12),
                                  Icon(Icons.folder_open, size: 14, color: Colors.grey.shade500),
                                  const SizedBox(width: 4),
                                  Text(m.tamano ?? 'N/A', style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
                                  const Spacer(),
                                  Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade500),
                                  const SizedBox(width: 4),
                                  Text(
                                    m.fechaCreacion != null 
                                      ? '${m.fechaCreacion!.day.toString().padLeft(2,'0')}/${m.fechaCreacion!.month.toString().padLeft(2,'0')}/${m.fechaCreacion!.year}'
                                      : '-',
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 11)
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text('Error: $err', textAlign: TextAlign.center),
                    TextButton(
                      onPressed: () => ref.read(gestionManualesProvider.notifier).fetchManuales(),
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
        backgroundColor: Colors.blue.shade600,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('NUEVO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => const ManualFormDialog(),
          );
        },
      ),
    );
  }
}
