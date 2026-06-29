import 'package:flutter/material.dart';
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
  final TextEditingController _identidadController = TextEditingController();
  final TextEditingController _temaController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();

  String _categoria = 'General';
  String _prioridad = 'Media';
  List<dynamic> _categorias = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchCategorias();
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
      request.fields['identidad'] = _identidadController.text.trim();
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
                TextFormField(
                  controller: _identidadController,
                  decoration: const InputDecoration(labelText: 'Identidad Empleado Reportado', border: OutlineInputBorder()),
                  validator: (v) => v!.isEmpty ? 'Requerido' : null,
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
