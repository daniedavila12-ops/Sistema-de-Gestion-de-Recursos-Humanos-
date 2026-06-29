import '../../../core/api/api_client.dart';
import '../models/usuario_admin_model.dart';
import '../models/rol_model.dart';
import '../models/permiso_model.dart';

class UsuariosRolesRepository {
  // USUARIOS
  Future<List<UsuarioAdmin>> getUsuarios() async {
    final response = await apiClient.get('/usuarios');
    final List data = response.data;
    return data.map((json) => UsuarioAdmin.fromJson(json)).toList();
  }

  Future<bool> createUsuario({
    required String nombre,
    required String email,
    required String password,
    required int rolId,
  }) async {
    final response = await apiClient.post('/usuarios', data: {
      'nombre': nombre,
      'email': email,
      'password': password,
      'rol_id': rolId,
    });
    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<bool> updateUsuario({
    required int id,
    required String nombre,
    required String email,
    String? password,
    required int rolId,
    required bool estado,
  }) async {
    final Map<String, dynamic> data = {
      'nombre': nombre,
      'email': email,
      'rol_id': rolId,
      'estado': estado ? 1 : 0,
    };
    if (password != null && password.isNotEmpty) {
      data['password'] = password;
    }
    final response = await apiClient.put('/usuarios/$id', data: data);
    return response.statusCode == 200;
  }

  Future<bool> updateEstadoUsuario(int id, bool estado) async {
    final response = await apiClient.put('/usuarios/$id/estado', data: {
      'estado': estado ? 1 : 0,
    });
    return response.statusCode == 200;
  }

  // ROLES
  Future<List<Rol>> getRoles() async {
    final response = await apiClient.get('/roles');
    final List data = response.data;
    return data.map((json) => Rol.fromJson(json)).toList();
  }

  Future<bool> createRol(String nombre) async {
    final response = await apiClient.post('/roles', data: {
      'nombre': nombre,
    });
    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<bool> updateRol(int id, String nombre) async {
    final response = await apiClient.put('/roles/$id', data: {
      'nombre': nombre,
    });
    return response.statusCode == 200;
  }

  Future<bool> deleteRol(int id) async {
    final response = await apiClient.delete('/roles/$id');
    return response.statusCode == 200;
  }

  // PERMISOS
  Future<List<Permiso>> getPermisosByRol(int rolId) async {
    final response = await apiClient.get('/roles/$rolId/permisos');
    final List data = response.data;
    return data.map((json) => Permiso.fromJson(json)).toList();
  }

  Future<bool> updatePermisos(int rolId, List<Permiso> permisos) async {
    final response = await apiClient.put('/roles/$rolId/permisos', data: {
      'permisos': permisos.map((p) => p.toJson()).toList(),
    });
    return response.statusCode == 200;
  }
}
