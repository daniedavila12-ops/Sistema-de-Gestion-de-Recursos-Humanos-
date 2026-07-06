import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:innova_mobile/core/constants/api_constants.dart';

class CrearIncidenciaPublicaScreen extends StatefulWidget {
  const CrearIncidenciaPublicaScreen({super.key});

  @override
  State<CrearIncidenciaPublicaScreen> createState() => _CrearIncidenciaPublicaScreenState();
}

class _CrearIncidenciaPublicaScreenState extends State<CrearIncidenciaPublicaScreen> {
  final _formKey = GlobalKey<FormState>();
  final String _apiUrl = '${ApiConstants.baseUrl}/api/reportes-incidencia';

  final TextEditingController _jefeController = TextEditingController();
  final List<TextEditingController> _identidadControllers = [TextEditingController()];
  
  MaskTextInputFormatter _crearFormatter() {
    return MaskTextInputFormatter(
      mask: '####-####-#####',
      filter: {"#": RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy,
    );
  }
  
  late final List<MaskTextInputFormatter> _identidadFormatters = [_crearFormatter()];

  final TextEditingController _temaController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();

  void _agregarPersona() {
    setState(() {
      _identidadControllers.add(TextEditingController());
      _identidadFormatters.add(_crearFormatter());
    });
  }

  void _removerPersona(int index) {
    if (_identidadControllers.length > 1) {
      setState(() {
        _identidadControllers[index].dispose();
        _identidadControllers.removeAt(index);
        _identidadFormatters.removeAt(index);
      });
    }
  }

  String _categoria = 'General';
  String _prioridad = 'Media';
  List<dynamic> _categorias = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchCategorias();
  }

  @override
  void dispose() {
    for (var controller in _identidadControllers) {
      controller.dispose();
    }
    _jefeController.dispose();
    _temaController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _fetchCategorias() async {
    try {
      final res = await http.get(Uri.parse('$_apiUrl/categorias/lista'));
      if (res.statusCode == 200) {
        final data = json.decode(res.body) as List;
        setState(() {
          _categorias = data.where((c) => c['activa'] == 1 || c['activa'] == true).toList();
          if (_categorias.isNotEmpty) {
            _categoria = _categorias[0]['nombre'];
          }
        });
      }
    } catch (e) {
      debugPrint('Error cargando categorias: $e');
    }
  }

  Future<void> _crearReporte() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      var request = http.MultipartRequest('POST', Uri.parse('$_apiUrl/crear'));
      request.fields['jefe_reporta'] = _jefeController.text.trim();
      
      final identidades = _identidadControllers
          .map((c) => c.text.trim())
          .where((t) => t.isNotEmpty)
          .join(', ');
          
      request.fields['identidad'] = identidades;
      request.fields['categoria'] = _categoria;
      request.fields['prioridad'] = _prioridad;
      request.fields['tema'] = _temaController.text.trim();
      request.fields['descripcion'] = _descripcionController.text.trim();

      final response = await request.send();
      if (response.statusCode == 201 || response.statusCode == 200) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('✅ Reporte Enviado'),
              content: const Text('Tu reporte de incidencia ha sido enviado con éxito.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.go('/login');
                  },
                  child: const Text('Aceptar'),
                )
              ],
            ),
          );
        }
      } else {
        throw Exception('Error al enviar reporte');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al enviar reporte')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        title: const Text('Reportar Incidente', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/login')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(child: Text('⚠️', style: TextStyle(fontSize: 48))),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _jefeController,
                  decoration: const InputDecoration(labelText: 'Tu Nombre (Jefe/Encargado)', border: OutlineInputBorder()),
                  validator: (v) => v!.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 16),
                const Text('Identidad(es) Empleado(s) Reportado(s)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _identidadControllers.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _identidadControllers[index],
                              inputFormatters: [_identidadFormatters[index]],
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Número de Identidad',
                                hintText: 'Ej: 0801-1990-12345',
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Requerido';
                                if (v.length < 15) return 'Incompleto';
                                return null;
                              },
                            ),
                          ),
                          if (_identidadControllers.length > 1)
                            IconButton(
                              icon: const Icon(Icons.remove_circle, color: Colors.red),
                              onPressed: () => _removerPersona(index),
                            ),
                        ],
                      ),
                    );
                  },
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: _agregarPersona,
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar otra persona'),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _categoria,
                  decoration: const InputDecoration(labelText: 'Categoría', border: OutlineInputBorder()),
                  items: _categorias.isEmpty
                      ? const [DropdownMenuItem(value: 'General', child: Text('General'))]
                      : _categorias.map((c) => DropdownMenuItem<String>(value: c['nombre'], child: Text(c['nombre']))).toList(),
                  onChanged: (v) => setState(() => _categoria = v!),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _prioridad,
                  decoration: const InputDecoration(labelText: 'Gravedad', border: OutlineInputBorder()),
                  items: ['Baja', 'Media', 'Alta', 'Urgente']
                      .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                      .toList(),
                  onChanged: (v) => setState(() => _prioridad = v!),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _temaController,
                  decoration: const InputDecoration(labelText: 'Motivo / Asunto', border: OutlineInputBorder()),
                  validator: (v) => v!.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descripcionController,
                  decoration: const InputDecoration(labelText: 'Descripción', border: OutlineInputBorder()),
                  maxLines: 3,
                  validator: (v) => v!.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _crearReporte,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('ENVIAR REPORTE'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
