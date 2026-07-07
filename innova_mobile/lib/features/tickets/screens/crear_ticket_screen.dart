// CREADO POR: DANIEL INNOVA

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/ticket_provider.dart';

class IdentidadInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (newText.length > 13) {
      newText = newText.substring(0, 13);
    }
    
    String formatted = '';
    for (int i = 0; i < newText.length; i++) {
      if (i == 4 || i == 8) {
        formatted += '-';
      }
      formatted += newText[i];
    }
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class CrearTicketScreen extends ConsumerStatefulWidget {
  const CrearTicketScreen({super.key});

  @override
  ConsumerState<CrearTicketScreen> createState() => _CrearTicketScreenState();
}

class _CrearTicketScreenState extends ConsumerState<CrearTicketScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final List<TextEditingController> _identidadesControllers = [TextEditingController()];
  String _tipo = 'Vacaciones';
  String _prioridad = 'Media';
  String _tema = '';
  String _descripcion = '';
  PlatformFile? _archivo;
  
  bool _isLoading = false;

  @override
  void dispose() {
    for (var controller in _identidadesControllers) {
      controller.dispose();
    }
    super.dispose();
  }
  
  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.pickFiles();
    if (result != null) {
      setState(() {
        _archivo = result.files.first;
      });
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    
    final String identidadesStr = _identidadesControllers.map((c) => c.text.trim()).where((text) => text.isNotEmpty).join(',');
    
    setState(() => _isLoading = true);
    
    try {
      final repository = ref.read(ticketRepositoryProvider);
      
      // Nota: El backend soporta envío JSON por ahora en el Repositorio Móvil.
      // Si se necesita enviar archivo, el repositorio debe actualizarse a FormData.
      final success = await repository.createTicket(
        identidad: identidadesStr,
        tipo: _tipo,
        prioridad: _prioridad,
        tema: _tema,
        descripcion: _descripcion,
      );
      
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Ticket enviado con éxito', style: TextStyle(color: Colors.white)), backgroundColor: Colors.green));
          context.pop();
        }
      } else {
        throw Exception('Error al enviar la solicitud');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ Error: $e', style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.grey),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Nueva Solicitud'),
        elevation: 0,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ...List.generate(_identidadesControllers.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _identidadesControllers[index],
                              keyboardType: TextInputType.number,
                              inputFormatters: [IdentidadInputFormatter()],
                              decoration: _inputDecoration(
                                index == 0 ? 'Número de Identidad' : 'Número de Identidad ${index + 1}',
                                Icons.badge_outlined,
                              ).copyWith(hintText: 'Ej: 0801-1990-12345'),
                              validator: (v) => v == null || v.isEmpty ? 'Requerido' : (v.length < 15 ? 'Identidad incompleta' : null),
                            ),
                          ),
                          if (index > 0)
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _identidadesControllers[index].dispose();
                                  _identidadesControllers.removeAt(index);
                                });
                              },
                            ),
                        ],
                      ),
                    );
                  }),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _identidadesControllers.add(TextEditingController());
                        });
                      },
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('+ Agregar otra persona'),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          decoration: _inputDecoration('Tipo de Solicitud', Icons.category_outlined),
                          initialValue: _tipo,
                          items: ['Vacaciones', 'Soporte IT', 'Recursos Humanos', 'Mantenimiento']
                            .map((t) => DropdownMenuItem(value: t, child: Text(t, overflow: TextOverflow.ellipsis))).toList(),
                          onChanged: (v) => setState(() => _tipo = v!),
                          onSaved: (v) => _tipo = v!,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          decoration: _inputDecoration('Prioridad', Icons.flag_outlined),
                          initialValue: _prioridad,
                          items: ['Baja', 'Media', 'Alta', 'Urgente']
                            .map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                          onChanged: (v) => setState(() => _prioridad = v!),
                          onSaved: (v) => _prioridad = v!,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    decoration: _inputDecoration('Tema / Asunto', Icons.subject).copyWith(hintText: 'Breve resumen'),
                    validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                    onSaved: (v) => _tema = v!,
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    decoration: _inputDecoration('Descripción', Icons.description_outlined).copyWith(hintText: 'Detalla tu solicitud aquí...'),
                    maxLines: 4,
                    validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                    onSaved: (v) => _descripcion = v!,
                  ),
                  const SizedBox(height: 16),

                  InkWell(
                    onTap: _pickFile,
                    child: InputDecorator(
                      decoration: _inputDecoration('Subir Archivo (Opcional)', Icons.attach_file_outlined),
                      child: Text(
                        _archivo?.name ?? 'Seleccionar archivo',
                        style: TextStyle(color: _archivo != null ? Colors.black87 : Colors.black54),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                    ),
                    onPressed: _submit,
                    child: const Text('ENVIAR SOLICITUD', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.2)),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
