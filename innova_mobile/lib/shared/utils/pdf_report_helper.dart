// CREADO POR: DANIEL INNOVA
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart' show BuildContext, ScaffoldMessenger, SnackBar, Text;

class PdfReportHelper {
  /// Genera y muestra un PDF con un título, fecha y una tabla de datos.
  static Future<void> generateTableReport({
    required BuildContext context,
    required String title,
    required String fileName,
    required List<String> headers,
    required List<List<String>> data,
    PdfColor titleColor = PdfColors.blue900,
    PdfColor headerColor = PdfColors.blue600,
    PdfColor rowColor = PdfColors.blue50,
  }) async {
    try {
      final doc = pw.Document();
      final dateStr = DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now());

      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context pdfContext) {
            return [
              pw.Text(title, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: titleColor)),
              pw.SizedBox(height: 5),
              pw.Text('Generado el: $dateStr', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
              pw.SizedBox(height: 10),
              pw.Divider(color: PdfColors.grey300),
              pw.SizedBox(height: 20),
              pw.TableHelper.fromTextArray(
                headers: headers,
                data: data,
                border: pw.TableBorder.all(color: PdfColors.grey300),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                headerDecoration: pw.BoxDecoration(color: headerColor),
                rowDecoration: pw.BoxDecoration(color: rowColor),
                oddRowDecoration: const pw.BoxDecoration(color: PdfColors.white),
              ),
            ];
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => doc.save(),
        name: fileName,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al generar el PDF')));
      }
    }
  }
}
