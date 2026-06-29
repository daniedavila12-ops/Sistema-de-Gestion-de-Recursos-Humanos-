import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/usuarios_roles_repository.dart';
import '../models/usuario_admin_model.dart';
import '../models/rol_model.dart';
import '../models/permiso_model.dart';

// Provider base para el repositorio
final usuariosRolesRepositoryProvider = Provider((ref) => UsuariosRolesRepository());

// Proveedor de Usuarios
final usuariosProvider = FutureProvider.autoDispose<List<UsuarioAdmin>>((ref) async {
  final repository = ref.watch(usuariosRolesRepositoryProvider);
  return repository.getUsuarios();
});

// Proveedor de Roles
final rolesProvider = FutureProvider.autoDispose<List<Rol>>((ref) async {
  final repository = ref.watch(usuariosRolesRepositoryProvider);
  return repository.getRoles();
});

// Proveedor de Permisos (Family por Rol)
final permisosRolProvider = FutureProvider.autoDispose.family<List<Permiso>, int>((ref, rolId) async {
  final repository = ref.watch(usuariosRolesRepositoryProvider);
  return repository.getPermisosByRol(rolId);
});

// Provider para la creación/edición (puedes usar el repositorio directamente en los widgets
// o crear un Notifier, aquí lo mantenemos simple consumiendo el repository y haciendo ref.invalidate)
