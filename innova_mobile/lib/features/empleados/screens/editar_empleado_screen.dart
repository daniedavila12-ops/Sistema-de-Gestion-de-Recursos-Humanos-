import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import '../../../core/api/api_client.dart';
import '../providers/departamentos_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:dio/dio.dart';

import '../models/empleado_model.dart';

class EditarEmpleadoScreen extends ConsumerStatefulWidget {
  final Empleado empleado;
  const EditarEmpleadoScreen({super.key, required this.empleado});

  @override
  ConsumerState<EditarEmpleadoScreen> createState() => _EditarEmpleadoScreenState();
}

class _EditarEmpleadoScreenState extends ConsumerState<EditarEmpleadoScreen> {
  final _formKey = GlobalKey<FormState>();

  // --- Validación en tiempo real ---
  Timer? _debounce;
  String? _codigoError;
  bool _isValidatingCodigo = false;

  Timer? _debounceIdentidad;
  String? _identidadError;
  bool _isValidatingIdentidad = false;

  // --- Información Personal ---
  final _codigoEmpleadoController = TextEditingController();
  final _identidadController = TextEditingController();
  final _nombresController = TextEditingController();
  final _apellidosController = TextEditingController();
  final _correoController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _direccionController = TextEditingController();
  String _genero = 'Masculino';
  DateTime? _fechaNacimiento;

  // --- Información Laboral ---
  final _ciudadController = TextEditingController();
  final _ubicacionController = TextEditingController();
  int? _departamentoId;
  String _tipoContrato = 'Permanente';
  DateTime? _fechaInicio;

  // --- Contacto de Emergencia 1 ---
  final _emergenciaNombreController = TextEditingController();
  final _emergenciaTelefonoController = TextEditingController();
  String? _emergenciaParentesco;

  // --- Contacto de Emergencia 2 (Opcional) ---
  final _emergenciaNombre2Controller = TextEditingController();
  final _emergenciaTelefono2Controller = TextEditingController();
  String? _emergenciaParentesco2;

  bool _isLoading = false;

  final List<String> _opcionesParentesco = ['Padre', 'Madre', 'Conyuge', 'Hermano(a)', 'Tio(a)', 'Otro (a)'];

  final _identidadMask = MaskTextInputFormatter(
    mask: '####-####-#####', 
    filter: { "#": RegExp(r'[0-9]') },
    type: MaskAutoCompletionType.lazy
  );

  final _telefonoMask = MaskTextInputFormatter(
    mask: '+504 ####-####', 
    filter: { "#": RegExp(r'[0-9]') },
    type: MaskAutoCompletionType.lazy
  );

  @override
  void initState() {
    super.initState();
    final emp = widget.empleado;
    _codigoEmpleadoController.text = emp.codigoEmpleado ?? '';
    // Safe initialization with mask formatters
    if (emp.identidad != null) {
      _identidadController.text = _identidadMask.maskText(emp.identidad!);
    }
    
    _nombresController.text = emp.nombre;
    _apellidosController.text = emp.apellido;
    _correoController.text = emp.correo ?? '';
    
    if (emp.telefono != null) {
      _telefonoController.text = _telefonoMask.maskText(emp.telefono!);
    }
    _direccionController.text = emp.direccion ?? '';
    _ciudadController.text = emp.ciudad ?? '';
    _ubicacionController.text = emp.ubicacion ?? '';
    _emergenciaNombreController.text = emp.emergenciaNombre ?? '';
    if (emp.emergenciaTelefono != null) {
      _emergenciaTelefonoController.text = _telefonoMask.maskText(emp.emergenciaTelefono!);
    }
    _emergenciaNombre2Controller.text = emp.emergenciaNombre2 ?? '';
    if (emp.emergenciaTelefono2 != null) {
      _emergenciaTelefono2Controller.text = _telefonoMask.maskText(emp.emergenciaTelefono2!);
    }
    
    if (emp.departamento != null) {
      _departamentoId = int.tryParse(emp.departamento!);
    }
    if (emp.tipoContrato != null && ['Permanente', 'Temporal', 'Servicios Profesionales'].contains(emp.tipoContrato)) {
      _tipoContrato = emp.tipoContrato!;
    }
    if (emp.emergenciaParentesco != null && _opcionesParentesco.contains(emp.emergenciaParentesco)) {
      _emergenciaParentesco = emp.emergenciaParentesco;
    }
    if (emp.emergenciaParentesco2 != null && emp.emergenciaParentesco2!.isNotEmpty && _opcionesParentesco.contains(emp.emergenciaParentesco2)) {
      _emergenciaParentesco2 = emp.emergenciaParentesco2;
    }
    if (emp.fechaNacimiento != null) {
      try {
        _fechaNacimiento = DateTime.parse(emp.fechaNacimiento!);
      } catch (_) {}
    }
    if (emp.fechaInicio != null) {
      _fechaInicio = emp.fechaInicio;
    }
  }

