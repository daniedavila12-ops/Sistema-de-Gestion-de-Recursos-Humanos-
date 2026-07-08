import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import '../../../core/api/api_client.dart';
import 'package:innova_mobile/core/constants/api_constants.dart';
import '../../auth/providers/auth_provider.dart';

class VacacionesScreen extends ConsumerStatefulWidget {
  const VacacionesScreen({super.key});

  @override
  ConsumerState<VacacionesScreen> createState() => _VacacionesScreenState();
}

class _VacacionesScreenState extends ConsumerState<VacacionesScreen> {
  List<dynamic> _listaEmpleados = [];
  List<dynamic> _empleadosFiltrados = [];
  dynamic _empleadoSeleccionado;
  
  List<dynamic> _vacacionesEmpleado = [];
  List<dynamic> _tiposPermisoDisponibles = [];
  
  final _searchController = TextEditingController();
  final _diasCorrespondientesController = TextEditingController();
  final _diasVacacionesController = TextEditingController();
  final _diasPagadosController = TextEditingController();
  final _diasPendientesController = TextEditingController();
  final _observacionesController = TextEditingController();
  final _autorizadoPorController = TextEditingController();
  final _nuevoTipoPermisoController = TextEditingController();

  bool _isLoading = false;
  bool _isEditing = false;
  int? _vacacionEditId;
  
  String _tipoSolicitud = '';
  String _tipoPermiso = '';
  String _periodo = '';
  DateTime? _fechaSolicitud = DateTime.now();
  DateTime? _fechaInicio;
  DateTime? _fechaFinal;
  DateTime? _fechaRegreso;
  
  bool _isContinuandoAdelantadas = false;
  bool _isContinuandoNormal = false;
  PlatformFile? _fileDocumento;
  
  @override
  void initState() {
    super.initState();
    _cargarTiposPermiso();
    _cargarEmpleados();
    _searchController.addListener(_filtrarEmpleados);

    _diasVacacionesController.addListener(_onDiasVacacionesChanged);
    _diasPagadosController.addListener(_onDiasPagadosChanged);
    _diasCorrespondientesController.addListener(_calcularDiasPendientes);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _diasCorrespondientesController.dispose();
    _diasVacacionesController.dispose();
    _diasPagadosController.dispose();
    _diasPendientesController.dispose();
    _observacionesController.dispose();
    _autorizadoPorController.dispose();
    _nuevoTipoPermisoController.dispose();
    super.dispose();
  }

  Future<void> _cargarTiposPermiso() async {
    try {
      final res = await apiClient.get('/vacaciones/tipos-permiso');
      if (mounted) {
        setState(() {
          _tiposPermisoDisponibles = res.data;
        });
      }
    } catch (e) {
      debugPrint('Error cargando tipos permiso: $e');
    }
  }

  Future<void> _cargarEmpleados() async {
    try {
      final res = await apiClient.get('/empleados/lista');
      if (mounted) {
        setState(() {
          _listaEmpleados = res.data;
          _empleadosFiltrados = _listaEmpleados.where((e) => e['estado'] == 'Activo' || e['estado'] == 1 || e['estado'] == true).toList();
        });
      }
    } catch (e) {
      debugPrint('Error cargando empleados: $e');
    }
  }

