// CREADO POR: DANIEL INNOVA

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../models/manual_model.dart';
import '../providers/gestion_manuales_provider.dart';

class ManualFormDialog extends ConsumerStatefulWidget {
  final Manual? manualToEdit;

  const ManualFormDialog({super.key, this.manualToEdit});

  @override
  ConsumerState<ManualFormDialog> createState() => _ManualFormDialogState();
}

class _ManualFormDialogState extends ConsumerState<ManualFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _tituloCtrl;
  late TextEditingController _categoriaCtrl;
  late TextEditingController _descripcionCtrl;
  
  File? _selectedFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tituloCtrl = TextEditingController(text: widget.manualToEdit?.titulo ?? '');
    _categoriaCtrl = TextEditingController(text: widget.manualToEdit?.categoria ?? '');
    _descripcionCtrl = TextEditingController(text: widget.manualToEdit?.descripcion ?? '');
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _categoriaCtrl.dispose();
    _descripcionCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (widget.manualToEdit == null && _selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes seleccionar un archivo PDF')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(gestionManualesProvider.notifier).subirManual(
        titulo: _tituloCtrl.text.trim(),
        categoria: _categoriaCtrl.text.trim(),
        descripcion: _descripcionCtrl.text.trim(),
        archivoPdf: _selectedFile,
        editandoId: widget.manualToEdit?.id,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.manualToEdit == null ? 'Manual subido correctamente' : 'Manual actualizado correctamente')),
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
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.manualToEdit == null ? 'SUBIR NUEVO MANUAL' : 'EDITAR MANUAL',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 24),

                TextFormField(
                  controller: _tituloCtrl,
                  decoration: InputDecoration(
                    labelText: 'Título',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _categoriaCtrl,
                  decoration: InputDecoration(
                    labelText: 'Categoría',
                    hintText: 'Ej: Legal, Sistemas, RRHH',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _descripcionCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Descripción',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 24),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200, style: BorderStyle.solid),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.picture_as_pdf, color: Colors.blue, size: 40),
                      const SizedBox(height: 8),
                      Text(
                        _selectedFile != null ? _selectedFile!.path.split('/').last.split('\\').last : 'Ningún archivo seleccionado',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: _pickFile,
                        icon: const Icon(Icons.upload_file),
                        label: const Text('Seleccionar PDF'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                      if (widget.manualToEdit != null)
                        const Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Text('Opcional: Sube un archivo solo si deseas reemplazar el actual.', style: TextStyle(fontSize: 10, color: Colors.grey), textAlign: TextAlign.center),
                        )
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('CANCELAR', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F172A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: _isLoading 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text(widget.manualToEdit == null ? 'GUARDAR' : 'ACTUALIZAR', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
