import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'providers/departamento_provider.dart';
import 'models/departamento_model.dart';
import '../auth/providers/auth_provider.dart';

class DepartamentosScreen extends ConsumerStatefulWidget {
  const DepartamentosScreen({super.key});

  @override
  ConsumerState<DepartamentosScreen> createState() => _DepartamentosScreenState();
}

class _DepartamentosScreenState extends ConsumerState<DepartamentosScreen> {
  String _searchQuery = '';
  String _usuarioActual = 'Mobile User';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _usuarioActual = prefs.getString('usuarioNombre') ?? 'Mobile User';
    });
  }

  void _mostrarDialogoFormulario({Departamento? departamento}) {
    final formKey = GlobalKey<FormState>();
    String nombre = departamento?.nombre ?? '';
    String descripcion = departamento?.descripcion ?? '';
    final bool esEdicion = departamento != null;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(esEdicion ? 'Editar Departamento' : 'Nuevo Departamento'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    initialValue: nombre,
                    decoration: const InputDecoration(
                      labelText: 'Nombre',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
                    onSaved: (value) => nombre = value!,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: descripcion,
                    decoration: const InputDecoration(
                      labelText: 'Descripción',
                      border: OutlineInputBorder(),
                    ),
                    onSaved: (value) => descripcion = value ?? '',
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();
                  
                  final notifier = ref.read(departamentoProvider.notifier);
                  bool success = false;

                  if (esEdicion) {
                    final updateModel = Departamento(
                      id: departamento.id,
                      nombre: nombre,
                      descripcion: descripcion,
                      modificadoPor: _usuarioActual,
                      estado: departamento.estado,
                    );
                    success = await notifier.updateDepartamento(updateModel);
                  } else {
                    final newModel = Departamento(
                      nombre: nombre,
                      descripcion: descripcion,
                      creadoPor: _usuarioActual,
                      modificadoPor: _usuarioActual,
                    );
                    success = await notifier.addDepartamento(newModel);
                  }
                      
                  if (!context.mounted) return; 

                  if (success) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(esEdicion ? 'Departamento actualizado' : 'Departamento creado')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Ocurrió un error al guardar')),
                    );
                  }
                }
              },
              child: Text(esEdicion ? 'Actualizar' : 'Guardar'),
            ),
          ],
        );
      },
    );
  }

  void _confirmarEliminacion(Departamento departamento) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar Departamento'),
          content: Text('¿Está seguro de eliminar el departamento "${departamento.nombre}"? Esta acción no se puede deshacer.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                final notifier = ref.read(departamentoProvider.notifier);
                final success = await notifier.deleteDepartamento(departamento.id!);
                if (!context.mounted) return;
                Navigator.pop(context);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Departamento eliminado exitosamente')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Error al eliminar, verifica si tiene empleados asignados')),
                  );
                }
              },
              child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _toggleEstado(Departamento departamento) async {
    final notifier = ref.read(departamentoProvider.notifier);
    final String accion = departamento.estado == 1 ? 'desactivar' : 'activar';
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('${departamento.estado == 1 ? "Desactivar" : "Activar"} Departamento'),
          content: Text('¿Está seguro de que desea $accion "${departamento.nombre}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context); // close dialog
                final success = await notifier.toggleEstado(departamento.id!, departamento.estado ?? 1, _usuarioActual);
                if (!context.mounted) return;
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Estado actualizado exitosamente')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Error al actualizar el estado')),
                  );
                }
              },
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final departamentosAsync = ref.watch(departamentoProvider);
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Departamentos'),
        actions: [
          if (authState.hasPermission('Departamentos', 'puedeCrear'))
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: ElevatedButton.icon(
                onPressed: () => _mostrarDialogoFormulario(),
                icon: const Icon(Icons.add),
                label: const Text('Agregar'),
              ),
            )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar departamento...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: departamentosAsync.when(
              data: (departamentos) {
                final filteredDepartamentos = departamentos.where((d) {
                  final query = _searchQuery.toLowerCase();
                  return d.nombre.toLowerCase().contains(query) ||
                         (d.descripcion?.toLowerCase().contains(query) ?? false);
                }).toList();

                if (filteredDepartamentos.isEmpty) {
                  return const Center(child: Text('No se encontraron departamentos.', style: TextStyle(fontStyle: FontStyle.italic)));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredDepartamentos.length,
                  itemBuilder: (context, index) {
                    final depto = filteredDepartamentos[index];
                    final bool isActivo = depto.estado == 1;

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    depto.nombre,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isActivo ? Colors.green[50] : Colors.red[50],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    isActivo ? 'Activo' : 'Inactivo',
                                    style: TextStyle(
                                      color: isActivo ? Colors.green[700] : Colors.red[700],
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              depto.descripcion?.isNotEmpty == true ? depto.descripcion! : 'Sin descripción',
                              style: TextStyle(color: Colors.grey[600], fontSize: 14),
                            ),
                            const SizedBox(height: 8),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (authState.hasPermission('Departamentos', 'puedeEditar'))
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                                    tooltip: 'Editar',
                                    onPressed: () => _mostrarDialogoFormulario(departamento: depto),
                                  ),
                                if (authState.hasPermission('Departamentos', 'puedeEditar'))
                                  IconButton(
                                    icon: Icon(isActivo ? Icons.block : Icons.check_circle_outline, color: isActivo ? Colors.orange : Colors.green, size: 20),
                                    tooltip: isActivo ? 'Desactivar' : 'Activar',
                                    onPressed: () => _toggleEstado(depto),
                                  ),
                                if (authState.hasPermission('Departamentos', 'puedeEliminar'))
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                    tooltip: 'Eliminar',
                                    onPressed: () => _confirmarEliminacion(depto),
                                  ),
                              ],
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
    );
  }
}
