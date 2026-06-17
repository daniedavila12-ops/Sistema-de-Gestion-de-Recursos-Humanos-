import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NuevoEmpleadoScreen extends ConsumerStatefulWidget {
  const NuevoEmpleadoScreen({super.key});

  @override
  ConsumerState<NuevoEmpleadoScreen> createState() => _NuevoEmpleadoScreenState();
}

class _NuevoEmpleadoScreenState extends ConsumerState<NuevoEmpleadoScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores de texto
  final _nombresController = TextEditingController();
  final _apellidosController = TextEditingController();
  final _identidadController = TextEditingController();
  final _correoController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _direccionController = TextEditingController();
  final _puestoController = TextEditingController();
  final _salarioController = TextEditingController();

  // Variables para Dropdowns y Fechas
  String? _genero;
  String? _estadoCivil;
  String? _departamento;
  String? _tipoContrato;
  DateTime? _fechaNacimiento;
  DateTime? _fechaIngreso;

  bool _isLoading = false;

  @override
  void dispose() {
    _nombresController.dispose();
    _apellidosController.dispose();
    _identidadController.dispose();
    _correoController.dispose();
    _telefonoController.dispose();
    _direccionController.dispose();
    _puestoController.dispose();
    _salarioController.dispose();
    super.dispose();
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
          _fechaIngreso = picked;
        }
      });
    }
  }

  void _guardarEmpleado() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      // Simulación de los datos a enviar usando todas las variables del formulario
      debugPrint('Guardando empleado...');
      debugPrint('Género: $_genero, Estado Civil: $_estadoCivil');
      debugPrint('Departamento: $_departamento, Contrato: $_tipoContrato');
      debugPrint('Nacimiento: $_fechaNacimiento, Ingreso: $_fechaIngreso');

      // Simular petición a la API
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Empleado registrado con éxito'),
              backgroundColor: Colors.green,
            ),
          );
          // Aquí podrías agregar context.pop() para regresar o limpiar los campos
        }
      });
    }
  }

  // Widget Auxiliar para decorar los inputs
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
      contentPadding: const EdgeInsets.symmetric(vertical: 16.0),
    );
  }

  // Widget Auxiliar para los Títulos de las Secciones
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 16.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    );
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
                'Registrar Nuevo Empleado',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.black87),
              ),
              const Text(
                'Complete la información del colaborador para agregarlo al sistema.',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              
              // --- SECCIÓN: INFORMACIÓN PERSONAL ---
              _buildSectionTitle('Información Personal'),
              TextFormField(
                controller: _nombresController,
                decoration: _inputDecoration('Nombres', Icons.person),
                validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _apellidosController,
                decoration: _inputDecoration('Apellidos', Icons.person_outline),
                validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _identidadController,
                decoration: _inputDecoration('Número de Identidad', Icons.badge),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: _inputDecoration('Género', Icons.people),
                      items: ['Masculino', 'Femenino', 'Otro'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                      onChanged: (v) => setState(() => _genero = v),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: _inputDecoration('Estado Civil', Icons.favorite),
                      items: ['Soltero', 'Casado', 'Divorciado', 'Viudo'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (v) => setState(() => _estadoCivil = v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () => _selectDate(context, true),
                child: InputDecorator(
                  decoration: _inputDecoration('Fecha de Nacimiento', Icons.cake),
                  child: Text(_fechaNacimiento == null ? 'Seleccionar fecha' : '${_fechaNacimiento!.day}/${_fechaNacimiento!.month}/${_fechaNacimiento!.year}', style: TextStyle(color: _fechaNacimiento == null ? Colors.black54 : Colors.black87)),
                ),
              ),

              // --- SECCIÓN: INFORMACIÓN DE CONTACTO ---
              _buildSectionTitle('Información de Contacto'),
              TextFormField(
                controller: _correoController,
                decoration: _inputDecoration('Correo Electrónico', Icons.email),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _telefonoController,
                decoration: _inputDecoration('Teléfono', Icons.phone),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _direccionController,
                decoration: _inputDecoration('Dirección Exacta', Icons.location_on),
                maxLines: 3,
              ),

              // --- SECCIÓN: INFORMACIÓN LABORAL ---
              _buildSectionTitle('Información Laboral'),
              DropdownButtonFormField<String>(
                decoration: _inputDecoration('Departamento', Icons.business),
                items: ['Dirección', 'Recursos Humanos', 'Ventas', 'Soporte TI', 'Producción'].map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                onChanged: (v) => setState(() => _departamento = v),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _puestoController,
                decoration: _inputDecoration('Puesto de Trabajo', Icons.work),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: _inputDecoration('Tipo de Contrato', Icons.description),
                items: ['Permanente', 'Temporal', 'Por Proyecto'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (v) => setState(() => _tipoContrato = v),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _salarioController,
                      decoration: _inputDecoration('Salario Base', Icons.attach_money),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context, false),
                      child: InputDecorator(
                        decoration: _inputDecoration('Fecha Ingreso', Icons.calendar_today),
                        child: Text(_fechaIngreso == null ? 'Seleccionar' : '${_fechaIngreso!.day}/${_fechaIngreso!.month}/${_fechaIngreso!.year}', style: TextStyle(color: _fechaIngreso == null ? Colors.black54 : Colors.black87)),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              // --- BOTÓN GUARDAR ---
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _guardarEmpleado,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade900,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('REGISTRAR EMPLEADO', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
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