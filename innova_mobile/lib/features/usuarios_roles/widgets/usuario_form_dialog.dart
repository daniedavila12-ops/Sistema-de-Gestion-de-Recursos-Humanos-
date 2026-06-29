import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/usuario_admin_model.dart';
import '../providers/usuarios_roles_provider.dart';

class UsuarioFormDialog extends ConsumerStatefulWidget {
  final UsuarioAdmin? usuario;

  const UsuarioFormDialog({super.key, this.usuario});

  @override
  ConsumerState<UsuarioFormDialog> createState() => _UsuarioFormDialogState();
}

class _UsuarioFormDialogState extends ConsumerState<UsuarioFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _nombre;
  late String _email;
  String _password = '';
  int? _rolId;
  late bool _estado;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nombre = widget.usuario?.nombre ?? '';
    _email = widget.usuario?.email ?? '';
    _rolId = widget.usuario?.rolId;
    _estado = widget.usuario?.estado ?? true;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    if (_rolId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, seleccione un rol')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final repo = ref.read(usuariosRolesRepositoryProvider);
      if (widget.usuario == null) {
        if (_password.isEmpty) {
          throw Exception('La contraseña es requerida para nuevos usuarios');
        }
        await repo.createUsuario(
          nombre: _nombre,
          email: _email,
          password: _password,
          rolId: _rolId!,
        );
      } else {
        await repo.updateUsuario(
          id: widget.usuario!.id,
          nombre: _nombre,
          email: _email,
          password: _password,
          rolId: _rolId!,
          estado: _estado,
        );
      }
      ref.invalidate(usuariosProvider);
      if (mounted) Navigator.pop(context);
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
    final rolesAsync = ref.watch(rolesProvider);

    return AlertDialog(
      title: Text(widget.usuario == null ? 'Crear Usuario' : 'Editar Usuario'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: _nombre,
                decoration: const InputDecoration(labelText: 'Nombre Completo'),
                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                onSaved: (v) => _nombre = v!,
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Correo Electrónico'),
                validator: (v) => v == null || v.isEmpty || !v.contains('@') ? 'Correo inválido' : null,
                onSaved: (v) => _email = v!,
              ),
              const SizedBox(height: 12),
              TextFormField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: widget.usuario == null ? 'Contraseña' : 'Nueva Contraseña (opcional)',
                ),
                validator: (v) {
                  if (widget.usuario == null && (v == null || v.isEmpty)) {
                    return 'Requerido';
                  }
                  return null;
                },
                onSaved: (v) => _password = v ?? '',
              ),
              const SizedBox(height: 12),
              rolesAsync.when(
                data: (roles) => DropdownButtonFormField<int>(
                  initialValue: _rolId,
                  decoration: const InputDecoration(labelText: 'Rol del Sistema'),
                  items: roles.map((r) => DropdownMenuItem(value: r.id, child: Text(r.nombre))).toList(),
                  onChanged: (v) => setState(() => _rolId = v),
                ),
                loading: () => const CircularProgressIndicator(),
                error: (err, _) => Text('Error al cargar roles: $err'),
              ),
              if (widget.usuario != null) ...[
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Usuario Activo'),
                  value: _estado,
                  onChanged: (v) => setState(() => _estado = v),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading ? const CircularProgressIndicator() : Text(widget.usuario == null ? 'Guardar' : 'Actualizar'),
        ),
      ],
    );
  }
}
