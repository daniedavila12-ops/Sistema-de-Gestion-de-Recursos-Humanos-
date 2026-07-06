// CREADO POR: DANIEL INNOVA

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'dart:convert';
import '../providers/reporte_incidencia_provider.dart';

class CrearReporteIncidenciaScreen extends ConsumerStatefulWidget {
  const CrearReporteIncidenciaScreen({super.key});

  @override
  ConsumerState<CrearReporteIncidenciaScreen> createState() => _CrearReporteIncidenciaScreenState();
}

class _CrearReporteIncidenciaScreenState extends ConsumerState<CrearReporteIncidenciaScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<TextEditingController> _identidadControllers = [TextEditingController()];
  
  MaskTextInputFormatter _crearFormatter() {
    return MaskTextInputFormatter(
      mask: '####-####-#####',
      filter: {"#": RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy,
    );
  }
  
  late final List<MaskTextInputFormatter> _identidadFormatters = [_crearFormatter()];
  
  final _temaController = TextEditingController();
  final _descripcionController = TextEditingController();

  void _agregarPersona() {
    setState(() {
      _identidadControllers.add(TextEditingController());
      _identidadFormatters.add(_crearFormatter());
    });
  }

  void _removerPersona(int index) {
    if (_identidadControllers.length > 1) {
      setState(() {
        _identidadControllers[index].dispose();
        _identidadControllers.removeAt(index);
        _identidadFormatters.removeAt(index);
      });
    }
  }

  String _prioridadSeleccionada = 'Media';
  String _categoriaSeleccionada = 'General';
  String? _archivoRuta;
  bool _isLoading = false;
  String _jefeReporta = 'Usuario';

  final List<String> _prioridades = ['Baja', 'Media', 'Alta', 'Urgente'];

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      String userName = 'Usuario';
      String rolNombre = '';
      
      try {
        final userDataString = prefs.getString('user_data');
        if (userDataString != null) {
          final userData = jsonDecode(userDataString);
          userName = userData['nombre'] ?? 'Usuario';
          
          final rolId = userData['rol'] ?? userData['rol_id'];
          if (rolId == 1) {
            rolNombre = ' - Administrador IT';
          } else if (rolId == 2) {
            rolNombre = ' - Recursos Humanos';
          } else if (rolId == 3) {
            rolNombre = ' - Empleado';
          }
        } else {
          userName = prefs.getString('usuarioNombre') ?? 'Usuario';
        }
      } catch (e) {
        userName = prefs.getString('usuarioNombre') ?? 'Usuario';
      }
      
      _jefeReporta = '$userName$rolNombre';
    });
  }

  @override
  void dispose() {
    for (var controller in _identidadControllers) {
      controller.dispose();
    }
    _temaController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarArchivo() async {
    FilePickerResult? result = await FilePicker.pickFiles();
    if (result != null) {
      setState(() {
        _archivoRuta = result.files.single.path;
      });
    }
  }

  Future<void> _crearReporte() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final repository = ref.read(reporteIncidenciaRepositoryProvider);
      
      final identidades = _identidadControllers
          .map((c) => c.text)
          .where((t) => t.isNotEmpty)
          .join(', ');

      final success = await repository.createReporte(
        jefeReporta: _jefeReporta,
        identidad: identidades,
        categoria: _categoriaSeleccionada,
        prioridad: _prioridadSeleccionada,
        tema: _temaController.text,
        descripcion: _descripcionController.text,
        archivoPath: _archivoRuta,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reporte creado exitosamente')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al crear reporte: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo Reporte de Incidencia')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _identidadControllers.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _identidadControllers[index],
                            inputFormatters: [_identidadFormatters[index]],
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Número de Identidad (Reportado ${index + 1})',
                              hintText: 'Ej: 0801-1990-12345',
                              prefixIcon: const Icon(Icons.badge),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Campo requerido';
                              if (value.length < 15) return 'Formato incompleto';
                              return null;
                            },
                          ),
                        ),
                        if (_identidadControllers.length > 1)
                          IconButton(
                            icon: const Icon(Icons.remove_circle, color: Colors.red),
                            onPressed: () => _removerPersona(index),
                          ),
                      ],
                    ),
                  );
                },
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _agregarPersona,
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar otra persona'),
                ),
              ),
              const SizedBox(height: 16),
              
              ref.watch(categoriasReporteProvider).when(
                data: (categoriasList) {
                  final categoriasActivas = categoriasList.where((c) => c.activa).map((c) => c.nombre).toList();
                  final val = categoriasActivas.contains(_categoriaSeleccionada) ? _categoriaSeleccionada : (categoriasActivas.isNotEmpty ? categoriasActivas.first : null);
                  return DropdownButtonFormField<String>(
                    initialValue: val,
                    decoration: InputDecoration(
                      labelText: 'Categoría',
                      prefixIcon: const Icon(Icons.folder),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    items: categoriasActivas.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (newVal) {
                      if (newVal != null) {
                        setState(() => _categoriaSeleccionada = newVal);
                      }
                    },
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (err, stack) => Text('Error cargando categorías', style: TextStyle(color: Colors.red)),
              ),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                initialValue: _prioridadSeleccionada,
                decoration: InputDecoration(
                  labelText: 'Prioridad',
                  prefixIcon: const Icon(Icons.flag),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                items: _prioridades.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                onChanged: (val) => setState(() => _prioridadSeleccionada = val!),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _temaController,
                decoration: InputDecoration(
                  labelText: 'Tema / Asunto',
                  prefixIcon: const Icon(Icons.title),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                validator: (value) => value == null || value.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descripcionController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Descripción Detallada',
                  prefixIcon: const Icon(Icons.description),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                validator: (value) => value == null || value.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: Text(
                      _archivoRuta == null ? 'Sin archivo adjunto' : 'Archivo seleccionado: ${_archivoRuta!.split('/').last}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.attach_file),
                    onPressed: _seleccionarArchivo,
                    tooltip: 'Adjuntar evidencia',
                  ),
                ],
              ),
              const SizedBox(height: 32),

              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.save, color: Colors.white),
                        label: const Text('Crear Reporte', style: TextStyle(color: Colors.white, fontSize: 16)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade600,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: _crearReporte,
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
