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
        title: const Text('PERMISOS DEL ROL', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.0, fontSize: 16)),
        backgroundColor: const Color(0xFF1E293B), // Slate 800 like web
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: permisosAsync.when(
        data: (permisosData) {
          _permisosForm ??= List.from(permisosData);

          if (_permisosForm!.isEmpty) {
            return const Center(child: Text('No hay módulos configurados.', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)));
          }

          final moduleGroups = {
            'RRHH Innova': [
              {'nombre': 'Dashboard', 'icono': '🏠'},
              {'nombre': 'Campanita de Notificaciones', 'icono': '🔔'}
            ],
            'RECURSOS HUMANOS': [
              {'nombre': 'Empleados', 'icono': '👥'},
              {'nombre': '+Nuevo Empleado', 'icono': '👤+'},
              {'nombre': 'Vacaciones', 'icono': '🏖️'},
              {'nombre': 'Reportes', 'icono': '📊'},
              {'nombre': 'Módulo de Reportes', 'icono': '📊'},
              {'nombre': 'Reclutamiento', 'icono': '💼'},
              {'nombre': 'Departamentos', 'icono': '🏢'},
              {'nombre': 'Reportes de Incidencia', 'icono': '⚠️'},
              {'nombre': 'Gestión de Manuales', 'icono': '📚'},
              {'nombre': 'Documentos', 'icono': '📁'},
              {'nombre': 'Archivero Legal', 'icono': '📁'},
              {'nombre': 'Faltas', 'icono': '📅'},
              {'nombre': 'Contratos', 'icono': '📝'},
              {'nombre': 'Notas', 'icono': '🗒️'},
              {'nombre': 'Perfil del Empleado', 'icono': '🧑‍💼'}
            ],
            'Departamento de IT': [
              {'nombre': 'Tickets', 'icono': '🎫'},
              {'nombre': 'Control de Usuarios', 'icono': '🔐'},
              {'nombre': 'Roles y Permisos', 'icono': '🛡️'},
              {'nombre': 'Logs de Sistema', 'icono': '📋'}
            ]
          };

          final Map<String, List<Map<String, dynamic>>> grupos = {
            'RRHH Innova': [],
            'RECURSOS HUMANOS': [],
            'Departamento de IT': [],
            'Otros': []
          };

          for (final permiso in _permisosForm!) {
            bool assigned = false;
            for (final entry in moduleGroups.entries) {
              final match = entry.value.where((m) => m['nombre'] == permiso.moduloNombre).toList();
              if (match.isNotEmpty) {
                grupos[entry.key]!.add({
                  'permiso': permiso,
                  'icono': match.first['icono'],
                });
                assigned = true;
                break;
              }
            }
            if (!assigned) {
              grupos['Otros']!.add({
                'permiso': permiso,
                'icono': '🔹',
              });
            }
          }

          List<Widget> listItems = [];
          for (final entry in grupos.entries) {
            if (entry.value.isEmpty) continue;

            IconData categoryIcon = Icons.folder;
            Color categoryColor = Colors.indigo.shade600;
            if (entry.key == 'RRHH Innova') { categoryIcon = Icons.dashboard_customize; categoryColor = Colors.indigo.shade600; }
            if (entry.key == 'RECURSOS HUMANOS') { categoryIcon = Icons.people_alt; categoryColor = Colors.teal.shade600; }
            if (entry.key == 'Departamento de IT') { categoryIcon = Icons.computer; categoryColor = Colors.orange.shade600; }

            listItems.add(
              Container(
                margin: const EdgeInsets.only(top: 24, bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: categoryColor.withValues(alpha: 0.15)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(categoryIcon, size: 18, color: categoryColor),
                    const SizedBox(width: 8),
                    Text(
                      entry.key.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: categoryColor,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            );

            for (final item in entry.value) {
              final permiso = item['permiso'] as Permiso;
              final icono = item['icono'] as String;

              listItems.add(
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.blueGrey.shade200, width: 1.0),
                    boxShadow: [
                      BoxShadow(color: Colors.blueGrey.shade100.withValues(alpha: 0.6), blurRadius: 15, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                permiso.moduloNombre == 'Cumpleañeros' ? '🎂 Cumpleañeros' : '$icono ${permiso.moduloNombre}',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF1E293B)),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Row(
                              children: [
                                Text('TODOS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.blueGrey.shade500)),
                                const SizedBox(width: 4),
                                Switch(
                                  value: _todosSeleccionados(permiso),
                                  onChanged: (v) => _toggleTodos(permiso, v),
                                  activeThumbColor: Colors.white,
                                  activeTrackColor: Colors.teal.shade500,
                                  inactiveThumbColor: Colors.blueGrey.shade300,
                                  inactiveTrackColor: Colors.blueGrey.shade100,
                                ),
                              ],
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          child: Divider(height: 1, color: Colors.blueGrey.shade100),
                        ),
                        Wrap(
                          spacing: 8,
                          runSpacing: 12,
                          alignment: WrapAlignment.start,
                          children: [
                            _buildActionChip('Ver', permiso.puedeVer, (v) => _onPuedeVerChange(permiso, v), Icons.visibility_outlined, Colors.indigo),
                            _buildActionChip('Crear', permiso.puedeCrear, (v) => _onAccionChange(permiso, v, 'crear'), Icons.add_circle_outline, Colors.teal),
                            _buildActionChip('Editar', permiso.puedeEditar, (v) => _onAccionChange(permiso, v, 'editar'), Icons.edit_outlined, Colors.orange),
                            _buildActionChip('Eliminar', permiso.puedeEliminar, (v) => _onAccionChange(permiso, v, 'eliminar'), Icons.delete_outline, Colors.red),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              );
            }
          }

          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Color(0xFF1E293B),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Configurando accesos para:',
                      style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.rol.nombre,
                      style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 28, letterSpacing: 0.5),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  children: listItems,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Colors.blueGrey.shade100)),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))
                  ],
                ),
                child: SafeArea(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _isLoading ? null : () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.blueGrey.shade600,
                          textStyle: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.0, fontSize: 13),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        ),
                        child: const Text('CANCELAR'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          textStyle: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.0, fontSize: 13),
                          elevation: 2,
                        ),
                        onPressed: _isLoading ? null : _guardarPermisos,
                        child: _isLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('GUARDAR'),
                      ),
                    ],
                  ),
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

  Widget _buildActionChip(String label, bool value, ValueChanged<bool?> onChanged, IconData icon, MaterialColor themeColor) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: value ? themeColor.shade50 : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value ? themeColor.shade300 : Colors.grey.shade300,
            width: value ? 1.5 : 1.0,
          ),
          boxShadow: value ? [BoxShadow(color: themeColor.shade100, blurRadius: 4, offset: const Offset(0, 2))] : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: value ? themeColor.shade700 : Colors.blueGrey.shade400),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: value ? FontWeight.w900 : FontWeight.w600,
                color: value ? themeColor.shade800 : Colors.blueGrey.shade600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
