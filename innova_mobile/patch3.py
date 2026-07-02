import os
import re

file_path = r'c:\Users\danie\Documents\INNOVA\Proyecto\innova_mobile\lib\features\empleados\screens\empleado_detail_screen.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Locate the monolithic _showVacacionDialog
idx_start = content.find('void _showVacacionDialog')
idx_end = content.find('void _confirmarEliminarVacacion')

if idx_start == -1 or idx_end == -1:
    print('Failed to find boundaries')
    exit(1)

new_show = '''void _showVacacionDialog(BuildContext context, WidgetRef ref, Empleado empleado, {VacacionEmpleado? vacacionToEdit}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _VacacionBottomSheet(
          empleado: empleado,
          vacacionToEdit: vacacionToEdit,
        );
      },
    );
  }

'''

sheet_code = """class _VacacionBottomSheet extends ConsumerStatefulWidget {
  final Empleado empleado;
  final VacacionEmpleado? vacacionToEdit;

  const _VacacionBottomSheet({
    Key? key,
    required this.empleado,
    this.vacacionToEdit,
  }) : super(key: key);

  @override
  ConsumerState<_VacacionBottomSheet> createState() => _VacacionBottomSheetState();
}

class _VacacionBottomSheetState extends ConsumerState<_VacacionBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController tipoPermisoController;
  late TextEditingController diasVacacionesController;
  late TextEditingController diasPagadosController;
  late TextEditingController diasPendientesController;
  late TextEditingController fechaInicioController;
  late TextEditingController fechaFinalController;
  late TextEditingController fechaRegresoController;
  late TextEditingController observacionesController;
  
  late TextEditingController fechaSolicitudController;
  late TextEditingController diasCorrespondientesController;
  late TextEditingController autorizadoPorController;

  String? selectedTipoSolicitud;
  String? selectedPeriodo;
  PlatformFile? selectedDocument;
  bool isSaving = false;

  final List<String> tiposSolicitud = ['Normal', 'Adelantadas', 'Pagadas', 'Permiso Especial'];
  List<String> periodosDisponibles = [];

  @override
  void initState() {
    super.initState();
    final v = widget.vacacionToEdit;
    
    selectedTipoSolicitud = v?.tipoSolicitud ?? 'Normal';
    if (!tiposSolicitud.contains(selectedTipoSolicitud)) {
      tiposSolicitud.add(selectedTipoSolicitud!);
    }
    
    selectedPeriodo = v?.periodo;

    tipoPermisoController = TextEditingController(text: v?.tipoPermiso ?? '');
    diasVacacionesController = TextEditingController(text: v?.diasVacaciones.toString() ?? '0');
    diasPagadosController = TextEditingController(text: v?.diasPagados.toString() ?? '0');
    diasPendientesController = TextEditingController(text: v?.diasPendientes.toString() ?? '0');
    
    fechaInicioController = TextEditingController(text: v?.fechaInicio != null ? v!.fechaInicio!.split('T')[0] : '');
    fechaFinalController = TextEditingController(text: v?.fechaFinal != null ? v!.fechaFinal!.split('T')[0] : '');
    fechaRegresoController = TextEditingController(text: v?.fechaRegreso != null ? v!.fechaRegreso!.split('T')[0] : '');
    observacionesController = TextEditingController(text: v?.observaciones ?? '');

    fechaSolicitudController = TextEditingController(text: v?.fechaSolicitud != null ? v!.fechaSolicitud!.split('T')[0] : "\\${DateTime.now().year}-\\${DateTime.now().month.toString().padLeft(2, '0')}-\\${DateTime.now().day.toString().padLeft(2, '0')}");
    diasCorrespondientesController = TextEditingController(text: v?.diasCorrespondientes.toString() ?? '0');
    autorizadoPorController = TextEditingController(text: v?.autorizadoPor ?? '');
  }

  @override
  void dispose() {
    tipoPermisoController.dispose();
    diasVacacionesController.dispose();
    diasPagadosController.dispose();
    diasPendientesController.dispose();
    fechaInicioController.dispose();
    fechaFinalController.dispose();
    fechaRegresoController.dispose();
    observacionesController.dispose();
    fechaSolicitudController.dispose();
    diasCorrespondientesController.dispose();
    autorizadoPorController.dispose();
    super.dispose();
  }

  void _calcularPeriodosDisponibles() {
    final vacacionesAsync = ref.read(vacacionesEmpleadoProvider(widget.empleado.id));
    final vacacionesEmpleado = vacacionesAsync.value ?? [];
    
    String inicioStr = widget.empleado.fechaInicio?.split('T')[0] ?? '';
    if (inicioStr.isEmpty) return;
    
    DateTime inicio = DateTime.tryParse(inicioStr) ?? DateTime.now();
    int anioInicio = inicio.year;
    int anioActual = DateTime.now().year;
    List<String> periodos = [];
    
    DateTime hoy = DateTime.now();
    int aniosLaboradosReales = hoy.year - inicio.year;
    if (hoy.month < inicio.month || (hoy.month == inicio.month && hoy.day < inicio.day)) {
      aniosLaboradosReales--;
    }
    
    if (selectedTipoSolicitud == 'Adelantadas') {
      int periodoAnioInicio = anioInicio + (aniosLaboradosReales > 0 ? aniosLaboradosReales : 0);
      String periodoAdelantado = "\\${periodoAnioInicio}-\\${periodoAnioInicio + 1}";
      bool isRegistrado = vacacionesEmpleado.any((v) => v.periodo == periodoAdelantado && (widget.vacacionToEdit == null || v.id != widget.vacacionToEdit!.id));
      if (!isRegistrado) periodos.add(periodoAdelantado);
    } else if (selectedTipoSolicitud == 'Normal' || selectedTipoSolicitud == 'Pagadas') {
      for (int i = 0; i < aniosLaboradosReales; i++) {
        int periodoAnioInicio = anioInicio + i;
        String periodo = "\\${periodoAnioInicio}-\\${periodoAnioInicio + 1}";
        bool isRegistrado = vacacionesEmpleado.any((v) => v.periodo == periodo && (widget.vacacionToEdit == null || v.id != widget.vacacionToEdit!.id));
        if (!isRegistrado) periodos.add(periodo);
      }
    } else if (selectedTipoSolicitud == 'Permiso Especial') {
      for (int i = anioInicio; i <= anioActual; i++) {
        periodos.add("\\${i}-\\${i + 1}");
      }
    } else {
      for (int i = anioInicio; i <= anioActual; i++) {
        String periodo = "\\${i}-\\${i + 1}";
        bool isRegistrado = vacacionesEmpleado.any((v) => v.periodo == periodo && (widget.vacacionToEdit == null || v.id != widget.vacacionToEdit!.id));
        if (!isRegistrado) periodos.add(periodo);
      }
    }
    
    setState(() {
      periodosDisponibles = periodos.reversed.toList();
      if (selectedPeriodo != null && !periodosDisponibles.contains(selectedPeriodo)) {
        periodosDisponibles.insert(0, selectedPeriodo!);
      } else if (periodosDisponibles.isNotEmpty && selectedPeriodo == null) {
        selectedPeriodo = periodosDisponibles.first;
      }
    });
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue.shade800,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      controller.text = "\\${picked.year}-\\${picked.month.toString().padLeft(2, '0')}-\\${picked.day.toString().padLeft(2, '0')}";
    }
  }

  Future<void> _pickDocument() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
    );
    if (result != null) {
      setState(() {
        selectedDocument = result.files.first;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSaving = true);
    final repository = ref.read(vacacionRepositoryProvider);
    
    try {
      final data = {
        'empleado_id': widget.empleado.id.toString(),
        'periodo': selectedPeriodo ?? '',
        'tipoSolicitud': selectedTipoSolicitud,
        'tipoPermiso': selectedTipoSolicitud == 'Permiso Especial' ? tipoPermisoController.text : null,
        'diasCorrespondientes': diasCorrespondientesController.text,
        'diasVacaciones': diasVacacionesController.text,
        'diasPagados': diasPagadosController.text,
        'diasPendientes': diasPendientesController.text,
        'fechaSolicitud': fechaSolicitudController.text.isNotEmpty ? fechaSolicitudController.text : null,
        'fechaInicio': fechaInicioController.text.isNotEmpty ? fechaInicioController.text : null,
        'fechaFinal': fechaFinalController.text.isNotEmpty ? fechaFinalController.text : null,
        'fechaRegreso': fechaRegresoController.text.isNotEmpty ? fechaRegresoController.text : null,
        'observaciones': observacionesController.text,
        'autorizadoPor': autorizadoPorController.text,
      };

      if (widget.vacacionToEdit == null) {
        await repository.registrarVacacion(data, selectedDocument);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vacaciones registradas con éxito', style: TextStyle(color: Colors.white)), backgroundColor: Colors.green));
      } else {
        await repository.actualizarVacacion(widget.vacacionToEdit!.id, data, selectedDocument);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vacaciones actualizadas con éxito', style: TextStyle(color: Colors.white)), backgroundColor: Colors.green));
      }
      
      ref.invalidate(vacacionesEmpleadoProvider(widget.empleado.id));
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString(), style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  Widget _buildTextField(String label, TextEditingController controller, {IconData? icon, bool readOnly = false, VoidCallback? onTap, TextInputType? keyboardType, bool isRequired = false, bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        enabled: enabled,
        onTap: onTap,
        keyboardType: keyboardType,
        validator: isRequired ? (value) => value == null || value.isEmpty ? 'Requerido' : null : null,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.blueGrey.shade500, fontSize: 13, fontWeight: FontWeight.w600),
          filled: true,
          fillColor: enabled ? Colors.blueGrey.shade50 : Colors.blueGrey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blueGrey.shade200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blueGrey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue.shade500, width: 2),
          ),
          suffixIcon: icon != null ? IconButton(icon: Icon(icon, color: Colors.blue.shade500), onPressed: onTap) : null,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _calcularPeriodosDisponibles();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              color: Colors.blue.shade800,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.vacacionToEdit == null ? 'REGISTRAR VACACIONES' : 'EDITAR VACACIÓN',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1.2
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Gestión de vacaciones para el empleado',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade100,
                        fontStyle: FontStyle.italic
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          // Body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('DATOS DE VACACIONES'),
                    
                    Row(
                      children: [
                        Expanded(child: _buildTextField('Fecha Solicitud', fechaSolicitudController, icon: Icons.calendar_today, readOnly: true, onTap: () => _selectDate(fechaSolicitudController), isRequired: true)),
                      ],
                    ),
                    
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: DropdownButtonFormField<String>(
                              value: selectedTipoSolicitud,
                              items: tiposSolicitud.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                              onChanged: (v) {
                                setState(() {
                                  selectedTipoSolicitud = v;
                                  selectedPeriodo = null;
                                  _calcularPeriodosDisponibles();
                                });
                              },
                              decoration: InputDecoration(
                                labelText: 'Tipo Solicitud',
                                labelStyle: TextStyle(color: Colors.blueGrey.shade500, fontSize: 13, fontWeight: FontWeight.w600),
                                filled: true,
                                fillColor: Colors.blueGrey.shade50,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: DropdownButtonFormField<String>(
                              value: selectedPeriodo,
                              items: periodosDisponibles.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                              onChanged: (v) => setState(() => selectedPeriodo = v),
                              decoration: InputDecoration(
                                labelText: 'Periodo',
                                labelStyle: TextStyle(color: Colors.blueGrey.shade500, fontSize: 13, fontWeight: FontWeight.w600),
                                filled: true,
                                fillColor: Colors.blueGrey.shade50,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                              ),
                              validator: (val) => val == null || val.isEmpty ? 'Requerido' : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    if (selectedTipoSolicitud == 'Permiso Especial')
                      _buildTextField('Tipo de Permiso (Ej. Maternidad)', tipoPermisoController),
                    
                    _buildSectionTitle('CÁLCULO DE DÍAS'),
                    if (selectedTipoSolicitud != 'Permiso Especial') ...[
                      Row(
                        children: [
                          Expanded(child: _buildTextField('Correspondientes', diasCorrespondientesController, keyboardType: TextInputType.number, enabled: selectedTipoSolicitud != 'Pagadas' && selectedTipoSolicitud != 'Adelantadas')),
                          const SizedBox(width: 12),
                          if (selectedTipoSolicitud != 'Pagadas')
                            Expanded(child: _buildTextField('Vac/Disfrutados', diasVacacionesController, keyboardType: TextInputType.number))
                          else
                            const Spacer(),
                        ],
                      ),
                      Row(
                        children: [
                          if (selectedTipoSolicitud == 'Pagadas')
                            Expanded(child: _buildTextField('Pagados', diasPagadosController, keyboardType: TextInputType.number))
                          else
                            const Spacer(),
                          const SizedBox(width: 12),
                          Expanded(child: _buildTextField('Pendientes', diasPendientesController, keyboardType: TextInputType.number, enabled: !(selectedTipoSolicitud == 'Normal' || selectedTipoSolicitud == 'Pagadas' || selectedTipoSolicitud == 'Adelantadas'))),
                        ],
                      ),
                    ] else ...[
                      Row(
                        children: [
                          Expanded(child: _buildTextField('Días a Tomar', diasVacacionesController, keyboardType: TextInputType.number)),
                        ],
                      ),
                    ],

                    _buildSectionTitle('FECHAS DE AUSENCIA'),
                    if (selectedTipoSolicitud != 'Pagadas') ...[
                      Row(
                        children: [
                          Expanded(child: _buildTextField('Inicio', fechaInicioController, icon: Icons.calendar_today, readOnly: true, onTap: () => _selectDate(fechaInicioController))),
                          const SizedBox(width: 12),
                          Expanded(child: _buildTextField('Final', fechaFinalController, icon: Icons.calendar_today, readOnly: true, onTap: () => _selectDate(fechaFinalController))),
                        ]
                      ),
                      _buildTextField('Fecha Regreso', fechaRegresoController, icon: Icons.calendar_today, readOnly: true, onTap: () => _selectDate(fechaRegresoController)),
                    ],

                    _buildSectionTitle('AUTORIZACIÓN Y OBSERVACIONES'),
                    _buildTextField('Autorizado Por', autorizadoPorController, isRequired: true),
                    _buildTextField('Observaciones', observacionesController),
                    
                    // Documento
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blueGrey.shade200, style: BorderStyle.solid),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Documento Adjunto (Opcional)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.blueGrey)),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              ElevatedButton.icon(
                                onPressed: _pickDocument,
                                icon: const Icon(Icons.upload_file, size: 18),
                                label: const Text('Seleccionar'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.blue.shade600,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Colors.blue.shade200)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  selectedDocument?.name ?? (widget.vacacionToEdit?.documento != null ? 'Documento actual guardado' : 'Ningún archivo seleccionado'),
                                  style: TextStyle(fontSize: 12, color: Colors.blueGrey.shade500, fontStyle: FontStyle.italic),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Footer
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.blueGrey.shade100)),
              boxShadow: [
                BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 10, offset: const Offset(0, -5))
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      side: BorderSide(color: Colors.blueGrey.shade300),
                    ),
                    child: Text('Cancelar', style: TextStyle(color: Colors.blueGrey.shade600, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isSaving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade800,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: isSaving
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text(widget.vacacionToEdit == null ? 'Guardar' : 'Actualizar', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0, top: 8.0),
      child: Text(
        title, 
        style: TextStyle(
          fontSize: 11, 
          fontWeight: FontWeight.w900, 
          color: Colors.blue.shade800, 
          letterSpacing: 1.5
        )
      ),
    );
  }
}

"""

content = content[:idx_start] + new_show + sheet_code + '\n' + content[idx_end:]

# Replace calls inside _buildVacacionesTab (which are remaining in content)
content = content.replace('_showVacacionDialog(context, ref, empleadoId, vacacionToEdit: vacacion)', '_showVacacionDialog(context, ref, _empleado, vacacionToEdit: vacacion)')
content = content.replace('_showVacacionDialog(context, ref, _empleado.id, vacacionToEdit: vacacion)', '_showVacacionDialog(context, ref, _empleado, vacacionToEdit: vacacion)')
content = content.replace('_showVacacionDialog(context, ref, empleadoId)', '_showVacacionDialog(context, ref, _empleado)')
content = content.replace('_showVacacionDialog(context, ref, _empleado.id)', '_showVacacionDialog(context, ref, _empleado)')
content = content.replace('_showVacacionDialog(context, ref, widget.empleado.id)', '_showVacacionDialog(context, ref, widget.empleado)')

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)

print('Patched successfully!')
