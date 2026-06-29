// CREADO POR: DANIEL INNOVA

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import '../models/documento_model.dart';
import '../providers/documento_provider.dart';
import '../widgets/gestion_categorias_dialog.dart';

class DocumentoFormScreen extends ConsumerStatefulWidget {
  final Documento? documentoToEdit;

  const DocumentoFormScreen({super.key, this.documentoToEdit});

  @override
  ConsumerState<DocumentoFormScreen> createState() => _DocumentoFormScreenState();
}

class _DocumentoFormScreenState extends ConsumerState<DocumentoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _tituloController;
  late TextEditingController _descripcionController;
  
  String? _selectedCategoria;
  
  final List<PlatformFile> _nuevosArchivos = [];
  List<ArchivoDocumento> _archivosExistentes = [];
  final List<int> _archivosEliminar = [];
  
  final List<TextEditingController> _linksControllers = [];
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tituloController = TextEditingController(text: widget.documentoToEdit?.titulo ?? '');
    _descripcionController = TextEditingController(text: widget.documentoToEdit?.descripcion ?? '');
    _selectedCategoria = widget.documentoToEdit?.categoria;
    
    if (widget.documentoToEdit != null) {
      _archivosExistentes = List.from(widget.documentoToEdit!.archivos);
      
      for (var link in widget.documentoToEdit!.links) {
        _linksControllers.add(TextEditingController(text: link.linkUrl));
      }
      if (widget.documentoToEdit!.linkLegacy != null && widget.documentoToEdit!.linkLegacy!.isNotEmpty) {
         _linksControllers.add(TextEditingController(text: widget.documentoToEdit!.linkLegacy));
      }
    }
    
    if (_linksControllers.isEmpty) {
      _linksControllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    for (var c in _linksControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickFiles() async {
    FilePickerResult? result = await FilePicker.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'png', 'jpg', 'jpeg'],
    );

    if (result != null) {
      setState(() {
        _nuevosArchivos.addAll(result.files);
      });
    }
  }

  void _removeNuevoArchivo(int index) {
    setState(() {
      _nuevosArchivos.removeAt(index);
    });
  }

  void _removeArchivoExistente(ArchivoDocumento archivo) {
    setState(() {
      _archivosEliminar.add(archivo.id);
      _archivosExistentes.remove(archivo);
    });
  }

  void _addLinkField() {
    setState(() {
      _linksControllers.add(TextEditingController());
    });
  }

  void _removeLinkField(int index) {
    setState(() {
      final controller = _linksControllers.removeAt(index);
      controller.dispose();
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    final validLinks = _linksControllers
        .map((c) => c.text.trim())
        .where((url) => url.isNotEmpty)
        .toList();

    if (_nuevosArchivos.isEmpty && _archivosExistentes.isEmpty && validLinks.isEmpty && 
        (widget.documentoToEdit?.archivoLegacy == null || widget.documentoToEdit!.archivoLegacy!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debe subir al menos un archivo o ingresar un link.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final formData = FormData.fromMap({
        'titulo': _tituloController.text.trim(),
        'descripcion': _descripcionController.text.trim(),
        'categoria': _selectedCategoria ?? 'General',
        'links': jsonEncode(validLinks),
        // Aquí podrías agregar 'creado_por': 1
      });

      if (widget.documentoToEdit != null) {
        formData.fields.add(MapEntry('archivosEliminar', jsonEncode(_archivosEliminar)));
      }

      for (var file in _nuevosArchivos) {
        if (file.path != null) {
          formData.files.add(MapEntry(
            'archivos',
            await MultipartFile.fromFile(file.path!, filename: file.name),
          ));
        }
      }

      final repo = ref.read(documentoRepositoryProvider);
      
      if (widget.documentoToEdit == null) {
        await repo.crearDocumento(formData);
      } else {
        await repo.actualizarDocumento(widget.documentoToEdit!.id, formData);
      }

      ref.invalidate(documentosProvider);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.documentoToEdit == null ? 'Documento creado' : 'Documento actualizado')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriasAsyncValue = ref.watch(categoriasLegalesProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.documentoToEdit == null ? 'NUEVO REGISTRO' : 'EDITAR REGISTRO', 
            style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const Text('Título *', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _tituloController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.blueGrey.shade50,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                    validator: (v) => v!.trim().isEmpty ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 20),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Categoría', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                      TextButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => const GestionCategoriasDialog(),
                          );
                        },
                        icon: const Icon(Icons.settings, size: 16, color: Colors.amber),
                        label: const Text('Gestionar', style: TextStyle(color: Colors.amber, fontSize: 12)),
                      ),
                    ],
                  ),
                  categoriasAsyncValue.when(
                    data: (categorias) {
                      if (categorias.isNotEmpty && _selectedCategoria == null && widget.documentoToEdit == null) {
                        _selectedCategoria = categorias.first.nombre;
                      }
                      return DropdownButtonFormField<String>(
                        initialValue: _selectedCategoria,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.blueGrey.shade50,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                        items: categorias.map((c) => DropdownMenuItem(value: c.nombre, child: Text(c.nombre))).toList()
                          ..add(const DropdownMenuItem(value: 'General', child: Text('General'))),
                        onChanged: (v) => setState(() => _selectedCategoria = v),
                      );
                    },
                    loading: () => const LinearProgressIndicator(),
                    error: (e, st) => const Text('Error al cargar categorías'),
                  ),
                  const SizedBox(height: 20),
                  
                  const Text('Descripción', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _descripcionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.blueGrey.shade50,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Archivos
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Archivos', style: TextStyle(fontWeight: FontWeight.bold)),
                            TextButton.icon(
                              onPressed: _pickFiles,
                              icon: const Icon(Icons.add),
                              label: const Text('Agregar'),
                            )
                          ],
                        ),
                        if (_archivosExistentes.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          const Text('Existentes:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ..._archivosExistentes.map((a) => ListTile(
                            title: Text('Archivo ${a.id}', style: const TextStyle(fontSize: 14)),
                            subtitle: Text(a.tamano, style: const TextStyle(fontSize: 12)),
                            trailing: IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () => _removeArchivoExistente(a),
                            ),
                          )),
                        ],
                        if (_nuevosArchivos.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          const Text('Nuevos:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ..._nuevosArchivos.asMap().entries.map((e) => ListTile(
                            title: Text(e.value.name, style: const TextStyle(fontSize: 14)),
                            trailing: IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () => _removeNuevoArchivo(e.key),
                            ),
                          )),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Links
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Links Web', style: TextStyle(fontWeight: FontWeight.bold)),
                            TextButton.icon(
                              onPressed: _addLinkField,
                              icon: const Icon(Icons.add),
                              label: const Text('Agregar'),
                            )
                          ],
                        ),
                        ..._linksControllers.asMap().entries.map((e) {
                          int idx = e.key;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: e.value,
                                    decoration: InputDecoration(
                                      hintText: 'https://ejemplo.com',
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                    ),
                                  ),
                                ),
                                if (_linksControllers.length > 1)
                                  IconButton(
                                    icon: const Icon(Icons.close, color: Colors.red),
                                    onPressed: () => _removeLinkField(idx),
                                  ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      widget.documentoToEdit == null ? 'GUARDAR' : 'ACTUALIZAR',
                      style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }
}
