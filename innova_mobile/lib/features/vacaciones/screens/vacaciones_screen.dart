import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VacacionesScreen extends ConsumerStatefulWidget {
  const VacacionesScreen({super.key});

  @override
  ConsumerState<VacacionesScreen> createState() => _VacacionesScreenState();
}

class _VacacionesScreenState extends ConsumerState<VacacionesScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores de texto
  final _periodoController = TextEditingController();
  final _diasSolicitadosController = TextEditingController();
  final _observacionesController = TextEditingController();

  // Variables de estado
  String? _empleadoSeleccionado;
  String? _tipoSolicitud;
  DateTime? _fechaInicio;
  DateTime? _fechaFinal;
  DateTime? _fechaRegreso;

  bool _isLoading = false;

  // Simulación de lista de empleados activos para el dropdown
  final List<Map<String, String>> _empleados = [
    {'id': '1', 'nombre': 'Gerad Cole (EMP-001)'},
    {'id': '2', 'nombre': 'Javier Paguada (EMP-030)'},
    {'id': '3', 'nombre': 'Dorian Garcias (EMP-377)'},
    {'id': '4', 'nombre': 'Carlos Flores (EMP-022)'},
  ];

  final List<String> _tiposSolicitud = [
    'Vacaciones Regulares',
    'Adelantadas',
    'Pagadas',
    'Permiso Especial',
    'Incapacidad Médica'
  ];

  @override
  void dispose() {
    _periodoController.dispose();
    _diasSolicitadosController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, String campo) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
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
        if (campo == 'inicio') _fechaInicio = picked;
        if (campo == 'final') _fechaFinal = picked;
        if (campo == 'regreso') _fechaRegreso = picked;
      });
    }
  }

  void _guardarVacaciones() {
    if (_formKey.currentState!.validate()) {
      if (_fechaInicio == null || _fechaFinal == null || _fechaRegreso == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor seleccione todas las fechas requeridas'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() => _isLoading = true);

      debugPrint('Registrando vacaciones...');
      debugPrint('Empleado: $_empleadoSeleccionado');
      debugPrint('Tipo: $_tipoSolicitud, Periodo: ${_periodoController.text}');
      debugPrint('Días: ${_diasSolicitadosController.text}');
      
      // Simulación de petición a la API
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Vacaciones registradas con éxito'),
              backgroundColor: Colors.green,
            ),
          );
          // Resetear formulario
          _formKey.currentState!.reset();
          setState(() {
            _empleadoSeleccionado = null;
            _tipoSolicitud = null;
            _fechaInicio = null;
            _fechaFinal = null;
            _fechaRegreso = null;
            _periodoController.clear();
            _diasSolicitadosController.clear();
            _observacionesController.clear();
          });
        }
      });
    }
  }

  // Estilos reutilizables
  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.blue.shade700),
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

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 16.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue.shade900, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Seleccionar';
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    return '$day/$month/$year';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Registrar Vacaciones',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.black87),
              ),
              const Text(
                'Gestione los días libres, permisos o vacaciones del personal.',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),

              // --- COLABORADOR ---
              _buildSectionTitle('Información del Colaborador', Icons.person),
              DropdownButtonFormField<String>(
                decoration: _inputDecoration('Seleccionar Empleado', Icons.badge),
                initialValue: _empleadoSeleccionado,
                items: _empleados.map((emp) => DropdownMenuItem(value: emp['id'], child: Text(emp['nombre']!))).toList(),
                onChanged: (v) => setState(() => _empleadoSeleccionado = v),
                validator: (v) => v == null ? 'Seleccione un empleado' : null,
              ),

              // --- DETALLES DE LA SOLICITUD ---
              _buildSectionTitle('Detalles de la Solicitud', Icons.assignment),
              DropdownButtonFormField<String>(
                decoration: _inputDecoration('Tipo de Solicitud', Icons.category),
                initialValue: _tipoSolicitud,
                items: _tiposSolicitud.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (v) => setState(() => _tipoSolicitud = v),
                validator: (v) => v == null ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _periodoController,
                      decoration: _inputDecoration('Periodo (Ej. 2024-2025)', Icons.date_range),
                      validator: (v) => v!.isEmpty ? 'Requerido' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      controller: _diasSolicitadosController,
                      decoration: _inputDecoration('Días', Icons.exposure_plus_1),
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? '*' : null,
                    ),
                  ),
                ],
              ),

              // --- FECHAS ---
              _buildSectionTitle('Fechas Programadas', Icons.calendar_month),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context, 'inicio'),
                      child: InputDecorator(
                        decoration: _inputDecoration('Fecha Inicio', Icons.flight_takeoff),
                        child: Text(_formatDate(_fechaInicio), style: TextStyle(color: _fechaInicio == null ? Colors.black54 : Colors.black87, fontSize: 13)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context, 'final'),
                      child: InputDecorator(
                        decoration: _inputDecoration('Fecha Final', Icons.flight_land),
                        child: Text(_formatDate(_fechaFinal), style: TextStyle(color: _fechaFinal == null ? Colors.black54 : Colors.black87, fontSize: 13)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () => _selectDate(context, 'regreso'),
                child: InputDecorator(
                  decoration: _inputDecoration('Fecha de Regreso (Laboral)', Icons.work_history),
                  child: Text(_formatDate(_fechaRegreso), style: TextStyle(color: _fechaRegreso == null ? Colors.black54 : Colors.black87)),
                ),
              ),

              // --- OBSERVACIONES ---
              _buildSectionTitle('Observaciones', Icons.notes),
              TextFormField(
                controller: _observacionesController,
                decoration: _inputDecoration('Detalles adicionales...', Icons.text_snippet).copyWith(alignLabelWithHint: true),
                maxLines: 4,
              ),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _guardarVacaciones,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade900,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('REGISTRAR VACACIONES', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
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