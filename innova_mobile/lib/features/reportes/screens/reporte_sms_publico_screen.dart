import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:innova_mobile/core/constants/api_constants.dart';

class ReporteSmsPublicoScreen extends StatefulWidget {
  const ReporteSmsPublicoScreen({super.key});

  @override
  State<ReporteSmsPublicoScreen> createState() => _ReporteSmsPublicoScreenState();
}

class _ReporteSmsPublicoScreenState extends State<ReporteSmsPublicoScreen> {
  final TextEditingController _searchController = TextEditingController();
  final String _apiUrl = '${ApiConstants.baseUrl}/api/tickets';

  bool _isLoading = false;
  Map<String, dynamic>? _ticket;
  String _errorMsg = '';

  Future<void> _buscarTicket() async {
    final searchTxt = _searchController.text.trim();
    if (searchTxt.isEmpty) return;

    final match = RegExp(r'\d+').firstMatch(searchTxt);
    if (match == null) {
      setState(() => _errorMsg = 'Formato inválido. Usa un número (ej. 18 o TKT-018)');
      return;
    }

    final numericId = match.group(0);
    setState(() {
      _isLoading = true;
      _errorMsg = '';
      _ticket = null;
    });

    try {
      final res = await http.get(Uri.parse('$_apiUrl/$numericId'));
      if (res.statusCode == 200) {
        setState(() {
          _ticket = json.decode(res.body);
        });
      } else if (res.statusCode == 404) {
        setState(() => _errorMsg = 'Ticket no encontrado. Verifica el número.');
      } else {
        setState(() => _errorMsg = 'Error al buscar el ticket.');
      }
    } catch (e) {
      setState(() => _errorMsg = 'Error de conexión.');
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
        title: const Text('Seguimiento de Ticket', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/login')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
              child: Column(
                children: [
                  const Text('Consulta el estado de tu solicitud', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            hintText: 'Ej: TKT-018 o 18',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _buscarTicket,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                        ),
                        child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('BUSCAR'),
                      ),
                    ],
                  ),
                  if (_errorMsg.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(_errorMsg, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  ],
                ],
              ),
            ),
            
            if (_ticket != null) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('TKT-${_ticket!['id'].toString().padLeft(3, '0')}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                        Chip(
                          label: Text(_ticket!['estado'] ?? 'Desconocido'),
                          backgroundColor: _ticket!['estado'] == 'Cerrado' ? Colors.red.shade100 : Colors.blue.shade100,
                          labelStyle: TextStyle(
                            color: _ticket!['estado'] == 'Cerrado' ? Colors.red.shade800 : Colors.blue.shade800,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(_ticket!['tema'] ?? _ticket!['tipo'] ?? 'General', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
                      width: double.infinity,
                      child: Text(_ticket!['descripcion'] ?? ''),
                    ),
                    const SizedBox(height: 16),
                    Text('Prioridad: ${_ticket!['prioridad']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('Solicitante: ${_ticket!['empleado_nombre'] ?? 'Externo'}'),
                    Text('Asignado a: ${_ticket!['asignado_empleado_nombre'] ?? 'Sin asignar'}'),
                  ],
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