  @override
  void dispose() {
    _codigoEmpleadoController.dispose();
    _identidadController.dispose();
    _nombresController.dispose();
    _apellidosController.dispose();
    _correoController.dispose();
    _telefonoController.dispose();
    _direccionController.dispose();
    _ciudadController.dispose();
    _ubicacionController.dispose();
    _emergenciaNombreController.dispose();
    _emergenciaTelefonoController.dispose();
    _emergenciaNombre2Controller.dispose();
    _emergenciaTelefono2Controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onCodigoChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    if (value.trim().isEmpty) {
      setState(() { _codigoError = null; });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 600), () async {
      if (!mounted) return;
      setState(() { _isValidatingCodigo = true; });
      try {
        final response = await apiClient.get('/empleados/validar-codigo/${value.trim()}');
        if (!mounted) return;
        if (response.data['existe'] == true) {
          setState(() { _codigoError = 'Este código ya está en uso'; });
        } else {
          setState(() { _codigoError = null; });
        }
      } catch (e) {
        if (mounted) setState(() { _codigoError = null; });
      } finally {
        if (mounted) setState(() { _isValidatingCodigo = false; });
      }
    });
  }

  void _onIdentidadChanged(String value) {
    if (_debounceIdentidad?.isActive ?? false) _debounceIdentidad!.cancel();
    if (value.trim().isEmpty) {
      setState(() { _identidadError = null; });
      return;
    }
    _debounceIdentidad = Timer(const Duration(milliseconds: 600), () async {
      if (!mounted) return;
      setState(() { _isValidatingIdentidad = true; });
      try {
        final response = await apiClient.get('/empleados/validar-identidad/${value.trim()}');
        if (!mounted) return;
        if (response.data['existe'] == true) {
          setState(() { _identidadError = 'Este número de identidad ya está registrado'; });
        } else {
          setState(() { _identidadError = null; });
        }
      } catch (e) {
        if (mounted) setState(() { _identidadError = null; });
      } finally {
        if (mounted) setState(() { _isValidatingIdentidad = false; });
      }
    });
  }

  Future<void> _selectDate(BuildContext context, bool isNacimiento) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue.shade900,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isNacimiento) {
          _fechaNacimiento = picked;
        } else {
          _fechaInicio = picked;
        }
      });
    }
  }

  Future<void> _guardarEmpleado() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_fechaNacimiento == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('La fecha de nacimiento es requerida')));
      return;
    }
    if (_fechaInicio == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('La fecha de inicio es requerida')));
      return;
    }
    if (_departamentoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Seleccione un departamento')));
      return;
    }
    if (_emergenciaParentesco == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Seleccione parentesco para contacto de emergencia 1')));
      return;
    }
    if (_codigoError != null || _identidadError != null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor, corrija los errores en el formulario')));
      return;
    }

    setState(() => _isLoading = true);

    final data = {
      'codigo_empleado': _codigoEmpleadoController.text,
      'identidad': _identidadController.text,
      'nombre': _nombresController.text,
      'apellido': _apellidosController.text,
      'fecha_nacimiento': DateFormat('yyyy-MM-dd').format(_fechaNacimiento!),
      'genero': _genero,
      'correo': _correoController.text,
      'telefono': _telefonoController.text,
      'direccion': _direccionController.text,
      'tipo_contrato': _tipoContrato,
      'fecha_inicio': DateFormat('yyyy-MM-dd').format(_fechaInicio!),
      'ciudad': _ciudadController.text,
      'ubicacion': _ubicacionController.text,
      'departamento_id': _departamentoId,
      'emergencia_parentesco': _emergenciaParentesco,
      'emergencia_nombre': _emergenciaNombreController.text,
      'emergencia_telefono': _emergenciaTelefonoController.text,
      'emergencia_parentesco_2': _emergenciaParentesco2 ?? '',
      'emergencia_nombre_2': _emergenciaNombre2Controller.text,
      'emergencia_telefono_2': _emergenciaTelefono2Controller.text,
    };

    try {
      final response = await apiClient.put('/empleados/', data: data);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ ${response.data['mensaje'] ?? 'Empleado registrado'}'), backgroundColor: Colors.green),
        );
        context.go('/empleados');
      }
    } catch (e) {
      if (mounted) {
        final errorMsg = e is DioException && e.response?.data?['mensaje'] != null
            ? e.response!.data['mensaje']
            : 'Error al guardar empleado';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ $errorMsg'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  InputDecoration _inputDecoration(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon, color: Colors.blue.shade700) : null,
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
      contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
    );
  }

  Widget _buildSectionTitle(String title, {Color color = Colors.blue}) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: color, letterSpacing: 1.5),
          ),
          const Divider(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final departamentosAsync = ref.watch(departamentosProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Editar Empleado'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'EDITAR EMPLEADO',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.black87),
              ),
              const Text(
                'Complete la ficha de información del colaborador.',
                style: TextStyle(color: Colors.grey, fontSize: 14, fontStyle: FontStyle.italic),
              ),
              
              // --- SECCIÓN 1: INFORMACIÓN PERSONAL ---
              _buildSectionTitle('1. Información Personal', color: Colors.blue),
              TextFormField(
                controller: _codigoEmpleadoController,
                decoration: _inputDecoration('Código Empleado (Ej: EMP-001)').copyWith(
                  errorText: _codigoError,
                  suffixIcon: _isValidatingCodigo 
                    ? const SizedBox(width: 20, height: 20, child: Padding(padding: EdgeInsets.all(12.0), child: CircularProgressIndicator(strokeWidth: 2))) 
                    : null,
                ),
                onChanged: _onCodigoChanged,
                validator: (v) => v!.isEmpty ? 'Requerido' : (_codigoError != null ? 'Código inválido' : null),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _identidadController,
                decoration: _inputDecoration('Identidad (0000-0000-00000)').copyWith(
                  errorText: _identidadError,
                  suffixIcon: _isValidatingIdentidad 
                    ? const SizedBox(width: 20, height: 20, child: Padding(padding: EdgeInsets.all(12.0), child: CircularProgressIndicator(strokeWidth: 2))) 
                    : null,
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [_identidadMask],
                onChanged: _onIdentidadChanged,
                validator: (v) => v!.isEmpty ? 'Requerido' : (_identidadError != null ? 'Identidad inválida' : null),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _nombresController,
                      decoration: _inputDecoration('Nombres'),
                      validator: (v) => v!.isEmpty ? 'Requerido' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _apellidosController,
                      decoration: _inputDecoration('Apellidos'),
                      validator: (v) => v!.isEmpty ? 'Requerido' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context, true),
                      child: InputDecorator(
                        decoration: _inputDecoration('F. Nacimiento', icon: Icons.cake),
                        child: Text(
                          _fechaNacimiento == null ? 'Seleccionar' : DateFormat('dd/MM/yyyy').format(_fechaNacimiento!),
                          style: TextStyle(color: _fechaNacimiento == null ? Colors.black54 : Colors.black87),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: _genero,
                      decoration: _inputDecoration('Género'),
                      items: ['Masculino', 'Femenino'].map((g) => DropdownMenuItem(value: g, child: Text(g, overflow: TextOverflow.ellipsis))).toList(),
                      onChanged: (v) => setState(() => _genero = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _correoController,
                decoration: _inputDecoration('Correo Personal (Ej: empleado@correo.com)', icon: Icons.email),
                keyboardType: TextInputType.emailAddress,
                validator: (v) => v!.isEmpty || !v.contains('@') ? 'Correo inválido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _telefonoController,
                decoration: _inputDecoration('Teléfono (Ej: +504 0000-0000)', icon: Icons.phone),
                keyboardType: TextInputType.phone,
                inputFormatters: [_telefonoMask],
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _direccionController,
                decoration: _inputDecoration('Dirección Exacta', icon: Icons.location_on),
                maxLines: 2,
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),

              // --- SECCIÓN 2: INFORMACIÓN LABORAL ---
              _buildSectionTitle('2. Información Laboral', color: Colors.blue),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: _tipoContrato,
                      decoration: _inputDecoration('Tipo de Contrato'),
                      items: ['Permanente', 'Temporal', 'Servicios Profesionales'].map((t) => DropdownMenuItem(value: t, child: Text(t, overflow: TextOverflow.ellipsis))).toList(),
                      onChanged: (v) => setState(() => _tipoContrato = v!),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: departamentosAsync.when(
                      data: (deps) => DropdownButtonFormField<int>(
                        isExpanded: true,
                        initialValue: deps.any((d) => d.id == _departamentoId) ? _departamentoId : null,
                        decoration: _inputDecoration('Departamento'),
                        items: deps.map((d) => DropdownMenuItem(value: d.id, child: Text(d.nombre, overflow: TextOverflow.ellipsis))).toList(),
                        onChanged: (v) => setState(() => _departamentoId = v),
                      ),
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (err, _) => Text('Error: $err'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _ciudadController,
                      decoration: _inputDecoration('Ciudad'),
                      validator: (v) => v!.isEmpty ? 'Requerido' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context, false),
                      child: InputDecorator(
                        decoration: _inputDecoration('Fecha de Inicio', icon: Icons.calendar_today),
                        child: Text(
                          _fechaInicio == null ? 'Seleccionar' : DateFormat('dd/MM/yyyy').format(_fechaInicio!),
                          style: TextStyle(color: _fechaInicio == null ? Colors.black54 : Colors.black87),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ubicacionController,
                decoration: _inputDecoration('Ubicación / Piso'),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),

              // --- SECCIÓN 3: CONTACTO DE EMERGENCIA 1 ---
              _buildSectionTitle('3. Contacto de Emergencia 1', color: Colors.orange),
              DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: _emergenciaParentesco,
                decoration: _inputDecoration('Parentesco'),
                items: _opcionesParentesco.map((p) => DropdownMenuItem(value: p, child: Text(p, overflow: TextOverflow.ellipsis))).toList(),
                onChanged: (v) => setState(() => _emergenciaParentesco = v),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emergenciaNombreController,
                decoration: _inputDecoration('Nombre Completo'),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emergenciaTelefonoController,
                decoration: _inputDecoration('Teléfono Emergencia'),
                keyboardType: TextInputType.phone,
                inputFormatters: [_telefonoMask],
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),

              // --- SECCIÓN 4: CONTACTO DE EMERGENCIA 2 ---
              _buildSectionTitle('4. Contacto de Emergencia 2 (Opcional)', color: Colors.orange),
              DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: _emergenciaParentesco2,
                decoration: _inputDecoration('Parentesco'),
                items: _opcionesParentesco.map((p) => DropdownMenuItem(value: p, child: Text(p, overflow: TextOverflow.ellipsis))).toList(),
                onChanged: (v) => setState(() => _emergenciaParentesco2 = v),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emergenciaNombre2Controller,
                decoration: _inputDecoration('Nombre Completo'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emergenciaTelefono2Controller,
                decoration: _inputDecoration('Teléfono Emergencia'),
                keyboardType: TextInputType.phone,
                inputFormatters: [_telefonoMask],
              ),

              const SizedBox(height: 32),
              // --- BOTÓN GUARDAR ---
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _guardarEmpleado,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('GUARDAR Y CERRAR', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 2)),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}