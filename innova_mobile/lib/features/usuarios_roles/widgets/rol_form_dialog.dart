import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/rol_model.dart';
import '../providers/usuarios_roles_provider.dart';

class RolFormDialog extends ConsumerStatefulWidget {
  final Rol? rol;

  const RolFormDialog({super.key, this.rol});

  @override
  ConsumerState<RolFormDialog> createState() => _RolFormDialogState();
}

class _RolFormDialogState extends ConsumerState<RolFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _nombre;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nombre = widget.rol?.nombre ?? '';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isLoading = true);
    try {
      final repo = ref.read(usuariosRolesRepositoryProvider);
      if (widget.rol == null) {
        await repo.createRol(_nombre);
      } else {
        await repo.updateRol(widget.rol!.id, _nombre);
      }
      ref.invalidate(rolesProvider);
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
    return AlertDialog(
      title: Text(widget.rol == null ? 'Crear Rol' : 'Editar Rol'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          initialValue: _nombre,
          decoration: const InputDecoration(
            labelText: 'Nombre del Rol',
            border: OutlineInputBorder(),
          ),
          validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
          onSaved: (v) => _nombre = v!,
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading ? const CircularProgressIndicator() : Text(widget.rol == null ? 'Guardar' : 'Actualizar'),
        ),
      ],
    );
  }
}
