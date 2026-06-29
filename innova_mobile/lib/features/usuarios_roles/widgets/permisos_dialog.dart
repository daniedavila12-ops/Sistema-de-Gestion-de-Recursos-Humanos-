import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/rol_model.dart';
import '../models/permiso_model.dart';
import '../providers/usuarios_roles_provider.dart';

class PermisosDialog extends ConsumerStatefulWidget {
  final Rol rol;

  const PermisosDialog({super.key, required this.rol});

  @override
  ConsumerState<PermisosDialog> createState() => _PermisosDialogState();
}

class _PermisosDialogState extends ConsumerState<PermisosDialog> {
  List<Permiso>? _permisosForm;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // We get the data using the provider directly inside the build method,
    // but we need a local copy to edit before saving.
  }

  void _onPuedeVerChange(Permiso p, bool? val) {
    setState(() {
      final index = _permisosForm!.indexOf(p);
      bool puedeVer = val ?? false;
      _permisosForm![index] = p.copyWith(
        puedeVer: puedeVer,
        puedeCrear: puedeVer ? p.puedeCrear : false,
        puedeEditar: puedeVer ? p.puedeEditar : false,
        puedeEliminar: puedeVer ? p.puedeEliminar : false,
      );
    });
  }

  void _onAccionChange(Permiso p, bool? val, String type) {
    setState(() {
      final index = _permisosForm!.indexOf(p);
      bool valBool = val ?? false;
      bool ver = p.puedeVer;
      if (valBool) ver = true;

      _permisosForm![index] = p.copyWith(
        puedeVer: ver,
        puedeCrear: type == 'crear' ? valBool : p.puedeCrear,
        puedeEditar: type == 'editar' ? valBool : p.puedeEditar,
        puedeEliminar: type == 'eliminar' ? valBool : p.puedeEliminar,
      );
    });
  }

  Future<void> _guardarPermisos() async {
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(usuariosRolesRepositoryProvider);
      await repo.updatePermisos(widget.rol.id, _permisosForm!);
      ref.invalidate(permisosRolProvider(widget.rol.id));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permisos actualizados exitosamente')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final permisosAsync = ref.watch(permisosRolProvider(widget.rol.id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Permisos del Rol'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: permisosAsync.when(
        data: (permisosData) {
          // Inicializar la copia local
          _permisosForm ??= List.from(permisosData);

          if (_permisosForm!.isEmpty) {
            return const Center(child: Text('No hay módulos configurados.'));
          }

          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: Colors.purple.shade50,
                child: Text(
                  'Configurando accesos para: ${widget.rol.nombre}',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.purple),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: _permisosForm!.length,
                  itemBuilder: (context, index) {
                    final permiso = _permisosForm![index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              permiso.moduloNombre,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const Divider(),
                            Wrap(
                              spacing: 20,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text('Ver'),
                                    Checkbox(
                                      value: permiso.puedeVer,
                                      onChanged: (v) => _onPuedeVerChange(permiso, v),
                                      activeColor: Colors.purple,
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text('Crear'),
                                    Checkbox(
                                      value: permiso.puedeCrear,
                                      onChanged: (v) => _onAccionChange(permiso, v, 'crear'),
                                      activeColor: Colors.purple,
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text('Editar'),
                                    Checkbox(
                                      value: permiso.puedeEditar,
                                      onChanged: (v) => _onAccionChange(permiso, v, 'editar'),
                                      activeColor: Colors.purple,
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text('Eliminar'),
                                    Checkbox(
                                      value: permiso.puedeEliminar,
                                      onChanged: (v) => _onAccionChange(permiso, v, 'eliminar'),
                                      activeColor: Colors.purple,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isLoading ? null : () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, foregroundColor: Colors.white),
                      onPressed: _isLoading ? null : _guardarPermisos,
                      child: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white)) : const Text('Guardar Permisos'),
                    ),
                  ],
                ),
              )
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
