import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/ticket_model.dart';
import 'package:innova_mobile/core/constants/api_constants.dart';
import '../../empleados/models/empleado_model.dart';

class PdfTicketGenerator {
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

  static Future<void> generarPdfTicket(Ticket ticket, List<RespuestaTicket> respuestas, List<Empleado> requesters) async {
    final pdf = pw.Document();
    final logo = await _fetchImage('$baseUrl/uploads/Logo/Logo.png');

    // Fetch avatars and attachment
    final Map<String, pw.ImageProvider> avatars = {};
    for (final req in requesters) {
      if (req.foto != null) {
        final img = await _fetchImage('$baseUrl${req.foto}');
        if (img != null) avatars[req.foto!] = img;
      }
    }
    
    pw.ImageProvider? attachmentImage;
    if (ticket.archivo != null) {
      final url = ticket.archivo!.toLowerCase();
      if (url.endsWith('.png') || url.endsWith('.jpg') || url.endsWith('.jpeg') || url.endsWith('.gif') || url.endsWith('.webp')) {
         attachmentImage = await _fetchImage('$baseUrl${ticket.archivo}');
      }
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.only(left: 32, right: 32, top: 32, bottom: 80),
        footer: (pw.Context context) => _buildFooter(context),
        build: (pw.Context context) {
          return [
            _buildHeader(ticket, logo),
            pw.SizedBox(height: 20),
            _buildGeneralInfoTable(ticket),
            pw.SizedBox(height: 10),
            _buildEmployeeInfoTable(requesters, avatars),
            pw.SizedBox(height: 20),
            _buildDescription(ticket, attachmentImage),
            pw.SizedBox(height: 20),
            _buildConversacion(respuestas),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Ticket_Soporte_${ticket.id}',
    );
  }

  static pw.Widget _buildHeader(Ticket ticket, pw.ImageProvider? logo) {
    final dateStr = ticket.fechaCreacion != null 
        ? DateFormat('dd/MM/yyyy HH:mm:ss').format(ticket.fechaCreacion!)
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
                pw.Text('REPORTE DE INCIDENCIA DE TICKET', style: pw.TextStyle(color: PdfColor.fromHex('#dc2626'), fontSize: 16, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 8),
                pw.Text('N° de Ticket: ${ticket.id}', style: pw.TextStyle(color: PdfColor.fromHex('#64748b'), fontSize: 11)),
                pw.Text('Generado el: $dateStr', style: pw.TextStyle(color: PdfColor.fromHex('#64748b'), fontSize: 11)),
                pw.Text('Estado: ${ticket.estado.toUpperCase()}', style: pw.TextStyle(color: PdfColor.fromHex('#64748b'), fontSize: 11)),
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

  static pw.Widget _buildGeneralInfoTable(Ticket ticket) {
    return pw.TableHelper.fromTextArray(
      headers: ['Información General', ''],
      data: [
        ['Tema / Asunto', ticket.tema],
        ['Categoría', ticket.categoria],
        ['Prioridad', ticket.prioridad],
        ['Asignado A', ticket.asignadoNombre],
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

  static pw.Widget _buildEmployeeInfoTable(List<Empleado> requesters, Map<String, pw.ImageProvider> avatars) {
    // Collect all names and phones
    final List<String> names = [];
    final List<String> phones = [];
    
    for (final req in requesters) {
      names.add('${req.nombre} ${req.apellido}'.trim());
      phones.add(req.telefono ?? 'N/A');
    }

    // Build avatars row
    final List<pw.Widget> avatarWidgets = requesters.map((req) {
      if (req.foto != null && avatars.containsKey(req.foto)) {
        return pw.Container(
          width: 40,
          height: 40,
          margin: const pw.EdgeInsets.only(right: 8),
          decoration: pw.BoxDecoration(
            shape: pw.BoxShape.circle,
            image: pw.DecorationImage(image: avatars[req.foto!]!, fit: pw.BoxFit.cover)
          ),
        );
      }
      return pw.Container(
        width: 40,
        height: 40,
        margin: const pw.EdgeInsets.only(right: 8),
        decoration: pw.BoxDecoration(shape: pw.BoxShape.circle, color: PdfColor.fromHex('#e2e8f0')),
        child: pw.Center(child: pw.Text(req.nombre.isNotEmpty ? req.nombre[0].toUpperCase() : '?', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18)))
      );
    }).toList();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        if (avatarWidgets.isNotEmpty) ...[
           pw.Row(children: avatarWidgets),
           pw.SizedBox(height: 8),
        ],
        pw.TableHelper.fromTextArray(
          headers: ['Datos del Solicitante', ''],
          data: [
            ['Nombres', names.join(', ')],
            ['Teléfonos', phones.join(', ')],
          ],
          border: pw.TableBorder.all(color: PdfColor.fromHex('#e2e8f0')),
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#0f172a')),
          headerDecoration: pw.BoxDecoration(color: PdfColor.fromHex('#f1f5f9')),
          cellPadding: const pw.EdgeInsets.all(6),
          columnWidths: {
            0: const pw.FixedColumnWidth(150),
            1: const pw.FlexColumnWidth(),
          },
        )
      ]
    );
  }

  static pw.Widget _buildDescription(Ticket ticket, pw.ImageProvider? attachmentImage) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Descripción del Ticket:', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#0f172a'))),
        pw.SizedBox(height: 6),
        pw.Text(
          ticket.descripcion.isEmpty ? 'Sin descripción.' : ticket.descripcion,
          style: pw.TextStyle(fontSize: 10, color: PdfColor.fromHex('#334155')),
        ),
        if (attachmentImage != null) ...[
          pw.SizedBox(height: 10),
          pw.Text('Evidencia Adjunta:', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#0f172a'))),
          pw.SizedBox(height: 6),
          pw.Container(
             width: 400,
             height: 200,
             decoration: pw.BoxDecoration(
               border: pw.Border.all(color: PdfColor.fromHex('#e2e8f0')),
               image: pw.DecorationImage(image: attachmentImage, fit: pw.BoxFit.contain)
             )
          )
        ]
      ],
    );
  }

  static pw.Widget _buildConversacion(List<RespuestaTicket> respuestas) {
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

    final List<List<String>> rows = respuestas.map((res) {
      final fecha = res.fechaCreacion != null 
          ? DateFormat('dd/MM/yyyy HH:mm:ss').format(res.fechaCreacion!)
          : 'N/A';
      final nombre = res.autorNombre;
      String msg = res.mensaje;
      if (res.archivo != null) {
        msg += '\n\n[📎 Archivo Adjunto]';
      }
      return ['$nombre\n$fecha', msg];
    }).toList();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Conversación y Resoluciones:', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#0f172a'))),
        pw.SizedBox(height: 8),
        pw.TableHelper.fromTextArray(
          headers: ['Usuario / Fecha', 'Mensaje'],
          data: rows,
          border: pw.TableBorder.all(color: PdfColor.fromHex('#e2e8f0')),
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#0f172a')),
          headerDecoration: pw.BoxDecoration(color: PdfColor.fromHex('#f1f5f9')),
          cellPadding: const pw.EdgeInsets.all(8),
          columnWidths: {
            0: const pw.FixedColumnWidth(120),
            1: const pw.FlexColumnWidth(),
          },
        ),
      ]
    );
  }

  static pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 40),
      child: pw.Column(
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.SizedBox(height: 60), // Mucho más espacio arriba para firmar
          pw.Container(
            width: 250,
            child: pw.Divider(color: PdfColor.fromHex('#000000'), thickness: 1),
          ),
          pw.SizedBox(height: 15), // Separación clara entre la línea y el texto
          pw.Text(
            'Firma de Jefe inmediato / supervisor',
            style: pw.TextStyle(
              fontSize: 12, 
              fontWeight: pw.FontWeight.bold, 
              color: PdfColor.fromHex('#334155')
            ),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 25),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.Text(
                'Página ${context.pageNumber} de ${context.pagesCount}',
                style: pw.TextStyle(fontSize: 8, color: PdfColor.fromHex('#94a3b8')),
              )
            ]
          )
        ]
      )
    );
  }
}
