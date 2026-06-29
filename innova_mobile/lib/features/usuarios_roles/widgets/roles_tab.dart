import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/usuarios_roles_provider.dart';
import '../models/rol_model.dart';
import 'rol_form_dialog.dart';
import 'permisos_dialog.dart';

class RolesTab extends ConsumerWidget {
  const RolesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rolesAsync = ref.watch(rolesProvider);

    return Scaffold(
      body: rolesAsync.when(
        data: (roles) {
          if (roles.isEmpty) {
            return const Center(child: Text('No hay roles registrados.'));
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => const RolFormDialog(),
          );
        },
        label: const Text('Crear Rol'),
        icon: const Icon(Icons.security),
      ),
    );
  }

  Widget _buildRolCard(BuildContext context, WidgetRef ref, Rol rol) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.purple.withValues(alpha: 0.2),
          child: Text(rol.id.toString(), style: const TextStyle(color: Colors.purple, fontWeight: FontWeight.bold)),
        ),
        title: Text(rol.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.shield, color: Colors.purple),
              tooltip: 'Gestionar Permisos',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => PermisosDialog(rol: rol)),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              tooltip: 'Editar Nombre',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => RolFormDialog(rol: rol),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              tooltip: 'Eliminar Rol',
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Eliminar Rol'),
                    content: Text('¿Está seguro de eliminar el rol "${rol.nombre}"?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
                      TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Eliminar', style: TextStyle(color: Colors.red))),
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
        ),
      ),
    );
  }
}
