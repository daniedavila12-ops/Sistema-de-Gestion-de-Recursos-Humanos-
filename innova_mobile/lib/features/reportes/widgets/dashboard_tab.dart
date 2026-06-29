// CREADO POR: DANIEL INNOVA
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pdf/pdf.dart';
import 'package:innova_mobile/shared/utils/pdf_report_helper.dart';
import '../providers/reportes_provider.dart';
import '../models/reporte_stats_model.dart';

class DashboardTab extends ConsumerWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportesState = ref.watch(reportesProvider);

    if (reportesState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (reportesState.error != null) {
      return Center(child: Text(reportesState.error!, style: const TextStyle(color: Colors.red)));
    }

    if (reportesState.stats == null) {
      return const Center(child: Text('No hay datos disponibles.'));
    }

    final stats = reportesState.stats!;
    final genderDist = reportesState.getGenderDistribution();
    final ageDist = reportesState.getAgeDistribution();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Resumen', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                onPressed: () => _generarPDFDashboard(context, stats),
                icon: const Icon(Icons.picture_as_pdf, size: 16),
                label: const Text('CREAR PDF DASHBOARD', style: TextStyle(fontSize: 10)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Tarjetas de Resumen
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              _buildStatCard('Total Empleados', stats.total.toString(), Colors.blue),
              _buildStatCard('Activos', stats.activos.toString(), Colors.green),
              _buildStatCard('Incidencias', stats.incidencias.toString(), Colors.orange),
              _buildStatCard('Tickets', stats.tickets.toString(), Colors.purple),
            ],
          ),
          const SizedBox(height: 32),
          
          // Gráfico de Género
          const Text('Distribución por Género', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          SizedBox(
            height: 250,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    value: genderDist['Masculino']!.toDouble(),
                    title: 'Hombres (${genderDist['Masculino']})',
                    color: Colors.blueAccent,
                    radius: 80,
                    titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  PieChartSectionData(
                    value: genderDist['Femenino']!.toDouble(),
                    title: 'Mujeres (${genderDist['Femenino']})',
                    color: Colors.pinkAccent,
                    radius: 80,
                    titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
                sectionsSpace: 2,
                centerSpaceRadius: 40,
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Gráfico de Edad
          const Text('Distribución por Edad', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          SizedBox(
            height: 250,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (ageDist.values.reduce((a, b) => a > b ? a : b) + 5).toDouble(),
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const style = TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12);
                        String text;
                        switch (value.toInt()) {
                          case 0: text = '18-25'; break;
                          case 1: text = '26-35'; break;
                          case 2: text = '36-45'; break;
                          case 3: text = '+45'; break;
                          default: text = ''; break;
                        }
                        return SideTitleWidget(meta: meta, child: Text(text, style: style));
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: [
                  _buildBarGroup(0, ageDist['18-25']!.toDouble(), Colors.lightBlue),
                  _buildBarGroup(1, ageDist['26-35']!.toDouble(), Colors.indigo),
                  _buildBarGroup(2, ageDist['36-45']!.toDouble(), Colors.deepPurple),
                  _buildBarGroup(3, ageDist['+45']!.toDouble(), Colors.purple),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  BarChartGroupData _buildBarGroup(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 22,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6)),
        ),
      ],
    );
  }

  Future<void> _generarPDFDashboard(BuildContext context, ReporteStats stats) async {
    final headers = ['Métrica', 'Cantidad'];
    final List<List<String>> data = [
      ['Total Empleados', '${stats.total}'],
      ['Activos', '${stats.activos}'],
      ['Inactivos', '${stats.inactivos}'],
      ['De Vacaciones', '${stats.deVacaciones}'],
      ['Faltas Acumuladas', '${stats.faltasMes}'],
      ['Documentos Legales', '${stats.docLegales}'],
      ['Contratos por Vencer', '${stats.vencimientos}'],
      ['Tickets Registrados', '${stats.tickets}'],
    ];

    await PdfReportHelper.generateTableReport(
      context: context,
      title: 'REPORTE: DASHBOARD GENERAL',
      fileName: 'Reporte_Dashboard.pdf',
      headers: headers,
      data: data,
      titleColor: PdfColors.blue900,
      headerColor: PdfColors.blue600,
      rowColor: PdfColors.blue50,
    );
  }
}
