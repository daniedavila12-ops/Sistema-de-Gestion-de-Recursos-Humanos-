import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/usuarios_roles_provider.dart';
import '../models/rol_model.dart';
import 'rol_form_dialog.dart';
import 'permisos_dialog.dart';
import '../../auth/providers/auth_provider.dart';

class RolesTab extends ConsumerWidget {
  const RolesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rolesAsync = ref.watch(rolesProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: rolesAsync.when(
        data: (roles) {
          if (roles.isEmpty) {
            return const Center(child: Text('No hay roles registrados.', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)));
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(rolesProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: roles.length,
              itemBuilder: (context, index) {
                final rol = roles[index];
                return _buildRolCard(context, ref, rol);
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildRolCard(BuildContext context, WidgetRef ref, Rol rol) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.blueGrey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.blueGrey.shade200.withValues(alpha: 0.5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'ID: ${rol.id}',
                    style: TextStyle(
                      color: Colors.blueGrey.shade600,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    rol.nombre,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Builder(
              builder: (context) {
                final authState = ref.watch(authProvider);
                final puedeEditar = authState.hasPermission('Roles y Permisos', 'puedeEditar');
                final puedeEliminar = authState.hasPermission('Roles y Permisos', 'puedeEliminar');

                return Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (puedeEditar)
                      _buildActionButton(
                        icon: Icons.edit,
                        color: Colors.blue,
                        tooltip: 'Editar',
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (_) => RolFormDialog(rol: rol),
                          );
                        },
                      ),
                    if (puedeEditar)
                      const SizedBox(width: 8),
                    if (puedeEditar)
                      Material(
                        color: Colors.purple.shade50,
                        borderRadius: BorderRadius.circular(10),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => PermisosDialog(rol: rol)),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            child: Row(
                              children: [
                                Icon(Icons.shield, color: Colors.purple.shade600, size: 18),
                                const SizedBox(width: 6),
                                Text(
                                  'Permisos',
                                  style: TextStyle(
                                    color: Colors.purple.shade600,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    if (puedeEliminar)
                      const SizedBox(width: 8),
                    if (puedeEliminar)
                      _buildActionButton(
                        icon: Icons.delete,
                        color: Colors.red,
                        tooltip: 'Eliminar',
                        onTap: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              title: const Text('Eliminar Rol', style: TextStyle(fontWeight: FontWeight.bold)),
                              content: Text('¿Está seguro de eliminar el rol "${rol.nombre}"?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, true), 
                                  child: const Text('Eliminar', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            try {
                              final repo = ref.read(usuariosRolesRepositoryProvider);
                              await repo.deleteRol(rol.id);
                              ref.invalidate(rolesProvider);
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error al eliminar rol: $e')),
                                );
                              }
                            }
                          }
                        },
                      ),
                  ],
                );
              }
            )
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required MaterialColor color, required String tooltip, required VoidCallback onTap}) {
    return Material(
      color: color.shade50,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Icon(icon, color: color.shade600, size: 18),
        ),
      ),
    );
  }
}
