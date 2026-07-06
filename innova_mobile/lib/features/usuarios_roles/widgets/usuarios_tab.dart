import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/usuarios_roles_provider.dart';
import '../models/usuario_admin_model.dart';
import '../models/rol_model.dart';
import 'usuario_form_dialog.dart';
import 'permisos_dialog.dart';
import 'package:intl/intl.dart';

class UsuariosTab extends ConsumerWidget {
  const UsuariosTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuariosAsync = ref.watch(usuariosProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: usuariosAsync.when(
        data: (usuarios) {
          if (usuarios.isEmpty) {
            return const Center(child: Text('No hay usuarios registrados.', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)));
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
    );
  }

  Widget _buildUsuarioCard(BuildContext context, WidgetRef ref, UsuarioAdmin usuario) {
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
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
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
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar
                    Container(
                      height: 48,
                      width: 48,
                      decoration: BoxDecoration(
                        color: Colors.blueGrey.shade100,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.blueGrey.shade200),
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0,2))],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        usuario.nombre.isNotEmpty ? usuario.nombre[0].toUpperCase() : 'U',
                        style: TextStyle(
                          color: Colors.blueGrey.shade500,
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  usuario.nombre,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                              ),
                              if (usuario.incidentesPendientes > 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)],
                                  ),
                                  child: Text(
                                    '${usuario.incidentesPendientes} Pendiente${usuario.incidentesPendientes > 1 ? 's' : ''}',
                                    style: TextStyle(
                                      color: Colors.red.shade600,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 10,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            usuario.email,
                            style: TextStyle(
                              color: Colors.blueGrey.shade500,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.purple.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  (usuario.rolNombre?.toUpperCase() ?? 'SIN ROL'),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.purple.shade600,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: usuario.estado ? Colors.green.shade50 : Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  usuario.estado ? 'ACTIVO' : 'INACTIVO',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: usuario.estado ? Colors.green.shade600 : Colors.red.shade600,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ÚLTIMO LOGIN',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: Colors.blueGrey.shade400,
                            letterSpacing: 1.0,
                          ),
                        ),
                        Text(
                          usuario.ultimoLogin != null
                              ? DateFormat('dd/MM/yyyy, hh:mm a').format(usuario.ultimoLogin!)
                              : 'Nunca',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.blueGrey.shade600,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        _buildActionButton(
                          icon: Icons.edit,
                          color: Colors.blue,
                          tooltip: 'Editar',
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (_) => UsuarioFormDialog(usuario: usuario),
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        _buildActionButton(
                          icon: usuario.estado ? Icons.block : Icons.check_circle,
                          color: usuario.estado ? Colors.red : Colors.green,
                          tooltip: usuario.estado ? 'Desactivar' : 'Activar',
                          onTap: () async {
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
                    )
                  ],
                )
              ],
            ),
          ),
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
