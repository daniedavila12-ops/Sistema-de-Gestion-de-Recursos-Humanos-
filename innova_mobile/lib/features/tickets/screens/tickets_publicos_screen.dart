import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:innova_mobile/core/constants/api_constants.dart';

class TicketsPublicosScreen extends StatefulWidget {
  const TicketsPublicosScreen({super.key});

  @override
  State<TicketsPublicosScreen> createState() => _TicketsPublicosScreenState();
}

class _TicketsPublicosScreenState extends State<TicketsPublicosScreen> {
  final _formKey = GlobalKey<FormState>();
  final String _apiUrl = '${ApiConstants.baseUrl}/api/tickets';

  final List<TextEditingController> _identidadControllers = [TextEditingController()];
  final TextEditingController _temaController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();

  String _categoria = 'Soporte IT';
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

  Future<void> _crearTicket() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      var request = http.MultipartRequest('POST', Uri.parse('$_apiUrl/crear'));
      request.fields['usuario_id'] = '';
      request.fields['identidad'] = _identidadControllers.map((c) => c.text.trim()).where((t) => t.isNotEmpty).join(',');
      request.fields['tipo'] = _categoria;
      request.fields['prioridad'] = _prioridad;
      request.fields['tema'] = _temaController.text.trim();
      request.fields['descripcion'] = _descripcionController.text.trim();

      final response = await request.send();
      if (response.statusCode == 201 || response.statusCode == 200) {
        final respStr = await response.stream.bytesToString();
        final data = json.decode(respStr);
        final ticketId = data['ticketId'];
        
        if (mounted) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('✅ Ticket Enviado'),
              content: Text('Su ticket fue enviado.\n\nPor favor copie este número para su seguimiento:\n\nTKT-${ticketId.toString().padLeft(3, '0')}'),
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
        throw Exception('Error al enviar ticket');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al enviar ticket')));
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
        title: const Text('Crear Ticket', style: TextStyle(fontWeight: FontWeight.bold)),
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
                const Center(child: Text('🎫', style: TextStyle(fontSize: 48))),
                const SizedBox(height: 16),
                ..._identidadControllers.asMap().entries.map((entry) {
                  int idx = entry.key;
                  TextEditingController controller = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: controller,
                            decoration: InputDecoration(
                              labelText: idx == 0 ? 'Número de Identidad' : 'Otro Número de Identidad', 
                              border: const OutlineInputBorder()
                            ),
                            validator: (v) => v!.isEmpty && idx == 0 ? 'Requerido' : null,
                          ),
                        ),
                        if (idx > 0)
                          IconButton(
                            icon: const Icon(Icons.remove_circle, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                _identidadControllers.removeAt(idx);
                              });
                            },
                          )
                      ],
                    ),
                  );
                }),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _identidadControllers.add(TextEditingController());
                    });
                  },
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('+ Agregar otra persona', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _categoria,
                  decoration: const InputDecoration(labelText: 'Categoría', border: OutlineInputBorder()),
                  items: _categorias.isEmpty
                      ? const [DropdownMenuItem(value: 'Soporte IT', child: Text('Soporte IT'))]
                      : _categorias.map((c) => DropdownMenuItem<String>(value: c['nombre'], child: Text(c['nombre']))).toList(),
                  onChanged: (v) => setState(() => _categoria = v!),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _prioridad,
                  decoration: const InputDecoration(labelText: 'Prioridad', border: OutlineInputBorder()),
                  items: ['Baja', 'Media', 'Alta', 'Urgente']
                      .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                      .toList(),
                  onChanged: (v) => setState(() => _prioridad = v!),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _temaController,
                  decoration: const InputDecoration(labelText: 'Tema / Asunto', border: OutlineInputBorder()),
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
                  onPressed: _isLoading ? null : _crearTicket,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('ENVIAR TICKET'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
