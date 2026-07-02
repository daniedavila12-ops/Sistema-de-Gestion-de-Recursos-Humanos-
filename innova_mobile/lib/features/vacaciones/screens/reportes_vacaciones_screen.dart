import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../../../core/api/api_client.dart';

class ReportesVacacionesScreen extends StatefulWidget {
  const ReportesVacacionesScreen({super.key});

  @override
  State<ReportesVacacionesScreen> createState() => _ReportesVacacionesScreenState();
}

class _ReportesVacacionesScreenState extends State<ReportesVacacionesScreen> {
  bool _isLoading = false;

  Future<void> _generarReporteGlobal() async {
    setState(() => _isLoading = true);
    try {
      final res = await apiClient.get('/empleados/lista');
      final List<dynamic> empleados = res.data;

      final doc = pw.Document();

      // Mapear los datos de empleados
      final tableData = empleados.map((emp) {
        String? inicioStr = emp['fecha_inicio'];
        DateTime inicio = DateTime.now();
        if (inicioStr != null) {
          if (inicioStr.contains('T')) {
            inicioStr = inicioStr.split('T')[0];
          }
          inicio = DateTime.tryParse('$inicioStr 00:00:00') ?? DateTime.now();
        }

        DateTime hoy = DateTime.now();
        int anios = hoy.year - inicio.year;
        if (hoy.month < inicio.month || (hoy.month == inicio.month && hoy.day < inicio.day)) {
          anios--;
        }
        if (anios < 0) anios = 0;

        int diasCorrespondientes = 0;
        if (anios >= 4) {
          diasCorrespondientes = 20;
        } else if (anios == 3) {
          diasCorrespondientes = 15;
        } else if (anios == 2) {
          diasCorrespondientes = 12;
        } else if (anios == 1) {
          diasCorrespondientes = 10;
        }

        return [
          emp['codigo_empleado'] ?? 'N/A',
          '${emp['nombre']} ${emp['apellido']}',
          emp['identidad'] ?? 'N/A',
          emp['fecha_inicio'] != null ? DateFormat('dd/MM/yyyy').format(inicio) : 'N/A',
          emp['ubicacion'] ?? 'N/A',
          '$anios años',
          '$diasCorrespondientes días'
        ];
      }).toList();

      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4.landscape,
          margin: const pw.EdgeInsets.all(32),
          header: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('REPORTE GLOBAL DE EMPLEADOS Y VACACIONES BASE',
                    style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                pw.SizedBox(height: 4),
                pw.Text('Generado el: ${DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now())}',
                    style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                pw.Divider(color: PdfColors.grey400),
                pw.SizedBox(height: 12),
              ],
            );
          },
          build: (pw.Context context) {
            return [
              pw.TableHelper.fromTextArray(
                headers: ['Código', 'Empleado', 'Identidad', 'Fecha Ingreso', 'Ubicación', 'Antigüedad', 'Días Base'],
                data: tableData,
                border: pw.TableBorder.all(color: PdfColors.grey300),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.indigo500),
                cellStyle: const pw.TextStyle(fontSize: 9),
                cellPadding: const pw.EdgeInsets.all(4),
                oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
              ),
            ];
          },
        ),
      );

      final bytes = await doc.save();
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => bytes,
        name: 'Reporte_Global_Vacaciones_${DateFormat('yyyy-MM-dd').format(DateTime.now())}.pdf',
      );

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al generar PDF: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes de Vacaciones', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.blue[900],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: _isLoading 
          ? const CircularProgressIndicator()
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.picture_as_pdf, size: 80, color: Colors.redAccent),
                  const SizedBox(height: 20),
                  const Text('Generador de Reportes', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  const Text(
                    'Genere un reporte en PDF de todos los empleados junto a su antigüedad y sus días base de vacaciones.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton.icon(
                    onPressed: _generarReporteGlobal,
                    icon: const Icon(Icons.download, color: Colors.white),
                    label: const Text('REPORTE GLOBAL DE EMPLEADOS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  )
                ],
              ),
            ),
      ),
    );
  }
}
