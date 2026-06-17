// CREADO POR: DANIEL INNOVA

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ReportesIncidenciasScreen extends StatefulWidget {
  const ReportesIncidenciasScreen({super.key});

  @override
  State<ReportesIncidenciasScreen> createState() => _ReportesIncidenciasScreenState();
}

class _ReportesIncidenciasScreenState extends State<ReportesIncidenciasScreen> {
  bool isLoading = true;
  List<dynamic> reportes = [];

  @override
  void initState() {
    super.initState();
    _cargarReportes();
  }

  Future<void> _cargarReportes() async {
    setState(() => isLoading = true);
    try {
      // Recordatorio: localhost en emulador de Android es 10.0.2.2
      final url = Uri.parse('http://10.0.2.2:3007/api/reportes-incidencia');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          reportes = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Error al cargar la lista de reportes');
      }
    } catch (e) {
      debugPrint('Error cargando reportes en Flutter: $e');
      if (mounted) setState(() => isLoading = false);
    }
  }

  // Helper para pintar el estado de la incidencia con los mismos colores de la web
  Color _getColorPorEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return Colors.red;
      case 'en proceso':
        return Colors.orange;
      case 'resuelto':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _cargarReportes,
              child: reportes.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 100),
                        Center(child: Text('No hay reportes de incidencias', style: TextStyle(color: Colors.grey))),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: reportes.length,
                      itemBuilder: (context, index) {
                        final reporte = reportes[index];
                        final colorEstado = _getColorPorEstado(reporte['estado'] ?? '');

                        return Card(
                          elevation: 0,
                          margin: const EdgeInsets.only(bottom: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: Colors.grey.shade200),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            title: Text(
                              reporte['tema'] ?? 'Sin Tema',
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF1E293B)),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8),
                                Text('👨‍💼 Reportado: ${reporte['empleado_nombre'] ?? ''} ${reporte['empleado_apellido'] ?? ''}'),
                                const SizedBox(height: 4),
                                Text('📅 Fecha: ${reporte['fecha_creacion']?.toString().split('T')[0] ?? ''}'),
                              ],
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(color: colorEstado.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: colorEstado.withValues(alpha: 0.5))),
                              child: Text((reporte['estado'] ?? 'Desconocido').toUpperCase(), style: TextStyle(color: colorEstado, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                            ),
                            onTap: () {
                              // PROXIMAMENTE: Navegaremos a la pantalla de Detalle del Reporte
                            },
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}