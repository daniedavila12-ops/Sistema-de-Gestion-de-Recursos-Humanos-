import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/reporte_incidencia_model.dart';
import '../../empleados/models/empleado_model.dart';
import 'package:innova_mobile/core/constants/api_constants.dart';

class PdfReporteGenerator {
  static const String baseUrl = ApiConstants.baseUrl;

  static Future<pw.ImageProvider?> _fetchImage(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return pw.MemoryImage(response.bodyBytes);
      }
    } catch (e) {
      debugPrint('Error loading image $url: $e');
    }
    return null;
  }

  static Future<void> generarPdfBasico(ReporteIncidencia reporte, List<Empleado> empleadosReportados) async {
    final pdf = pw.Document();
    final logo = await _fetchImage('$baseUrl/uploads/Logo/Logo.png');

    final Map<String, pw.ImageProvider> fotosEmpleados = {};
    for (var emp in empleadosReportados) {
      if (emp.foto != null) {
        final img = await _fetchImage('$baseUrl${emp.foto}');
        if (img != null) {
          fotosEmpleados[emp.identidad ?? ''] = img;
        }
      }
    }

    pw.ImageProvider? evidenciaImg;
    if (reporte.archivo != null &&
        (reporte.archivo!.toLowerCase().endsWith('.png') ||
         reporte.archivo!.toLowerCase().endsWith('.jpg') ||
         reporte.archivo!.toLowerCase().endsWith('.jpeg'))) {
      evidenciaImg = await _fetchImage('$baseUrl${reporte.archivo}');
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            _buildHeader(reporte, logo),
            pw.SizedBox(height: 20),
            _buildGeneralInfoTable(reporte),
            pw.SizedBox(height: 10),
            _buildEmployeePhotosRow(empleadosReportados, fotosEmpleados, reporte),
            pw.SizedBox(height: 10),
            _buildEmployeeInfoTable(reporte, empleadosReportados),
            pw.SizedBox(height: 20),
            _buildDescription(reporte),
            pw.SizedBox(height: 20),
            _buildEvidencia(reporte, evidenciaImg),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Reporte_Incidencia_${reporte.id}',
    );
  }

  static Future<void> generarPdfResoluciones(
      ReporteIncidencia reporte, List<RespuestaReporteIncidencia> respuestas, List<Empleado> empleadosReportados) async {
    final pdf = pw.Document();
    final logo = await _fetchImage('$baseUrl/uploads/Logo/Logo.png');

    final Map<String, pw.ImageProvider> fotosEmpleados = {};
    for (var emp in empleadosReportados) {
      if (emp.foto != null) {
        final img = await _fetchImage('$baseUrl${emp.foto}');
        if (img != null) {
          fotosEmpleados[emp.identidad ?? ''] = img;
        }
      }
    }

    pw.ImageProvider? evidenciaImg;
    if (reporte.archivo != null &&
        (reporte.archivo!.toLowerCase().endsWith('.png') ||
         reporte.archivo!.toLowerCase().endsWith('.jpg') ||
         reporte.archivo!.toLowerCase().endsWith('.jpeg'))) {
      evidenciaImg = await _fetchImage('$baseUrl${reporte.archivo}');
    }

    final Map<int, pw.ImageProvider?> resolucionesImgs = {};
    for (var res in respuestas) {
      if (res.archivoUrl != null && 
          (res.archivoUrl!.toLowerCase().endsWith('.png') ||
           res.archivoUrl!.toLowerCase().endsWith('.jpg') ||
           res.archivoUrl!.toLowerCase().endsWith('.jpeg'))) {
        resolucionesImgs[res.id] = await _fetchImage('$baseUrl${res.archivoUrl}');
      }
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        footer: (pw.Context context) => _buildFooter(context),
        build: (pw.Context context) {
          return [
            _buildHeader(reporte, logo, resoluciones: true),
            pw.SizedBox(height: 20),
            _buildGeneralInfoTable(reporte),
            pw.SizedBox(height: 10),
            _buildEmployeePhotosRow(empleadosReportados, fotosEmpleados, reporte),
            pw.SizedBox(height: 10),
            _buildEmployeeInfoTable(reporte, empleadosReportados),
            pw.SizedBox(height: 20),
            _buildDescription(reporte),
            pw.SizedBox(height: 20),
            _buildEvidencia(reporte, evidenciaImg),
            pw.SizedBox(height: 20),
            _buildConversacion(respuestas, resolucionesImgs),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Resoluciones_Incidencia_${reporte.id}',
    );
  }

  static pw.Widget _buildHeader(ReporteIncidencia reporte, pw.ImageProvider? logo, {bool resoluciones = false}) {
    final title = resoluciones ? 'REPORTE DE INCIDENCIA - RESOLUCIONES' : 'REPORTE DE INCIDENCIA';
    final dateStr = reporte.fechaCreacion != null 
        ? DateFormat('dd/MM/yyyy HH:mm:ss').format(reporte.fechaCreacion!)
        : 'Desconocido';

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(title, style: pw.TextStyle(color: PdfColor.fromHex('#dc2626'), fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 8),
                pw.Text('N° de Ticket: ${reporte.id}', style: pw.TextStyle(color: PdfColor.fromHex('#64748b'), fontSize: 11)),
                pw.Text('Generado el: $dateStr', style: pw.TextStyle(color: PdfColor.fromHex('#64748b'), fontSize: 11)),
                pw.Text('Estado: ${reporte.estado.toUpperCase()}', style: pw.TextStyle(color: PdfColor.fromHex('#64748b'), fontSize: 11)),
              ],
            ),
            if (logo != null)
              pw.Container(
                width: 100,
                height: 40,
                child: pw.Image(logo, fit: pw.BoxFit.contain),
              ),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Divider(color: PdfColor.fromHex('#dc2626'), thickness: 1.5),
      ],
    );
  }

  static pw.Widget _buildGeneralInfoTable(ReporteIncidencia reporte) {
    final dateStr = reporte.fechaCreacion != null 
        ? DateFormat('dd/MM/yyyy HH:mm:ss').format(reporte.fechaCreacion!)
        : 'N/A';
        
    return pw.TableHelper.fromTextArray(
      headers: ['Información General', ''],
      data: [
        ['Tema / Asunto', reporte.tema],
        ['Categoría', reporte.categoria],
        ['Reportado Por', reporte.jefeReporta ?? 'N/A'],
        ['Fecha del Reporte', dateStr],
      ],
      border: pw.TableBorder.all(color: PdfColor.fromHex('#e2e8f0')),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#0f172a')),
      headerDecoration: pw.BoxDecoration(color: PdfColor.fromHex('#f1f5f9')),
      cellPadding: const pw.EdgeInsets.all(6),
      columnWidths: {
        0: const pw.FixedColumnWidth(150),
        1: const pw.FlexColumnWidth(),
      },
    );
  }

  static pw.Widget _buildEmployeePhotosRow(List<Empleado> empleados, Map<String, pw.ImageProvider> fotos, ReporteIncidencia reporte) {
    if (empleados.isEmpty) {
      return pw.SizedBox();
    }

    final children = <pw.Widget>[];
    for (var emp in empleados) {
      final img = fotos[emp.identidad ?? ''];
      children.add(
        pw.Container(
          width: 70,
          height: 70,
          margin: const pw.EdgeInsets.only(right: 10),
          decoration: pw.BoxDecoration(
            color: PdfColor.fromHex('#f1f5f9'),
            borderRadius: pw.BorderRadius.circular(4),
            border: pw.Border.all(color: PdfColor.fromHex('#cbd5e1'), width: 1),
          ),
          child: img != null
              ? pw.ClipRRect(
                  horizontalRadius: 4,
                  verticalRadius: 4,
                  child: pw.Image(img, fit: pw.BoxFit.cover),
                )
              : pw.Center(
                  child: pw.Text(
                    emp.nombre.isNotEmpty ? emp.nombre[0].toUpperCase() : '?',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#64748b'), fontSize: 24),
                  ),
                ),
        )
      );
    }
    return pw.Row(children: children);
  }

  static pw.Widget _buildEmployeeInfoTable(ReporteIncidencia reporte, List<Empleado> empleados) {
    String nombresStr;
    String identidadesStr;
    String departamentosStr;

    if (empleados.isNotEmpty) {
      nombresStr = empleados.map((e) => '${e.nombre} ${e.apellido}'.trim()).join(', ');
      identidadesStr = empleados.map((e) => e.identidad ?? 'N/A').join(', ');
      departamentosStr = empleados.map((e) => '${e.nombre} ${e.apellido}: ${e.departamento ?? 'Sin Departamento'}').join(', ');
    } else {
      nombresStr = '${reporte.empleadoNombre ?? ''} ${reporte.empleadoApellido ?? ''}'.trim();
      if (nombresStr.isEmpty) nombresStr = 'N/A';
      identidadesStr = reporte.identidad ?? 'N/A';
      departamentosStr = 'Sin Departamento';
    }

    return pw.TableHelper.fromTextArray(
      headers: ['Datos del Empleado Reportado', ''],
      data: [
        ['Nombre', nombresStr],
        ['Identidad', identidadesStr],
        ['Departamento', departamentosStr],
      ],
      border: pw.TableBorder.all(color: PdfColor.fromHex('#e2e8f0')),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#0f172a')),
      headerDecoration: pw.BoxDecoration(color: PdfColor.fromHex('#f1f5f9')),
      cellPadding: const pw.EdgeInsets.all(6),
      columnWidths: {
        0: const pw.FixedColumnWidth(150),
        1: const pw.FlexColumnWidth(),
      },
    );
  }

  static pw.Widget _buildDescription(ReporteIncidencia reporte) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Descripción del Incidente:', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#0f172a'))),
        pw.SizedBox(height: 6),
        pw.Text(
          reporte.descripcion.isEmpty ? 'Sin descripción.' : reporte.descripcion,
          style: pw.TextStyle(fontSize: 10, color: PdfColor.fromHex('#334155')),
        ),
      ],
    );
  }

  static pw.Widget _buildEvidencia(ReporteIncidencia reporte, pw.ImageProvider? img) {
    if (reporte.archivo == null) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Evidencia Adjunta del Incidente:', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#0f172a'))),
          pw.SizedBox(height: 6),
          pw.Text('No hay evidencia adjunta al reporte inicial.', style: pw.TextStyle(fontSize: 10, color: PdfColor.fromHex('#64748b'), fontStyle: pw.FontStyle.italic)),
        ]
      );
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Evidencia Adjunta del Incidente:', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#0f172a'))),
        pw.SizedBox(height: 6),
        if (img != null)
          pw.Container(
            height: 200,
            alignment: pw.Alignment.centerLeft,
            child: pw.Image(img, fit: pw.BoxFit.contain),
          )
        else
          pw.Text('Archivo de documento adjunto: ${reporte.archivo}', style: pw.TextStyle(fontSize: 10, color: PdfColor.fromHex('#334155'))),
      ],
    );
  }

  static pw.Widget _buildConversacion(List<RespuestaReporteIncidencia> respuestas, Map<int, pw.ImageProvider?> resolucionesImgs) {
    if (respuestas.isEmpty) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Conversación y Resoluciones:', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#0f172a'))),
          pw.SizedBox(height: 6),
          pw.Text('No hay respuestas registradas aún.', style: pw.TextStyle(fontSize: 10, color: PdfColor.fromHex('#64748b'), fontStyle: pw.FontStyle.italic)),
        ]
      );
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Conversación y Resoluciones:', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#0f172a'))),
        pw.SizedBox(height: 8),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColor.fromHex('#e2e8f0')),
          columnWidths: {
            0: const pw.FixedColumnWidth(120),
            1: const pw.FlexColumnWidth(),
          },
          children: [
            pw.TableRow(
              decoration: pw.BoxDecoration(color: PdfColor.fromHex('#f1f5f9')),
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text('Usuario / Fecha', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#0f172a'))),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text('Mensaje', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#0f172a'))),
                ),
              ],
            ),
            ...respuestas.map((res) {
              final fecha = DateFormat('dd/MM/yyyy HH:mm:ss').format(res.fechaCreacion);
              final nombre = res.usuarioNombre.isEmpty ? 'Usuario' : res.usuarioNombre;
              final img = resolucionesImgs[res.id];
              return pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('$nombre\n$fecha', style: pw.TextStyle(fontSize: 10)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(res.respuesta, style: pw.TextStyle(fontSize: 10)),
                        if (img != null) ...[
                          pw.SizedBox(height: 10),
                          pw.Container(
                            height: 150,
                            alignment: pw.Alignment.centerLeft,
                            child: pw.Image(img, fit: pw.BoxFit.contain),
                          ),
                        ] else if (res.archivoUrl != null) ...[
                          pw.SizedBox(height: 10),
                          pw.Text('[📎 Archivo Adjunto: ${res.archivoUrl}]', style: pw.TextStyle(fontSize: 10, color: PdfColor.fromHex('#64748b'))),
                        ],
                      ],
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ]
    );
  }

  static pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 20),
      child: pw.Column(
        children: [
          pw.Divider(color: PdfColor.fromHex('#000000'), thickness: 1, indent: 150, endIndent: 150),
          pw.SizedBox(height: 5),
          pw.Text(
            'Firma de Jefe inmediato / supervisor',
            style: const pw.TextStyle(fontSize: 10),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.Text(
                'Página ${context.pageNumber} de ${context.pagesCount}',
                style: pw.TextStyle(fontSize: 8, color: PdfColor.fromHex('#64748b')),
              )
            ]
          )
        ]
      )
    );
  }
}
