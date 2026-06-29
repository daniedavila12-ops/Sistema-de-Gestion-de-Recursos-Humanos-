// CREADO POR: DANIEL INNOVA

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'contrato_provider.dart';

class NuevoContratoScreen extends ConsumerStatefulWidget {
  final int empleadoId;
  const NuevoContratoScreen({super.key, required this.empleadoId});

  @override
  ConsumerState<NuevoContratoScreen> createState() => _NuevoContratoScreenState();
}

class _NuevoContratoScreenState extends ConsumerState<NuevoContratoScreen> {
  final _formKey = GlobalKey<FormState>();

  final _puestoController = TextEditingController();
  final _notasController = TextEditingController();

  String? _tipoContrato;
  String? _estado;
  DateTime? _fechaInicio;
  DateTime? _fechaFin;
  DateTime? _fechaSalida;
  PlatformFile? _archivoContrato;

  bool _isLoading = false;

  @override
  void dispose() {
    _puestoController.dispose();
    _notasController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, Function(DateTime) onDateSelected) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        onDateSelected(picked);
      });
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'png'],
    );

    if (result != null) {
      setState(() {
        _archivoContrato = result.files.first;
      });
    }
  }

  void _guardarContrato() async {
    if (_formKey.currentState!.validate()) {
      if (_fechaInicio == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, seleccione la fecha de inicio.'), backgroundColor: Colors.red),
        );
        return;
      }

      setState(() => _isLoading = true);

      final contratoData = {
        'empleadoId': widget.empleadoId.toString(),
        'puesto': _puestoController.text,
        'tipo_contrato': _tipoContrato,
        'estado': _estado,
        'fecha_inicio': _fechaInicio!.toIso8601String(),
        'fecha_fin': _fechaFin?.toIso8601String(),
        'fecha_salida': _fechaSalida?.toIso8601String(),
        'notas': _notasController.text,
      };

      try {
        await ref.read(contratoRepositoryProvider).createContrato(contratoData, _archivoContrato);
        ref.invalidate(contratosProvider(widget.empleadoId));

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Contrato registrado con éxito'), backgroundColor: Colors.green),
          );
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al registrar el contrato: $e'), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.blue.shade700),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Nuevo Contrato')),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Detalles del Contrato', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.black87)),
              const Text('Define las condiciones laborales para el empleado.', style: TextStyle(color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 24),
              TextFormField(controller: _puestoController, decoration: _inputDecoration('Puesto de Trabajo', Icons.work_outline), validator: (v) => v!.isEmpty ? 'Campo requerido' : null),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      decoration: _inputDecoration('Tipo de Contrato', Icons.description_outlined),
                      items: ['Permanente', 'Temporal', 'Servicios Profesionales'].map((t) => DropdownMenuItem(value: t, child: Text(t, overflow: TextOverflow.ellipsis))).toList(),
                      onChanged: (v) => setState(() => _tipoContrato = v),
                      validator: (v) => v == null ? 'Seleccione un tipo' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      decoration: _inputDecoration('Estado', Icons.toggle_on_outlined),
                      items: ['Activo', 'Finalizado', 'Renovado'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                      onChanged: (v) => setState(() => _estado = v),
                      validator: (v) => v == null ? 'Seleccione un estado' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context, (date) => setState(() => _fechaInicio = date)),
                      child: InputDecorator(decoration: _inputDecoration('Fecha de Inicio', Icons.calendar_today_outlined), child: Text(_fechaInicio == null ? 'Seleccionar' : _formatDate(_fechaInicio!))),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context, (date) => setState(() => _fechaFin = date)),
                      child: InputDecorator(decoration: _inputDecoration('Fecha Fin (Opcional)', Icons.event_busy_outlined), child: Text(_fechaFin == null ? 'Seleccionar' : _formatDate(_fechaFin!))),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () => _selectDate(context, (date) => setState(() => _fechaSalida = date)),
                child: InputDecorator(decoration: _inputDecoration('Fecha Salida (Opcional)', Icons.logout_outlined), child: Text(_fechaSalida == null ? 'Seleccionar' : _formatDate(_fechaSalida!))),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _pickFile,
                child: InputDecorator(
                  decoration: _inputDecoration('Documento (Opcional)', Icons.attach_file_outlined),
                  child: Text(
                    _archivoContrato?.name ?? 'Seleccionar archivo',
                    style: TextStyle(color: _archivoContrato != null ? Colors.black87 : Colors.black54),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(controller: _notasController, decoration: _inputDecoration('Notas (Opcional)', Icons.notes_outlined).copyWith(alignLabelWithHint: true), maxLines: 4),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _guardarContrato,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade900, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('GUARDAR CONTRATO', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}