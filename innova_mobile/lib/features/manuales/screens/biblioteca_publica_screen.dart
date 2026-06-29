import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:innova_mobile/core/constants/api_constants.dart';

class BibliotecaPublicaScreen extends StatefulWidget {
  const BibliotecaPublicaScreen({super.key});

  @override
  State<BibliotecaPublicaScreen> createState() => _BibliotecaPublicaScreenState();
}

class _BibliotecaPublicaScreenState extends State<BibliotecaPublicaScreen> {
  final String _apiUrl = '${ApiConstants.baseUrl}/api/biblioteca';
  final String _baseServerUrl = ApiConstants.baseUrl;
  
  List<dynamic> _manuales = [];
  List<dynamic> _manualesFiltrados = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchManuales();
  }

  Future<void> _fetchManuales() async {
    try {
      final response = await http.get(Uri.parse(_apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        setState(() {
          _manuales = data;
          _manualesFiltrados = data;
          _isLoading = false;
        });
      } else {
        throw Exception('Error al cargar la biblioteca');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _filterManuales(String query) {
    setState(() {
      _manualesFiltrados = _manuales.where((m) {
        final titulo = m['titulo']?.toString().toLowerCase() ?? '';
        final categoria = m['categoria']?.toString().toLowerCase() ?? '';
        final lowerQuery = query.toLowerCase();
        return titulo.contains(lowerQuery) || categoria.contains(lowerQuery);
      }).toList();
    });
  }

  Future<void> _descargarManual(String path) async {
    String normalizedPath = path.replaceAll('\\', '/');
    if (!normalizedPath.startsWith('/')) {
      normalizedPath = '/$normalizedPath';
    }
    
    final url = Uri.parse('$_baseServerUrl$normalizedPath');
    
    try {
      final success = await launchUrl(url, mode: LaunchMode.externalApplication);
      if (!success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se pudo iniciar la descarga')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al abrir URL: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        title: const Text('Biblioteca Digital', style: TextStyle(fontWeight: FontWeight.w900)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Buscar manual por nombre o categoría...',
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                filled: true,
                fillColor: const Color(0xFF1E293B),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
              onChanged: _filterManuales,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _manualesFiltrados.isEmpty
                      ? const Center(child: Text('No se encontraron manuales.', style: TextStyle(color: Colors.white54, fontStyle: FontStyle.italic)))
                      : ListView.builder(
                          itemCount: _manualesFiltrados.length,
                          itemBuilder: (context, index) {
                            final manual = _manualesFiltrados[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              child: Column(
                                children: [
                                  Container(height: 8, decoration: const BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.vertical(top: Radius.circular(20)))),
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Chip(
                                              label: Text(manual['categoria'] ?? 'General'),
                                              backgroundColor: Colors.blue.shade50,
                                              labelStyle: TextStyle(color: Colors.blue.shade800, fontSize: 10, fontWeight: FontWeight.bold),
                                              visualDensity: VisualDensity.compact,
                                            ),
                                            Text(manual['tamano'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(manual['titulo'] ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                                        const SizedBox(height: 4),
                                        Text(manual['descripcion'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 14, fontStyle: FontStyle.italic)),
                                        const SizedBox(height: 16),
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton.icon(
                                            icon: const Icon(Icons.download),
                                            label: const Text('Descargar PDF', style: TextStyle(fontWeight: FontWeight.bold)),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFF0F172A),
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                              padding: const EdgeInsets.symmetric(vertical: 12),
                                            ),
                                            onPressed: () {
                                              if (manual['archivo'] != null) {
                                                _descargarManual(manual['archivo']);
                                              }
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
