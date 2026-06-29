import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/auth_provider.dart';
import 'package:innova_mobile/core/constants/api_constants.dart';

class PerfilUsuarioDialog extends ConsumerStatefulWidget {
  const PerfilUsuarioDialog({super.key});

  @override
  ConsumerState<PerfilUsuarioDialog> createState() => _PerfilUsuarioDialogState();
}

class _PerfilUsuarioDialogState extends ConsumerState<PerfilUsuarioDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _actualController = TextEditingController();
  final TextEditingController _nuevaController = TextEditingController();
  final TextEditingController _confirmarController = TextEditingController();
  
  bool _isLoading = false;
  String _fotoUsuario = '';
  String _rolNombre = 'Cargando...';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _fotoUsuario = prefs.getString('usuarioFoto') ?? '';
      int rol = int.tryParse(prefs.getString('usuarioRol') ?? '2') ?? 2;
      if (rol == 1) {
        _rolNombre = 'Administrador IT';
      } else if (rol == 2) {
        _rolNombre = 'Recursos Humanos';
      } else {
        _rolNombre = 'Empleado';
      }
    });
  }

  Future<void> _cambiarFoto() async {
    final user = ref.read(authProvider).user;
    if (user == null) return;

    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      setState(() => _isLoading = true);
      try {
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('${ApiConstants.baseUrl}/api/auth/${user.id}/foto'),
        );
        request.files.add(await http.MultipartFile.fromPath('foto', result.files.single.path!));
        
        var response = await request.send();
        if (response.statusCode == 200) {
          final respStr = await response.stream.bytesToString();
          final data = json.decode(respStr);
          final nuevaFoto = data['fotoUrl'];

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('usuarioFoto', nuevaFoto);

          setState(() {
            _fotoUsuario = nuevaFoto;
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Foto actualizada correctamente')));
          }
        } else {
          throw Exception('Error al actualizar foto');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _cambiarPassword() async {
    if (!_formKey.currentState!.validate()) return;
    if (_nuevaController.text != _confirmarController.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Las contraseñas nuevas no coinciden')));
      return;
    }

    final user = ref.read(authProvider).user;
    if (user == null) return;

    setState(() => _isLoading = true);
    try {
      final res = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/api/auth/cambiar-password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'id': user.id,
          'actual': _actualController.text,
          'nueva': _nuevaController.text,
        }),
      );

      if (res.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Contraseña actualizada correctamente')));
          Navigator.of(context).pop();
        }
      } else {
        final err = json.decode(res.body);
        throw Exception(err['mensaje'] ?? 'Error al actualizar contraseña');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _cerrarSesion() async {
    await ref.read(authProvider.notifier).logout();
    if (mounted) {
      Navigator.of(context).pop();
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final initial = (user?.nombre.isNotEmpty ?? false) ? user!.nombre[0].toUpperCase() : 'U';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('👤 Perfil de Usuario', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
                ],
              ),
              const Divider(),
              const SizedBox(height: 16),
              
              // FOTO DE PERFIL
              GestureDetector(
                onTap: _isLoading ? null : _cambiarFoto,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      backgroundImage: _fotoUsuario.isNotEmpty ? NetworkImage('${ApiConstants.baseUrl}$_fotoUsuario') : null,
                      child: _fotoUsuario.isEmpty ? Text(initial, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)) : null,
                    ),
                    if (_isLoading)
                      const CircularProgressIndicator(color: Colors.white),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(user?.nombre ?? 'Usuario', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(_rolNombre, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
              
              const SizedBox(height: 24),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Seguridad - Cambiar Contraseña', style: TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
              ),
              const SizedBox(height: 16),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _actualController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Contraseña Actual',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      validator: (v) => v!.isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _nuevaController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Nueva Contraseña',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      validator: (v) => v!.isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _confirmarController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Confirmar Contraseña',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      validator: (v) => v!.isEmpty ? 'Requerido' : null,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('CANCELAR', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _cambiarPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('ACTUALIZAR', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const Divider(height: 32),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isLoading ? null : _cerrarSesion,
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text('CERRAR SESIÓN', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