  void _filtrarEmpleados() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _empleadosFiltrados = _listaEmpleados.where((e) {
        if (!(e['estado'] == 'Activo' || e['estado'] == 1 || e['estado'] == true)) return false;
        if (query.isEmpty) return true;
        final nombre = '${e['nombre']} ${e['apellido']}'.toLowerCase();
        final id = e['identidad']?.toString().toLowerCase() ?? '';
        final cod = e['codigo_empleado']?.toString().toLowerCase() ?? '';
        return nombre.contains(query) || id.contains(query) || cod.contains(query);
      }).toList();
    });
  }

  Future<void> _seleccionarEmpleado(dynamic emp) async {
    setState(() {
      _empleadoSeleccionado = emp;
      _searchController.clear();
      _cancelarEdicion();
    });

    try {
      final resContratos = await apiClient.get('/empleados/${emp['id']}/contratos');
      final contratos = resContratos.data as List;
      if (contratos.isNotEmpty) {
        contratos.sort((a, b) => DateTime.parse(a['fechaInicio']).compareTo(DateTime.parse(b['fechaInicio'])));
        final firstContrato = contratos.first;
        if (firstContrato['fechaInicio'] != null) {
          setState(() {
            _empleadoSeleccionado['fecha_inicio'] = firstContrato['fechaInicio'];
          });
        }
      }
    } catch (e) {
      debugPrint("Error cargando contratos: $e");
    }

    if (!_isEditing) {
      _diasCorrespondientesController.text = _diasCorrespondientesCalculados().toString();
      _calcularDiasPendientes();
    }

    await _cargarVacacionesEmpleado(emp['id']);
  }

  Future<void> _cargarVacacionesEmpleado(int id) async {
    try {
      final res = await apiClient.get('/vacaciones/empleado/$id');
      List records = res.data;
      
      String? empFechaInicio = _empleadoSeleccionado['fecha_inicio'];
      Map<String, double> periodosMap = {};
      
      records.sort((a, b) => a['id'].compareTo(b['id']));
      
      for (var v in records) {
        if (!periodosMap.containsKey(v['periodo'])) {
          double base = 0;
          if (empFechaInicio != null && v['periodo'] != null && v['periodo'].toString().contains('-')) {
            String inicioStr = empFechaInicio.contains('T') ? empFechaInicio.split('T')[0] : empFechaInicio;
            int anioInicioEmp = DateTime.parse('$inicioStr 00:00:00').year;
            int anioPeriodo = int.parse(v['periodo'].split('-')[0]);
            int anios = anioPeriodo - anioInicioEmp + 1;
            if (anios >= 4) {
              base = 20;
            } else if (anios == 3) {
              base = 15;
            } else if (anios == 2) {
              base = 12;
            } else if (anios == 1) {
              base = 10;
            }
          }
          if (base == 0 || v['tipoSolicitud'] == 'Permiso Especial') {
            base = double.tryParse(v['diasCorrespondientes'].toString()) ?? 0;
          }
          periodosMap[v['periodo']] = base;
          v['diasCorrespondientes'] = base;
        } else {
          v['diasCorrespondientes'] = periodosMap[v['periodo']];
        }
        
        double aRestar = 0;
        if (v['tipoSolicitud'] == 'Pagadas') {
          aRestar = (double.tryParse(v['diasVacaciones'].toString()) ?? 0) + (double.tryParse(v['diasPagados'].toString()) ?? 0);
        } else if (v['tipoSolicitud'] != 'Permiso Especial') {
          aRestar = double.tryParse(v['diasVacaciones'].toString()) ?? 0;
        }
        
        v['diasPendientes'] = (v['diasCorrespondientes'] ?? 0) - aRestar;
        periodosMap[v['periodo']] = v['diasPendientes'];
      }
      
      if (mounted) {
        setState(() {
          _vacacionesEmpleado = records.reversed.toList(); // Mostrar más recientes primero
        });
      }
    } catch (e) {
      debugPrint('Error al cargar historial: $e');
    }
  }

  void _limpiarSeleccion() {
    setState(() {
      _empleadoSeleccionado = null;
      _searchController.clear();
      _cancelarEdicion();
      _vacacionesEmpleado = [];
    });
  }

  int _aniosLaboradosCalculados() {
    if (_empleadoSeleccionado == null || _empleadoSeleccionado['fecha_inicio'] == null) return 0;
    String inicioStr = _empleadoSeleccionado['fecha_inicio'];
    if (inicioStr.contains('T')) inicioStr = inicioStr.split('T')[0];
    DateTime inicio = DateTime.parse('$inicioStr 00:00:00');
    
    if (_periodo.isNotEmpty) {
      try {
        int anioFin = int.parse(_periodo.split('-')[1]);
        return (anioFin - inicio.year) > 0 ? (anioFin - inicio.year) : 0;
      } catch (_) {}
    }
    
    DateTime hoy = DateTime.now();
    int anios = hoy.year - inicio.year;
    if (hoy.month < inicio.month || (hoy.month == inicio.month && hoy.day < inicio.day)) {
      anios--;
    }
    return anios > 0 ? anios : 0;
  }

  double _diasCorrespondientesCalculados() {
    int anios = _aniosLaboradosCalculados();
    if (anios >= 4) return 20;
    if (anios == 3) return 15;
    if (anios == 2) return 12;
    if (anios == 1) return 10;
    return 0;
  }

  double _diasPendientesAcumuladosTotales() {
    if (_empleadoSeleccionado == null || _empleadoSeleccionado['fecha_inicio'] == null) return 0;
    String inicioStr = _empleadoSeleccionado['fecha_inicio'];
    if (inicioStr.contains('T')) inicioStr = inicioStr.split('T')[0];
    DateTime inicio = DateTime.parse('$inicioStr 00:00:00');
    int anioInicio = inicio.year;
    
    DateTime hoy = DateTime.now();
    int aniosLaboradosReales = hoy.year - inicio.year;
    if (hoy.month < inicio.month || (hoy.month == inicio.month && hoy.day < inicio.day)) {
      aniosLaboradosReales--;
    }
    
    double totalCorrespondientesAcumulados = 0;
    Set<String> periodosProcesados = {};
    
    for (int i = 0; i < aniosLaboradosReales; i++) {
       int periodoAnioInicio = anioInicio + i;
       String periodoStr = '$periodoAnioInicio-${periodoAnioInicio + 1}';
       periodosProcesados.add(periodoStr);
       
       var vacacionesPeriodo = _vacacionesEmpleado.where((v) => v['periodo'] == periodoStr).toList();
       if (vacacionesPeriodo.isNotEmpty) {
           var vacacionOriginal = [...vacacionesPeriodo];
           vacacionOriginal.sort((a, b) => a['id'].compareTo(b['id']));
           totalCorrespondientesAcumulados += double.tryParse(vacacionOriginal.first['diasCorrespondientes'].toString()) ?? 0;
       } else {
           int anios = i + 1;
           if (anios >= 4) {
             totalCorrespondientesAcumulados += 20;
           } else if (anios == 3) {
             totalCorrespondientesAcumulados += 15;
           } else if (anios == 2) {
             totalCorrespondientesAcumulados += 12;
           } else if (anios == 1) {
             totalCorrespondientesAcumulados += 10;
           }
       }
    }

    for (var vacacion in _vacacionesEmpleado) {
        if (vacacion['periodo'] != null && !periodosProcesados.contains(vacacion['periodo'])) {
            periodosProcesados.add(vacacion['periodo']);
        }
    }

    double totalDiasTomadosYPagados = 0;
    for (var vacacion in _vacacionesEmpleado) {
      if (_isEditing && vacacion['id'] == _vacacionEditId) continue;
      
      double aRestar = 0;
      if (vacacion['tipoSolicitud'] == 'Pagadas') {
        aRestar = (double.tryParse(vacacion['diasVacaciones'].toString()) ?? 0) + (double.tryParse(vacacion['diasPagados'].toString()) ?? 0);
      } else if (vacacion['tipoSolicitud'] != 'Permiso Especial') {
        aRestar = double.tryParse(vacacion['diasVacaciones'].toString()) ?? 0;
      }
      totalDiasTomadosYPagados += aRestar; 
    }

    double resultado = totalCorrespondientesAcumulados - totalDiasTomadosYPagados;
    return resultado < 0 ? 0 : resultado;
  }

  bool _isAdelantadasDisponible() {
    if (_empleadoSeleccionado == null || _empleadoSeleccionado['fecha_inicio'] == null) return false;
    String inicioStr = _empleadoSeleccionado['fecha_inicio'];
    if (inicioStr.contains('T')) inicioStr = inicioStr.split('T')[0];
    DateTime inicio = DateTime.parse('$inicioStr 00:00:00');
    int anioInicio = inicio.year;
    
    DateTime hoy = DateTime.now();
    int aniosLaboradosReales = hoy.year - inicio.year;
    if (hoy.month < inicio.month || (hoy.month == inicio.month && hoy.day < inicio.day)) {
      aniosLaboradosReales--;
    }
    
    int periodoAnioInicio = anioInicio + (aniosLaboradosReales > 0 ? aniosLaboradosReales : 0);
    String periodoAdelantado = '$periodoAnioInicio-${periodoAnioInicio + 1}';
    
    bool isRegistrado = _vacacionesEmpleado.any((v) => v['periodo'] == periodoAdelantado && (!_isEditing || v['id'] != _vacacionEditId));
    return !isRegistrado;
  }

  List<String> _periodosDisponibles() {
    if (_empleadoSeleccionado == null || _empleadoSeleccionado['fecha_inicio'] == null) return [];
    if (_isContinuandoNormal || _isContinuandoAdelantadas) return [];
    String inicioStr = _empleadoSeleccionado['fecha_inicio'];
    if (inicioStr.contains('T')) inicioStr = inicioStr.split('T')[0];
    DateTime inicio = DateTime.parse('$inicioStr 00:00:00');
    int anioInicio = inicio.year;
    int anioActual = DateTime.now().year;
    List<String> periodos = [];
    
    if (_tipoSolicitud == 'Adelantadas') {
      DateTime hoy = DateTime.now();
      int aniosLaboradosReales = hoy.year - inicio.year;
      if (hoy.month < inicio.month || (hoy.month == inicio.month && hoy.day < inicio.day)) {
        aniosLaboradosReales--;
      }
      int periodoAnioInicio = anioInicio + (aniosLaboradosReales > 0 ? aniosLaboradosReales : 0);
      String periodoAdelantado = '$periodoAnioInicio-${periodoAnioInicio + 1}';
      bool isRegistrado = _vacacionesEmpleado.any((v) => v['periodo'] == periodoAdelantado && (!_isEditing || v['id'] != _vacacionEditId));
      if (!isRegistrado) periodos.add(periodoAdelantado);
    } else if (_tipoSolicitud == 'Normal' || _tipoSolicitud == 'Pagadas') {
      DateTime hoy = DateTime.now();
      int aniosLaboradosReales = hoy.year - inicio.year;
      if (hoy.month < inicio.month || (hoy.month == inicio.month && hoy.day < inicio.day)) {
        aniosLaboradosReales--;
      }
      for (int i = 0; i < aniosLaboradosReales; i++) {
        int periodoAnioInicio = anioInicio + i;
        String periodo = '$periodoAnioInicio-${periodoAnioInicio + 1}';
        bool isRegistrado = _vacacionesEmpleado.any((v) => v['periodo'] == periodo && (!_isEditing || v['id'] != _vacacionEditId));
        if (!isRegistrado) periodos.add(periodo);
      }
    } else if (_tipoSolicitud == 'Permiso Especial') {
      for (int i = anioInicio; i <= anioActual; i++) {
        periodos.add('$i-${i + 1}');
      }
    } else {
      for (int i = anioInicio; i <= anioActual; i++) {
        String periodo = '$i-${i + 1}';
        bool isRegistrado = _vacacionesEmpleado.any((v) => v['periodo'] == periodo && (!_isEditing || v['id'] != _vacacionEditId));
        if (!isRegistrado) periodos.add(periodo);
      }
    }
    
    return periodos.reversed.toList();
  }

  void _calcularDiasPendientes() {
    double correspondientes = double.tryParse(_diasCorrespondientesController.text) ?? 0;
    double tomados = double.tryParse(_diasVacacionesController.text) ?? 0;
    double pagados = double.tryParse(_diasPagadosController.text) ?? 0;
    
    double pendientes;
    if (_tipoSolicitud == 'Pagadas') {
      pendientes = correspondientes - pagados - tomados;
      if (pendientes < 0) {
        pendientes = _diasPendientesAcumuladosTotales() - pagados - tomados;
      }
    } else {
      pendientes = correspondientes - tomados;
      if (pendientes < 0) {
        pendientes = _diasPendientesAcumuladosTotales() - tomados;
      }
    }
    
    _diasPendientesController.text = pendientes.toString();
  }

  void _onDiasVacacionesChanged() {
    double val = double.tryParse(_diasVacacionesController.text) ?? 0;
    if (val < 0) {
      _diasVacacionesController.text = '0';
      return;
    }
    double correspondientes = double.tryParse(_diasCorrespondientesController.text) ?? 0;

    if (_tipoSolicitud == 'Permiso Especial') {
      if (val > 4) {
        _diasVacacionesController.text = '4';
      }
      _diasPagadosController.text = '0';
    } else if (_tipoSolicitud == 'Normal' || _tipoSolicitud == 'Adelantadas') {
      if (val > correspondientes) {
        _diasVacacionesController.text = correspondientes.toString();
      }
      _diasPagadosController.text = '0';
    } else {
      _diasPagadosController.text = _diasVacacionesController.text;
    }
    _calcularFechas();
    _calcularDiasPendientes();
  }

  void _onDiasPagadosChanged() {
    double val = double.tryParse(_diasPagadosController.text) ?? 0;
    if (val < 0) {
      _diasPagadosController.text = '0';
      return;
    }
    if (_tipoSolicitud == 'Pagadas') {
      double correspondientes = double.tryParse(_diasCorrespondientesController.text) ?? 0;
      if (val > correspondientes) {
        _diasPagadosController.text = correspondientes.toString();
      }
    }
    _calcularDiasPendientes();
  }

  void _calcularFechas() {
    if (_fechaInicio != null) {
      double dias = double.tryParse(_diasVacacionesController.text) ?? 0;
      if (dias > 0) {
        DateTime fechaActual = DateTime(_fechaInicio!.year, _fechaInicio!.month, _fechaInicio!.day);
        int diasContados = 0;
        
        if (fechaActual.weekday == DateTime.sunday) {
          fechaActual = fechaActual.add(const Duration(days: 1));
        }
        
        while (diasContados < dias.ceil()) { // Aproximación simple para días fraccionados
          if (fechaActual.weekday != DateTime.sunday) {
            diasContados++;
          }
          if (diasContados < dias.ceil()) {
            fechaActual = fechaActual.add(const Duration(days: 1));
          }
        }
        
        setState(() {
          _fechaFinal = fechaActual;
        });

        DateTime fRegreso = fechaActual.add(const Duration(days: 1));
        while (fRegreso.weekday == DateTime.sunday) {
          fRegreso = fRegreso.add(const Duration(days: 1));
        }
        setState(() {
          _fechaRegreso = fRegreso;
        });
      } else {
         setState(() {
          _fechaFinal = null;
          _fechaRegreso = null;
        });
      }
    }
  }

  Future<void> _selectDate(BuildContext context, String campo) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: campo == 'inicio' && _fechaInicio != null ? _fechaInicio! : DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        if (campo == 'solicitud') _fechaSolicitud = picked;
        if (campo == 'inicio') {
          _fechaInicio = picked;
          _calcularFechas();
        }
        if (campo == 'final') _fechaFinal = picked;
        if (campo == 'regreso') _fechaRegreso = picked;
      });
    }
  }

  Future<void> _pickDocument() async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
    );

    if (result != null) {
      setState(() {
        _fileDocumento = result.files.first;
      });
    }
  }

  void _cancelarEdicion() {
    setState(() {
      _isEditing = false;
      _vacacionEditId = null;
      _isContinuandoAdelantadas = false;
      _isContinuandoNormal = false;
      
      _tipoSolicitud = '';
      _tipoPermiso = '';
      _nuevoTipoPermisoController.clear();
      _periodo = '';
      _diasCorrespondientesController.text = '0';
      _diasVacacionesController.text = '0';
      _diasPagadosController.text = '0';
      _diasPendientesController.text = '0';
      _fechaSolicitud = DateTime.now();
      _fechaInicio = null;
      _fechaFinal = null;
      _fechaRegreso = null;
      _observacionesController.clear();
      _autorizadoPorController.clear();
      _fileDocumento = null;
    });
    if (_empleadoSeleccionado != null) {
      _diasCorrespondientesController.text = _diasCorrespondientesCalculados().toString();
      _calcularDiasPendientes();
    }
  }

  void _editarVacacion(dynamic v) {
    setState(() {
      _isEditing = true;
      _vacacionEditId = v['id'];
      _tipoSolicitud = v['tipoSolicitud'] ?? '';
      _tipoPermiso = v['tipoPermiso'] ?? '';
      _periodo = v['periodo'] ?? '';
      _diasCorrespondientesController.text = v['diasCorrespondientes']?.toString() ?? '0';
      _diasVacacionesController.text = v['diasVacaciones']?.toString() ?? '0';
      _diasPagadosController.text = v['diasPagados']?.toString() ?? '0';
      _diasPendientesController.text = v['diasPendientes']?.toString() ?? '0';
      _fechaSolicitud = v['fechaSolicitud'] != null ? DateTime.parse(v['fechaSolicitud']) : null;
      _fechaInicio = v['fechaInicio'] != null ? DateTime.parse(v['fechaInicio']) : null;
      _fechaFinal = v['fechaFinal'] != null ? DateTime.parse(v['fechaFinal']) : null;
      _fechaRegreso = v['fechaRegreso'] != null ? DateTime.parse(v['fechaRegreso']) : null;
      _observacionesController.text = v['observaciones'] ?? '';
      _autorizadoPorController.text = v['autorizadoPor'] ?? '';
      _fileDocumento = null;
    });
  }

  bool _esUltimoRegistroPeriodo(dynamic v) {
    if (_vacacionesEmpleado.isEmpty) return false;
    var delPeriodo = _vacacionesEmpleado.where((vac) => vac['periodo'] == v['periodo']).toList();
    if (delPeriodo.isEmpty) return false;
    int maxId = delPeriodo.map<int>((e) => e['id'] as int).reduce((a, b) => a > b ? a : b);
    return v['id'] == maxId;
  }

  void _continuarVacaciones(dynamic v) {
    _cancelarEdicion();
    setState(() {
      _periodo = v['periodo'] ?? '';
      if (v['tipoSolicitud'] == 'Adelantadas') {
        _tipoSolicitud = 'Adelantadas';
        _isContinuandoAdelantadas = true;
        _isContinuandoNormal = false;
      } else if (v['tipoSolicitud'] == 'Normal' || v['tipoSolicitud'] == 'Pagadas') {
        _tipoSolicitud = v['tipoSolicitud'];
        _isContinuandoAdelantadas = false;
        _isContinuandoNormal = true;
      } else {
        _tipoSolicitud = 'Normal';
        _isContinuandoAdelantadas = false;
        _isContinuandoNormal = false;
      }
      
      _diasCorrespondientesController.text = v['diasPendientes']?.toString() ?? '0';
    });
    _calcularDiasPendientes();
  }

  Future<void> _eliminarVacacion(int id) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar'),
        content: const Text('¿Está seguro de eliminar este registro?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Eliminar', style: TextStyle(color: Colors.red))),
        ],
      )
    );
    if (confirm != true) return;
    
    try {
      await apiClient.delete('/vacaciones/$id');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registro eliminado')));
      if (_empleadoSeleccionado != null) {
        await _cargarVacacionesEmpleado(_empleadoSeleccionado['id']);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al eliminar: $e')));
    }
  }

  Future<void> _guardarVacaciones() async {
    if (_empleadoSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Seleccione un empleado')));
      return;
    }

    if (_tipoSolicitud == 'Pagadas') {
      double dPagados = double.tryParse(_diasPagadosController.text) ?? 0;
      double dCorresp = double.tryParse(_diasCorrespondientesController.text) ?? 0;
      if (dPagados < 0) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Días pagados no pueden ser negativos')));
        return;
      }
      if (dPagados > dCorresp) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Días pagados no pueden ser mayores a correspondientes')));
        return;
      }
    } else {
      double dPendientes = double.tryParse(_diasPendientesController.text) ?? 0;
      if (dPendientes < 0 && _tipoSolicitud != 'Permiso Especial') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No cuenta con días pendientes suficientes')));
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id') ?? '1';

      FormData formData = FormData.fromMap({
        'empleado_id': _empleadoSeleccionado['id'],
        'fechaIngreso': _empleadoSeleccionado['fecha_inicio'] ?? '',
        'aniosLaborados': _aniosLaboradosCalculados(),
        'diasCorrespondientesEmpleado': _diasCorrespondientesCalculados(),
        'fechaSolicitud': _fechaSolicitud?.toIso8601String().split('T')[0] ?? '',
        'tipoSolicitud': _tipoSolicitud,
        'tipoPermiso': _tipoPermiso == 'Otro' ? _nuevoTipoPermisoController.text : _tipoPermiso,
        'periodo': _periodo,
        'diasCorrespondientes': _diasCorrespondientesController.text,
        'diasVacaciones': _diasVacacionesController.text,
        'diasPagados': _diasPagadosController.text,
        'diasPendientes': _diasPendientesController.text,
        'fechaInicio': _fechaInicio?.toIso8601String().split('T')[0] ?? '',
        'fechaFinal': _fechaFinal?.toIso8601String().split('T')[0] ?? '',
        'fechaRegreso': _fechaRegreso?.toIso8601String().split('T')[0] ?? '',
        'observaciones': _observacionesController.text,
        'autorizadoPor': _autorizadoPorController.text,
        'usuario_id': userId,
      });

      if (_fileDocumento != null && _fileDocumento!.path != null) {
        formData.files.add(MapEntry(
          'documento',
          await MultipartFile.fromFile(_fileDocumento!.path!, filename: _fileDocumento!.name)
        ));
      }

      if (_isEditing) {
        await apiClient.put('/vacaciones/$_vacacionEditId', data: formData);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vacaciones actualizadas')));
      } else {
        await apiClient.post('/vacaciones/registrar', data: formData);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vacaciones registradas')));
      }

      await _cargarTiposPermiso();
      await _cargarVacacionesEmpleado(_empleadoSeleccionado['id']);
      _cancelarEdicion();

    } on DioException catch (e) {
      String msg = e.response?.data?['error'] ?? e.message;
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $msg')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Seleccionar';
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final puedeCrear = authState.hasPermission('Vacaciones', 'puedeCrear');
    final puedeEditar = authState.hasPermission('Vacaciones', 'puedeEditar');
    final puedeEliminar = authState.hasPermission('Vacaciones', 'puedeEliminar');

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Registrar Vacaciones', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.blue[900],
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          TextButton.icon(
            onPressed: () {
              context.push('/reportes-vacaciones');
            },
            icon: const Text('📄', style: TextStyle(fontSize: 14)),
            label: const Text('REPORTES VACACIONES', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_empleadoSeleccionado == null) ...[
              const Text('SELECCIONAR EMPLEADO', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, letterSpacing: 1.2)),
              const SizedBox(height: 8),
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Buscar por nombre o identidad...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),
              if (_empleadosFiltrados.isNotEmpty)
                Container(
                  constraints: const BoxConstraints(maxHeight: 400),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!)
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _empleadosFiltrados.length,
                    separatorBuilder: (c, i) => Divider(height: 1, color: Colors.grey[200]),
                    itemBuilder: (c, i) {
                      var emp = _empleadosFiltrados[i];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue[100],
                          child: Text(emp['nombre'][0], style: const TextStyle(color: Colors.blue)),
                        ),
                        title: Text('${emp['nombre']} ${emp['apellido']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${emp['identidad']} | Cód: ${emp['codigo_empleado'] ?? 'N/A'}'),
                        onTap: () => _seleccionarEmpleado(emp),
                      );
                    },
                  ),
                ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  border: Border.all(color: Colors.blue[200]!),
                  borderRadius: BorderRadius.circular(12)
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.white,
                      child: Text(_empleadoSeleccionado['nombre'][0], style: TextStyle(color: Colors.blue[400], fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${_empleadoSeleccionado['nombre']} ${_empleadoSeleccionado['apellido']}', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue[900], fontSize: 16)),
                          Text('${_empleadoSeleccionado['identidad']} | ${_empleadoSeleccionado['codigo_empleado'] ?? ''}', style: TextStyle(color: Colors.blue[700], fontSize: 12)),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: _limpiarSeleccion,
                      child: const Text('Cambiar'),
                    )
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              const Text('DATOS DE EMPLEADO', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 12, letterSpacing: 1.5)),
              const Divider(),
              Container(
                padding: const EdgeInsets.all(12),
                width: double.infinity,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!)),
                child: Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _buildInfoItem('Fecha Ingreso', _empleadoSeleccionado['fecha_inicio'] != null ? _empleadoSeleccionado['fecha_inicio'].split('T')[0] : 'N/A'),
                    _buildInfoItem('Años de laborar', _aniosLaboradosCalculados().toString()),
                    _buildInfoItem('Días Corresp.', _diasCorrespondientesCalculados().toString()),
                    _buildInfoItem('Días Pendientes (Acum)', _diasPendientesAcumuladosTotales().toString(), isHighlight: true),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              if (puedeCrear || _isEditing) ...[
                const Text('DATOS DE VACACIONES', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 12, letterSpacing: 1.5)),
                const Divider(),
              
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDatePicker('Fecha Solicitud', _fechaSolicitud, () => _selectDate(context, 'solicitud')),
                    const SizedBox(height: 12),
                    
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Tipo Solicitud', border: OutlineInputBorder()),
                      initialValue: _tipoSolicitud.isEmpty ? null : _tipoSolicitud,
                      items: () {
                        List<String> options = [];
                        if (_isContinuandoAdelantadas) {
                          options = ['Adelantadas', 'Normal', 'Pagadas'];
                        } else if (_isContinuandoNormal) {
                          options = ['Normal', 'Pagadas'];
                        } else {
                          options = ['Normal'];
                          if (_isAdelantadasDisponible()) options.add('Adelantadas');
                          options.addAll(['Pagadas', 'Permiso Especial']);
                        }
                        return options.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList();
                      }(),
                      onChanged: (v) {
                        setState(() {
                          _tipoSolicitud = v ?? '';
                          if (!_isContinuandoAdelantadas && !_isContinuandoNormal) _periodo = '';
                          if (_tipoSolicitud == 'Permiso Especial') {
                            _diasPagadosController.text = '0';
                            if ((double.tryParse(_diasVacacionesController.text)??0) > 4) _diasVacacionesController.text = '4';
                          } else if (_tipoSolicitud == 'Normal' || _tipoSolicitud == 'Adelantadas') {
                            _diasPagadosController.text = '0';
                          } else {
                            _diasPagadosController.text = _diasVacacionesController.text;
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Periodo', border: OutlineInputBorder()),
                      initialValue: _periodo.isEmpty ? null : _periodo,
                      items: () {
                        List<String> options = _periodosDisponibles();
                        if (_periodo.isNotEmpty && (_isEditing || _isContinuandoNormal || _isContinuandoAdelantadas) && !options.contains(_periodo)) {
                           options.insert(0, _periodo);
                        }
                        return options.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList();
                      }(),
                      onChanged: (v) {
                        setState(() {
                          _periodo = v ?? '';
                          if (!_isEditing) {
                            _diasCorrespondientesController.text = _diasCorrespondientesCalculados().toString();
                            _calcularDiasPendientes();
                          }
                        });
                      },
                    ),
                    
                    if (_periodo.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      if (_tipoSolicitud == 'Permiso Especial') ...[
                         DropdownButtonFormField<String>(
                            decoration: const InputDecoration(labelText: 'Tipo de Permiso', border: OutlineInputBorder()),
                            initialValue: _tipoPermiso.isEmpty ? null : _tipoPermiso,
                            items: _tiposPermisoDisponibles.map<DropdownMenuItem<String>>((e) => DropdownMenuItem(value: e['nombre'], child: Text(e['nombre']))).toList()..add(const DropdownMenuItem(value: 'Otro', child: Text('Otro'))),
                            onChanged: (v) => setState(() => _tipoPermiso = v ?? ''),
                         ),
                         if (_tipoPermiso == 'Otro') ...[
                           const SizedBox(height: 8),
                           TextField(controller: _nuevoTipoPermisoController, decoration: const InputDecoration(labelText: 'Especifique permiso', border: OutlineInputBorder())),
                         ]
                      ],
                      const SizedBox(height: 12),
                      
                      Row(
                        children: [
                          if (_tipoSolicitud != 'Normal' && _tipoSolicitud != 'Permiso Especial')
                            Expanded(child: TextField(controller: _diasCorrespondientesController, decoration: const InputDecoration(labelText: 'Días Corresp.', border: OutlineInputBorder()), readOnly: _tipoSolicitud == 'Pagadas' || _tipoSolicitud == 'Adelantadas', keyboardType: TextInputType.number)),
                          if (_tipoSolicitud != 'Normal' && _tipoSolicitud != 'Permiso Especial') const SizedBox(width: 8),
                          
                          if (_tipoSolicitud != 'Pagadas')
                            Expanded(child: TextField(controller: _diasVacacionesController, decoration: InputDecoration(labelText: _tipoSolicitud == 'Permiso Especial' ? 'Días Tomar' : 'Días Vac.', border: const OutlineInputBorder()), keyboardType: TextInputType.number)),
                          if (_tipoSolicitud != 'Pagadas') const SizedBox(width: 8),
                          
                          if (_tipoSolicitud == 'Pagadas')
                            Expanded(child: TextField(controller: _diasPagadosController, decoration: const InputDecoration(labelText: 'Días Pagados', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      if (_tipoSolicitud != 'Permiso Especial')
                         TextField(controller: _diasPendientesController, decoration: const InputDecoration(labelText: 'Días Pendientes', border: OutlineInputBorder(), filled: true, fillColor: Colors.black12), readOnly: true),
                      
                      const SizedBox(height: 12),
                      if (_tipoSolicitud != 'Pagadas') ...[
                         Row(
                           children: [
                             Expanded(child: _buildDatePicker('Inicio', _fechaInicio, () => _selectDate(context, 'inicio'))),
                             const SizedBox(width: 8),
                             Expanded(child: _buildDatePicker('Final', _fechaFinal, () => _selectDate(context, 'final'))),
                           ],
                         ),
                         const SizedBox(height: 12),
                         _buildDatePicker('Regreso', _fechaRegreso, () => _selectDate(context, 'regreso')),
                         const SizedBox(height: 12),
                      ],
                      
                      TextField(controller: _autorizadoPorController, decoration: const InputDecoration(labelText: 'Autorizado Por', border: OutlineInputBorder())),
                      const SizedBox(height: 12),
                      TextField(controller: _observacionesController, maxLines: 3, decoration: const InputDecoration(labelText: 'Observaciones', border: OutlineInputBorder())),
                      const SizedBox(height: 12),
                      
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Documento (Opcional)', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        subtitle: Text(_fileDocumento?.name ?? 'Ningún archivo seleccionado'),
                        trailing: ElevatedButton(onPressed: _pickDocument, child: const Text('Examinar')),
                      ),
                      
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (_isEditing)
                            TextButton(onPressed: _cancelarEdicion, child: const Text('CANCELAR')),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _guardarVacaciones,
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[600], foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
                            child: _isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text(_isEditing ? 'ACTUALIZAR' : 'GUARDAR'),
                          )
                        ],
                      )
                    ]
                  ],
                ),
              ),
              ] else if (!puedeCrear && !_isEditing) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.yellow[50], borderRadius: BorderRadius.circular(8)),
                  child: const Text('No tienes permisos para registrar vacaciones.', style: TextStyle(color: Colors.orange, fontStyle: FontStyle.italic)),
                ),
              ],

              const SizedBox(height: 32),
              const Text('HISTORIAL DE VACACIONES', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 12, letterSpacing: 1.5)),
              const Divider(),
              
              if (_vacacionesEmpleado.isEmpty)
                const Padding(padding: EdgeInsets.all(32), child: Center(child: Text('No hay registros', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic))))
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _vacacionesEmpleado.length,
                  itemBuilder: (context, index) {
                    var v = _vacacionesEmpleado[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      color: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey[200]!)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Wrap(
                                    spacing: 8,
                                    runSpacing: 4,
                                    children: [
                                      Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(4)), child: Text('Periodo: ${v['periodo']}', style: const TextStyle(fontSize: 10, color: Colors.blue, fontWeight: FontWeight.bold))),
                                      Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: v['tipoSolicitud'] == 'Adelantadas' ? Colors.red[50] : Colors.grey[100], borderRadius: BorderRadius.circular(4)), child: Text('${v['tipoSolicitud']}', style: TextStyle(fontSize: 10, color: v['tipoSolicitud'] == 'Adelantadas' ? Colors.red : Colors.black87, fontWeight: FontWeight.bold))),
                                    ]
                                  ),
                                ),
                                Row(
                                  children: [
                                    if (_esUltimoRegistroPeriodo(v) && (double.tryParse(v['diasPendientes'].toString()) ?? 0) > 0 && puedeCrear)
                                      IconButton(icon: const Icon(Icons.add_circle_outline, color: Colors.indigo), onPressed: () => _continuarVacaciones(v), tooltip: 'Continuar', constraints: const BoxConstraints(), padding: const EdgeInsets.all(4)),
                                    if (v['documento'] != null)
                                      IconButton(icon: const Icon(Icons.description, color: Colors.green), onPressed: () async {
                                        final url = Uri.parse('${ApiConstants.baseUrl}${v['documento']}');
                                        if (await canLaunchUrl(url)) await launchUrl(url);
                                      }, tooltip: 'Ver Documento', constraints: const BoxConstraints(), padding: const EdgeInsets.all(4)),
                                    if (puedeEditar)
                                      IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _editarVacacion(v), constraints: const BoxConstraints(), padding: const EdgeInsets.all(4)),
                                    if (puedeEliminar)
                                      IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _eliminarVacacion(v['id']), constraints: const BoxConstraints(), padding: const EdgeInsets.all(4)),
                                  ],
                                )
                              ],
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 16,
                              runSpacing: 12,
                              children: [
                                _buildHistInfo('Días Corresp.', v['diasCorrespondientes'].toString()),
                                _buildHistInfo('Días Disfrutados', v['tipoSolicitud'] == 'Adelantadas' ? '0' : v['diasVacaciones'].toString(), color: Colors.blue),
                                _buildHistInfo('Días Adelantados', v['tipoSolicitud'] == 'Adelantadas' ? v['diasVacaciones'].toString() : '0', color: Colors.red),
                                _buildHistInfo('Días Pagados', v['diasPagados'].toString(), color: Colors.green),
                                _buildHistInfo('Días Pendientes', v['diasPendientes'].toString(), color: Colors.orange),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 16,
                              runSpacing: 8,
                              children: [
                                Text('Inicio: ${v['fechaInicio'] != null ? v['fechaInicio'].split('T')[0] : 'N/A'}', style: const TextStyle(fontSize: 12)),
                                Text('Final: ${v['fechaFinal'] != null ? v['fechaFinal'].split('T')[0] : 'N/A'}', style: const TextStyle(fontSize: 12)),
                                Text('Regreso: ${v['fechaRegreso'] != null ? v['fechaRegreso'].split('T')[0] : 'N/A'}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            if (v['observaciones'] != null && v['observaciones'].toString().isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(8),
                                color: Colors.yellow[50],
                                child: Text('Obs: ${v['observaciones']}', style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.yellow[800])),
                              )
                            ]
                          ],
                        ),
                      ),
                    );
                  },
                )
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, {bool isHighlight = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isHighlight ? Colors.orange : Colors.black87)),
      ],
    );
  }

  Widget _buildHistInfo(String label, String value, {Color color = Colors.black87}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildDatePicker(String label, DateTime? date, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_formatDate(date), style: TextStyle(color: date == null ? Colors.grey : Colors.black87)),
            const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
