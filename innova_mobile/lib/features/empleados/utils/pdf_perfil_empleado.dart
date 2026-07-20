// CREADO POR: DANIEL INNOVA
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/empleado_model.dart';
import 'package:innova_mobile/core/constants/api_constants.dart';
import 'package:http/http.dart' as http;

class PdfPerfilEmpleado {
  static Future<void> generarPDF(Empleado empleado) async {
    final doc = pw.Document();

    pw.MemoryImage? profileImage;
    if (empleado.foto != null && empleado.foto!.isNotEmpty) {
      try {
        final response = await http.get(Uri.parse('${ApiConstants.baseUrl}${empleado.foto}'));
        if (response.statusCode == 200) {
          profileImage = pw.MemoryImage(response.bodyBytes);
        }
      } catch (e) {
        // Ignorar error de carga de foto
      }
    }

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  if (profileImage != null)
                    pw.Container(
                      width: 80,
                      height: 80,
                      margin: const pw.EdgeInsets.only(right: 16),
                      decoration: pw.BoxDecoration(
                        shape: pw.BoxShape.rectangle,
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                        image: pw.DecorationImage(image: profileImage, fit: pw.BoxFit.cover),
                      ),
                    ),
                  pw.Expanded(
                    child: pw.Column(
                      mainAxisSize: pw.MainAxisSize.min,
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('PERFIL DEL EMPLEADO',
                            style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                        pw.SizedBox(height: 4),
                        pw.Text('Identidad: ${empleado.identidad ?? 'N/A'}',
                            style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700)),
                        pw.Text('Generado el: ${DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now())}',
                            style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700)),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 8),
              pw.Divider(color: PdfColors.blue900, thickness: 1.5),
              pw.SizedBox(height: 12),
            ],
          );
        },
        footer: (pw.Context context) {
          return pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(top: 1.0 * PdfPageFormat.cm),
            child: pw.Text(
              'INNOVA SISTEMA RRHH - Página ${context.pageNumber} de ${context.pagesCount}',
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
            ),
          );
        },
        build: (pw.Context context) {
          return [
            // Información Principal
            pw.TableHelper.fromTextArray(
              headers: ['Información Principal', ''],
              data: [
                ['Nombre Completo', empleado.nombreCompleto],
                ['Código de Empleado', empleado.codigoEmpleado ?? 'N/A'],
                ['Tipo de Contrato', empleado.tipoContrato ?? 'Permanente'],
                ['Estado', empleado.estado == 1 ? 'Activo' : 'Inactivo'],
              ],
              border: pw.TableBorder.all(color: PdfColors.grey300),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.blue900),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
              cellStyle: const pw.TextStyle(fontSize: 10),
              cellPadding: const pw.EdgeInsets.all(6),
              columnWidths: {0: const pw.FixedColumnWidth(150)},
            ),
            pw.SizedBox(height: 20),

            // Información Personal
            pw.TableHelper.fromTextArray(
              headers: ['Información Personal', ''],
              data: [
                ['Fecha de Nacimiento', empleado.fechaNacimiento != null ? DateFormat('dd/MM/yyyy').format(DateTime.parse(empleado.fechaNacimiento!)) : 'N/A'],
                ['Correo Electrónico', empleado.correo ?? 'N/A'],
                ['Teléfono', empleado.telefono ?? 'N/A'],
                ['Dirección', empleado.direccion ?? 'N/A'],
              ],
              border: pw.TableBorder.all(color: PdfColors.grey300),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.blue900),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
              cellStyle: const pw.TextStyle(fontSize: 10),
              cellPadding: const pw.EdgeInsets.all(6),
              columnWidths: {0: const pw.FixedColumnWidth(150)},
            ),
            pw.SizedBox(height: 20),

            // Información Laboral
            pw.TableHelper.fromTextArray(
              headers: ['Información Laboral', ''],
              data: [
                ['Fecha de Inicio', empleado.fechaInicio != null ? DateFormat('dd/MM/yyyy').format(empleado.fechaInicio!) : 'N/A'],
                ['Ciudad', empleado.ciudad ?? 'N/A'],
                ['Ubicación / Piso', empleado.ubicacion ?? 'N/A'],
              ],
              border: pw.TableBorder.all(color: PdfColors.grey300),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.blue900),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
              cellStyle: const pw.TextStyle(fontSize: 10),
              cellPadding: const pw.EdgeInsets.all(6),
              columnWidths: {0: const pw.FixedColumnWidth(150)},
            ),
            pw.SizedBox(height: 20),

            // Contactos de Emergencia
            if ((empleado.emergenciaNombre != null && empleado.emergenciaNombre!.isNotEmpty) ||
                (empleado.emergenciaNombre2 != null && empleado.emergenciaNombre2!.isNotEmpty)) ...[
              pw.TableHelper.fromTextArray(
                headers: ['Contacto de Emergencia', 'Parentesco', 'Teléfono'],
                data: [
                  if (empleado.emergenciaNombre != null && empleado.emergenciaNombre!.isNotEmpty)
                    [empleado.emergenciaNombre, empleado.emergenciaParentesco ?? 'N/A', empleado.emergenciaTelefono ?? 'N/A'],
                  if (empleado.emergenciaNombre2 != null && empleado.emergenciaNombre2!.isNotEmpty)
                    [empleado.emergenciaNombre2, empleado.emergenciaParentesco2 ?? 'N/A', empleado.emergenciaTelefono2 ?? 'N/A'],
                ],
                border: pw.TableBorder.all(color: PdfColors.grey300),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.deepOrange800),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.orange50),
                cellStyle: const pw.TextStyle(fontSize: 10),
                cellPadding: const pw.EdgeInsets.all(6),
              ),
            ]
          ];
        },
      ),
    );

    final bytes = await doc.save();
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => bytes,
      name: 'Perfil_Empleado_${empleado.identidad ?? empleado.id}.pdf',
    );
  }
}
