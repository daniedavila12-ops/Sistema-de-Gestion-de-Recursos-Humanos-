// CREADO POR: DANIEL INNOVA
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:innova_mobile/shared/utils/pdf_report_helper.dart';
import 'package:intl/intl.dart';
import '../widgets/dashboard_tab.dart';
import '../providers/reportes_provider.dart';
import '../../reportes_incidencias/providers/reporte_incidencia_provider.dart';
import '../../tickets/providers/tickets_filter_provider.dart';

class ReportesScreen extends ConsumerWidget {
  const ReportesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Módulo de Reportes'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(icon: Icon(Icons.dashboard), text: 'Dashboard'),
              Tab(icon: Icon(Icons.people), text: 'Personal'),
              Tab(icon: Icon(Icons.warning), text: 'Incidencias'),
              Tab(icon: Icon(Icons.confirmation_number), text: 'Tickets'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            const DashboardTab(),
            _buildPersonalTab(context, ref),
            _buildIncidenciasTab(context, ref),
            _buildTicketsTab(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalTab(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reportesProvider);
    if (state.isLoading) return const Center(child: CircularProgressIndicator());
    if (state.empleadosDetalles.isEmpty) return const Center(child: Text('No hay personal'));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                onPressed: () => _generarPDFPersonal(context, state.empleadosDetalles),
                icon: const Icon(Icons.picture_as_pdf, size: 16),
                label: const Text('CREAR PDF PERSONAL', style: TextStyle(fontSize: 10)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: state.empleadosDetalles.length,
            itemBuilder: (context, index) {
              final emp = state.empleadosDetalles[index];
              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text('${emp['nombre']} ${emp['apellido']}'),
                subtitle: Text('Depto: ${emp['departamento'] ?? 'N/A'} - Faltas: ${emp['total_faltas'] ?? 0}'),
                trailing: Text(emp['estado'] == 1 ? 'Activo' : 'Inactivo', 
                  style: TextStyle(color: emp['estado'] == 1 ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildIncidenciasTab(BuildContext context, WidgetRef ref) {
    final reportesAsyncValue = ref.watch(filteredReportesIncidenciaProvider);
    return reportesAsyncValue.when(
      data: (reportes) {
        if (reportes.isEmpty) return const Center(child: Text('No hay incidencias reportadas.'));
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _generarPDFIncidencias(context, reportes),
                    icon: const Icon(Icons.picture_as_pdf, size: 16),
                    label: const Text('CREAR PDF INCIDENCIAS', style: TextStyle(fontSize: 10)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[700],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: reportes.length,
                itemBuilder: (context, index) {
                  final rep = reportes[index];
                  return ListTile(
                    leading: Icon(Icons.warning, color: _getPriorityColor(rep.prioridad)),
                    title: Text(rep.tema),
                    subtitle: Text('${rep.categoria} • ${rep.estado}'),
                    trailing: Text(rep.fechaCreacion != null ? '${rep.fechaCreacion!.day}/${rep.fechaCreacion!.month}/${rep.fechaCreacion!.year}' : ''),
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildTicketsTab(BuildContext context, WidgetRef ref) {
    final ticketsAsyncValue = ref.watch(filteredTicketsProvider);
    return ticketsAsyncValue.when(
      data: (tickets) {
        if (tickets.isEmpty) return const Center(child: Text('No hay tickets reportados.'));
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _generarPDFTickets(context, tickets),
                    icon: const Icon(Icons.picture_as_pdf, size: 16),
                    label: const Text('CREAR PDF TICKETS', style: TextStyle(fontSize: 10)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple[700],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: tickets.length,
                itemBuilder: (context, index) {
                  final t = tickets[index];
                  return ListTile(
                    leading: Icon(Icons.confirmation_number, color: _getPriorityColor(t.prioridad)),
                    title: Text(t.tema),
                    subtitle: Text('${t.categoria} • ${t.estado}'),
                    trailing: Text(t.fechaCreacion != null ? '${t.fechaCreacion!.day}/${t.fechaCreacion!.month}/${t.fechaCreacion!.year}' : ''),
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error: $e')),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'urgente': return Colors.red;
      case 'alta': return Colors.orange;
      case 'media': return Colors.blue;
      default: return Colors.grey;
    }
  }

  Future<void> _generarPDFPersonal(BuildContext context, List<dynamic> empleados) async {
    final headers = ['Código', 'Nombre Completo', 'Departamento', 'Faltas', 'Estado'];
    final data = empleados.map((emp) => [
      emp['codigo_empleado']?.toString() ?? 'N/A',
      '${emp['nombre']} ${emp['apellido']}'.trim(),
      emp['departamento']?.toString() ?? 'N/A',
      emp['total_faltas']?.toString() ?? '0',
      emp['estado'] == 1 ? 'Activo' : 'Inactivo',
    ]).toList();

    await PdfReportHelper.generateTableReport(
      context: context,
      title: 'DIRECTORIO ANALÍTICO DE EMPLEADOS',
      fileName: 'Reporte_Personal.pdf',
      headers: headers,
      data: data,
      titleColor: PdfColors.blue900,
      headerColor: PdfColors.blue600,
      rowColor: PdfColors.blue50,
    );
  }

  Future<void> _generarPDFIncidencias(BuildContext context, List<dynamic> reportes) async {
    final headers = ['Tema', 'Categoría', 'Prioridad', 'Estado', 'Fecha'];
    final List<List<String>> data = reportes.map((rep) => <String>[
      rep.tema?.toString() ?? 'N/A',
      rep.categoria?.toString() ?? 'N/A',
      rep.prioridad?.toString() ?? 'N/A',
      rep.estado?.toString() ?? 'N/A',
      rep.fechaCreacion != null ? DateFormat('dd/MM/yyyy').format(rep.fechaCreacion!) : 'N/A',
    ]).toList();

    await PdfReportHelper.generateTableReport(
      context: context,
      title: 'REPORTE DE INCIDENCIAS LABORALES',
      fileName: 'Reporte_Incidencias.pdf',
      headers: headers,
      data: data,
      titleColor: PdfColors.orange900,
      headerColor: PdfColors.orange600,
      rowColor: PdfColors.orange50,
    );
  }

  Future<void> _generarPDFTickets(BuildContext context, List<dynamic> tickets) async {
    final headers = ['Tema', 'Categoría', 'Prioridad', 'Estado', 'Fecha'];
    final List<List<String>> data = tickets.map((t) => <String>[
      t.tema?.toString() ?? 'N/A',
      t.categoria?.toString() ?? 'N/A',
      t.prioridad?.toString() ?? 'N/A',
      t.estado?.toString() ?? 'N/A',
      t.fechaCreacion != null ? DateFormat('dd/MM/yyyy').format(t.fechaCreacion!) : 'N/A',
    ]).toList();

    await PdfReportHelper.generateTableReport(
      context: context,
      title: 'REPORTE DE SOPORTE Y TICKETS',
      fileName: 'Reporte_Tickets.pdf',
      headers: headers,
      data: data,
      titleColor: PdfColors.purple900,
      headerColor: PdfColors.purple600,
      rowColor: PdfColors.purple50,
    );
  }
}

