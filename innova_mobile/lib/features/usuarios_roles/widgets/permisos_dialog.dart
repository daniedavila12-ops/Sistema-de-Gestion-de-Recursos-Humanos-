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

  bool _todosSeleccionados(Permiso p) {
    return p.puedeVer && p.puedeCrear && p.puedeEditar && p.puedeEliminar;
  }

  void _toggleTodos(Permiso p, bool? val) {
    setState(() {
      final index = _permisosForm!.indexOf(p);
      bool valBool = val ?? false;
      _permisosForm![index] = p.copyWith(
        puedeVer: valBool,
        puedeCrear: valBool,
        puedeEditar: valBool,
        puedeEliminar: valBool,
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
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('PERMISOS DEL ROL', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.0)),
        backgroundColor: Colors.purple.shade800,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: permisosAsync.when(
        data: (permisosData) {
          _permisosForm ??= List.from(permisosData);

          if (_permisosForm!.isEmpty) {
            return const Center(child: Text('No hay módulos configurados.', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)));
          }

          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                color: Colors.purple.shade800,
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(color: Colors.purple.shade100, fontSize: 14),
                    children: [
                      const TextSpan(text: 'Configurando accesos para: '),
                      TextSpan(text: widget.rol.nombre, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _permisosForm!.length,
                  itemBuilder: (context, index) {
                    final permiso = _permisosForm![index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.blueGrey.shade200),
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1))],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  permiso.moduloNombre,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF1E293B)),
                                ),
                                Row(
                                  children: [
                                    const Text('TODOS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.purple)),
                                    Checkbox(
                                      value: _todosSeleccionados(permiso),
                                      onChanged: (v) => _toggleTodos(permiso, v),
                                      activeColor: Colors.purple,
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const Divider(),
                            Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(child: _buildCheckbox('Ver', permiso.puedeVer, (v) => _onPuedeVerChange(permiso, v))),
                                    Expanded(child: _buildCheckbox('Crear', permiso.puedeCrear, (v) => _onAccionChange(permiso, v, 'crear'))),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(child: _buildCheckbox('Editar', permiso.puedeEditar, (v) => _onAccionChange(permiso, v, 'editar'))),
                                    Expanded(child: _buildCheckbox('Eliminar', permiso.puedeEliminar, (v) => _onAccionChange(permiso, v, 'eliminar'))),
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
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Colors.blueGrey.shade100)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isLoading ? null : () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blueGrey.shade600,
                        textStyle: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.0, fontSize: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: const Text('CANCELAR'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        textStyle: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.0, fontSize: 12),
                        elevation: 4,
                      ),
                      onPressed: _isLoading ? null : _guardarPermisos,
                      child: _isLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('GUARDAR PERMISOS'),
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

  Widget _buildCheckbox(String label, bool value, ValueChanged<bool?> onChanged) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.purple,
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }
}
