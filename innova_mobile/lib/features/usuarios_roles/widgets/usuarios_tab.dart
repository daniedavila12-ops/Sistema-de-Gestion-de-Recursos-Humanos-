import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/usuarios_roles_provider.dart';
import '../models/usuario_admin_model.dart';
import '../models/rol_model.dart';
import 'usuario_form_dialog.dart';
import 'permisos_dialog.dart';

class UsuariosTab extends ConsumerWidget {
  const UsuariosTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuariosAsync = ref.watch(usuariosProvider);

    return Scaffold(
      body: usuariosAsync.when(
        data: (usuarios) {
          if (usuarios.isEmpty) {
            return const Center(child: Text('No hay usuarios registrados.'));
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(usuariosProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: usuarios.length,
              itemBuilder: (context, index) {
                final usuario = usuarios[index];
                return _buildUsuarioCard(context, ref, usuario);
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
            builder: (_) => const UsuarioFormDialog(),
          );
        },
        label: const Text('Crear Usuario'),
        icon: const Icon(Icons.person_add),
      ),
    );
  }

  Widget _buildUsuarioCard(BuildContext context, WidgetRef ref, UsuarioAdmin usuario) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: ListTile(
        onTap: () {
          if (usuario.rolId != null) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => PermisosDialog(
                  rol: Rol(id: usuario.rolId!, nombre: usuario.rolNombre ?? 'Desconocido'),
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Este usuario no tiene un rol asignado')),
            );
          }
        },
        leading: CircleAvatar(
          backgroundColor: usuario.estado ? Colors.blue : Colors.grey,
          child: Text(usuario.nombre.isNotEmpty ? usuario.nombre[0].toUpperCase() : 'U'),
        ),
        title: Row(
          children: [
            Expanded(child: Text(usuario.nombre, style: const TextStyle(fontWeight: FontWeight.bold))),
            const SizedBox(width: 4),
            const Icon(Icons.shield, size: 14, color: Colors.purple),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(usuario.email),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.purple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    usuario.rolNombre ?? 'Sin Rol',
                    style: const TextStyle(fontSize: 12, color: Colors.purple, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: usuario.estado ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    usuario.estado ? 'Activo' : 'Inactivo',
                    style: TextStyle(
                      fontSize: 12,
                      color: usuario.estado ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => UsuarioFormDialog(usuario: usuario),
                );
              },
            ),
            IconButton(
              icon: Icon(
                usuario.estado ? Icons.block : Icons.check_circle,
                color: usuario.estado ? Colors.red : Colors.green,
              ),
              onPressed: () async {
                final repo = ref.read(usuariosRolesRepositoryProvider);
                try {
                  await repo.updateEstadoUsuario(usuario.id, !usuario.estado);
                  ref.invalidate(usuariosProvider);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error al cambiar estado: $e')),
                    );
                  }
                }
              },
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }
}
