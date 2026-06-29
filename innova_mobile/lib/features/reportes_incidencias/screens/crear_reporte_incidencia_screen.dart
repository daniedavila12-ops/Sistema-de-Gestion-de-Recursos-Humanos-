// CREADO POR: DANIEL INNOVA

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/reporte_incidencia_provider.dart';

class CrearReporteIncidenciaScreen extends ConsumerStatefulWidget {
  const CrearReporteIncidenciaScreen({super.key});

  @override
  ConsumerState<CrearReporteIncidenciaScreen> createState() => _CrearReporteIncidenciaScreenState();
}

class _CrearReporteIncidenciaScreenState extends ConsumerState<CrearReporteIncidenciaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identidadController = TextEditingController();
  final _temaController = TextEditingController();
  final _descripcionController = TextEditingController();

  String _prioridadSeleccionada = 'Media';
  String _categoriaSeleccionada = 'General';
  String? _archivoRuta;
  bool _isLoading = false;
  String _jefeReporta = 'Usuario';

  final List<String> _prioridades = ['Baja', 'Media', 'Alta', 'Urgente'];
  final List<String> _categorias = ['General', 'Asistencia', 'Comportamiento', 'Infraestructura', 'Hardware/Software']; // Simulación de categorías

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _jefeReporta = prefs.getString('usuario_nombre') ?? 'Usuario';
    });
  }

  @override
  void dispose() {
    _identidadController.dispose();
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
      
      final success = await repository.createReporte(
        jefeReporta: _jefeReporta,
        identidad: _identidadController.text,
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
              TextFormField(
                controller: _identidadController,
                decoration: InputDecoration(
                  labelText: 'Número de Identidad (Reportado)',
                  prefixIcon: const Icon(Icons.badge),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                validator: (value) => value == null || value.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                initialValue: _categoriaSeleccionada,
                decoration: InputDecoration(
                  labelText: 'Categoría',
                  prefixIcon: const Icon(Icons.folder),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                items: _categorias.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) => setState(() => _categoriaSeleccionada = val!),
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
