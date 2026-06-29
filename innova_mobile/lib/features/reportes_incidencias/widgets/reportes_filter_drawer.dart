import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/reporte_incidencia_provider.dart';
import '../models/reporte_incidencia_model.dart';
import '../../auth/providers/auth_provider.dart';

class ReportesFilterDrawer extends ConsumerWidget {
  const ReportesFilterDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportesAsync = ref.watch(reportesIncidenciaProvider);
    final categoriasAsync = ref.watch(categoriasReporteProvider);
    final vistaFilter = ref.watch(reporteVistaFilterProvider);
    final statusFilter = ref.watch(reporteStatusFilterProvider);
    final categoriaFilter = ref.watch(reporteCategoriaFilterProvider);

    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Header del Drawer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.filter_list, color: Colors.black87),
                  const SizedBox(width: 8),
                  const Text('Filtros Avanzados', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  // --- VISTAS ---
                  _buildSectionTitle('VISTAS'),
                  _buildVistaItem(context, ref, 'Todas', 'todas', vistaFilter, reportesAsync),
                  _buildVistaItem(context, ref, 'Mis Entradas', 'misEntradas', vistaFilter, reportesAsync),
                  _buildVistaItem(context, ref, 'Asignado a Mí', 'asignado', vistaFilter, reportesAsync),
                  _buildVistaItem(context, ref, 'Sin Asignación', 'sinAsignacion', vistaFilter, reportesAsync),

                  const Divider(),

                  // --- ESTATUS ---
                  _buildSectionTitle('POR ESTATUS'),
                  _buildStatusItem(context, ref, 'Pendiente', statusFilter, Colors.orange, reportesAsync),
                  _buildStatusItem(context, ref, 'En Proceso', statusFilter, Colors.blue, reportesAsync),
                  _buildStatusItem(context, ref, 'Resuelto', statusFilter, Colors.green, reportesAsync),
                  _buildStatusItem(context, ref, 'Cancelado', statusFilter, Colors.grey, reportesAsync),
                  _buildStatusItem(context, ref, 'Todas', statusFilter, Colors.black, reportesAsync),

                  const Divider(),

                  // --- CATEGORIAS ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('CATEGORÍAS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                        IconButton(
                          icon: const Icon(Icons.add_circle, color: Colors.red),
                          tooltip: 'Agregar Categoría',
                          onPressed: () => _mostrarDialogoCategoria(context, ref),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),

                  // Opción de "Todas" en Categorías
                  _buildCategoriaFilterItem(context, ref, 'Todas', categoriaFilter, reportesAsync, null),

                  // Lista de categorías dinámica
                  categoriasAsync.when(
                    data: (categorias) {
                      if (categorias.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('No hay categorías.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        );
                      }
                      return Column(
                        children: categorias.map((cat) {
                          return _buildCategoriaFilterItem(context, ref, cat.nombre, categoriaFilter, reportesAsync, cat);
                        }).toList(),
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (error, _) => Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('Error: $error', style: const TextStyle(color: Colors.red, fontSize: 12)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1),
      ),
    );
  }

  Widget _buildVistaItem(BuildContext context, WidgetRef ref, String label, String value, String currentFilter, AsyncValue<List<ReporteIncidencia>> reportesAsync) {
    final isSelected = currentFilter == value;

    // Calcular el badge (este conteo es global sin aplicar otros filtros, como en la web)
    int count = 0;
    reportesAsync.whenData((reportes) {
      if (value == 'todas') {
        count = reportes.length;
      } else {
        // Obtenemos authProvider aquí no se puede tan fácil sin read, pero pasamos la longitud total por ahora
        // o podemos usar where para aproximar. Para mantener el rendimiento, usamos read.
        final user = ref.read(authProvider).user;
        count = reportes.where((r) {
           if (value == 'misEntradas') return r.jefeReporta == user?.nombre;
           if (value == 'asignado') return r.asignadoUsuarioId == user?.id;
           if (value == 'sinAsignacion') return r.asignadoUsuarioId == null;
           return true;
        }).length;
      }
    });

    return ListTile(
      dense: true,
      title: Text(label, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? Colors.red.shade700 : Colors.black87)),
      tileColor: isSelected ? Colors.red.shade50 : null,
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(color: isSelected ? Colors.red.shade100 : Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
        child: Text('$count', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isSelected ? Colors.red.shade700 : Colors.grey.shade600)),
      ),
      onTap: () {
        ref.read(reporteVistaFilterProvider.notifier).state = value;
      },
    );
  }

  Widget _buildStatusItem(BuildContext context, WidgetRef ref, String status, String currentFilter, Color color, AsyncValue<List<ReporteIncidencia>> reportesAsync) {
    final isSelected = currentFilter == status;

    int count = 0;
    reportesAsync.whenData((reportes) {
      if (status == 'Todas') {
        count = reportes.length;
      } else {
        count = reportes.where((r) {
          if (status == 'Cancelado') return r.estado == 'Cancelado' || r.estado == 'Desestimado';
          if (status == 'Pendiente') return r.estado == 'Pendiente' || r.estado == '';
          return r.estado == status;
        }).length;
      }
    });

    return ListTile(
      dense: true,
      leading: CircleAvatar(radius: 5, backgroundColor: color),
      title: Text(status, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? Colors.red.shade700 : Colors.black87)),
      tileColor: isSelected ? Colors.red.shade50 : null,
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(color: isSelected ? Colors.red.shade100 : Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
        child: Text('$count', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isSelected ? Colors.red.shade700 : Colors.grey.shade600)),
      ),
      onTap: () {
        ref.read(reporteStatusFilterProvider.notifier).state = status;
      },
    );
  }

  Widget _buildCategoriaFilterItem(BuildContext context, WidgetRef ref, String catNombre, String currentFilter, AsyncValue<List<ReporteIncidencia>> reportesAsync, CategoriaReporte? catObj) {
    final isSelected = currentFilter == catNombre;
    
    int count = 0;
    reportesAsync.whenData((reportes) {
      if (catNombre == 'Todas') {
        count = reportes.length;
      } else {
        count = reportes.where((r) => r.categoria == catNombre).length;
      }
    });

    return ListTile(
      dense: true,
      leading: Icon(
        catObj == null ? Icons.folder : (catObj.activa ? Icons.folder_open : Icons.folder_off), 
        size: 18, 
        color: (catObj != null && !catObj.activa) ? Colors.grey : (isSelected ? Colors.red.shade700 : Colors.grey.shade600),
      ),
      title: Text(catNombre, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: (catObj != null && !catObj.activa) ? Colors.grey : (isSelected ? Colors.red.shade700 : Colors.black87))),
      tileColor: isSelected ? Colors.red.shade50 : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: isSelected ? Colors.red.shade100 : Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
            child: Text('$count', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isSelected ? Colors.red.shade700 : Colors.grey.shade600)),
          ),
          if (catObj != null) ...[
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.edit, size: 14, color: Colors.grey),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () => _mostrarDialogoCategoria(context, ref, categoria: catObj),
            ),
            const SizedBox(width: 4),
            IconButton(
              icon: Icon(catObj.activa ? Icons.visibility : Icons.visibility_off, size: 14, color: Colors.orange),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () => _toggleCategoria(context, ref, catObj),
            ),
          ],
        ],
      ),
      onTap: () {
        ref.read(reporteCategoriaFilterProvider.notifier).state = catNombre;
      },
    );
  }

  void _mostrarDialogoCategoria(BuildContext context, WidgetRef ref, {CategoriaReporte? categoria}) {
    final controller = TextEditingController(text: categoria?.nombre ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        bool isLoading = false;
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(categoria == null ? 'Nueva Categoría' : 'Editar Categoría', style: const TextStyle(fontWeight: FontWeight.bold)),
              content: Form(
                key: formKey,
                child: TextFormField(
                  controller: controller,
                  decoration: InputDecoration(
                    labelText: 'Nombre de la categoría',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Requerido' : null,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: isLoading ? null : () async {
                    if (formKey.currentState!.validate()) {
                      setStateDialog(() => isLoading = true);
                      try {
                        final repo = ref.read(reporteIncidenciaRepositoryProvider);
                        if (categoria == null) {
                          await repo.addCategoria(controller.text.trim());
                        } else {
                          await repo.updateCategoria(categoria.id, controller.text.trim(), categoria.activa);
                        }
                        ref.invalidate(categoriasReporteProvider);
                        if (context.mounted) Navigator.pop(context);
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                        }
                      } finally {
                        setStateDialog(() => isLoading = false);
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade600, foregroundColor: Colors.white),
                  child: isLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Guardar'),
                ),
              ],
            );
          }
        );
      }
    );
  }

  Future<void> _toggleCategoria(BuildContext context, WidgetRef ref, CategoriaReporte cat) async {
    try {
      final repo = ref.read(reporteIncidenciaRepositoryProvider);
      await repo.updateCategoria(cat.id, cat.nombre, !cat.activa);
      ref.invalidate(categoriasReporteProvider);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al cambiar visibilidad: $e')));
      }
    }
  }
}
