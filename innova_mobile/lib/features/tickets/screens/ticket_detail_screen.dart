// CREADO POR: DANIEL INNOVA

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ticket_model.dart';
import '../providers/ticket_provider.dart';
import '../../auth/providers/auth_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/pdf_ticket_generator.dart';
import 'package:innova_mobile/core/constants/api_constants.dart';
import '../../empleados/models/empleado_model.dart';
import '../../empleados/providers/empleado_provider.dart';

class TicketDetailScreen extends ConsumerStatefulWidget {
  final Ticket ticket;

  const TicketDetailScreen({super.key, required this.ticket});

  @override
  ConsumerState<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends ConsumerState<TicketDetailScreen> {
  final TextEditingController _respuestaController = TextEditingController();
  bool _isSending = false;

  final List<String> availableStatuses = ['Abierto', 'En Progreso', 'Pendiente', 'Resuelto', 'Cerrado'];

  @override
  void dispose() {
    _respuestaController.dispose();
    super.dispose();
  }

  void _enviarRespuesta() async {
    if (_respuestaController.text.trim().isEmpty) return;
    setState(() => _isSending = true);
    try {
      final repo = ref.read(ticketRepositoryProvider);
      final usuarioId = ref.read(authProvider).user?.id;
      await repo.addRespuesta(
        ticketId: widget.ticket.id, 
        mensaje: _respuestaController.text.trim(),
        usuarioId: usuarioId,
      );
      _respuestaController.clear();
      ref.invalidate(ticketRespuestasProvider(widget.ticket.id));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Respuesta enviada con éxito')));
    } catch(e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al enviar respuesta: $e')));
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _updateStatus(String nuevoEstado) async {
    try {
      await ref.read(ticketRepositoryProvider).updateEstado(widget.ticket.id, nuevoEstado);
      ref.invalidate(ticketDetailProvider(widget.ticket.id));
      ref.invalidate(ticketsProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Estado actualizado')));
    } catch(e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al actualizar estado: $e')));
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'urgente': return Colors.red[700]!;
      case 'alta': return Colors.red[400]!;
      case 'media': return Colors.orange[700]!;
      case 'baja': return Colors.green[600]!;
      default: return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'abierto': return Colors.blue[600]!;
      case 'en progreso': return Colors.purple[600]!;
      case 'pendiente': return Colors.orange[600]!;
      case 'resuelto': return Colors.green[600]!;
      case 'cerrado': return Colors.grey[600]!;
      default: return Colors.grey;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/D';
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _makePhoneCall(String phoneNumber) async {
    // Remove all non-numeric characters for the tel URI except '+'
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleanPhone.isEmpty) return;
    
    final Uri launchUri = Uri(scheme: 'tel', path: cleanPhone);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se pudo abrir el marcador de teléfono')));
    }
  }

  void _openWhatsApp(String phoneNumber) async {
    // Clean phone number (WhatsApp needs country code, we assume +504 or let the user provide it)
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleanPhone.isEmpty) return;
    
    final Uri launchUri = Uri.parse('https://wa.me/$cleanPhone');
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se pudo abrir WhatsApp')));
    }
  }

  List<Empleado> _getRequesters(Ticket ticket, List<Empleado>? allEmpleados) {
    if (allEmpleados == null || allEmpleados.isEmpty) {
       return [
         Empleado(id: 0, nombre: ticket.solicitanteNombre, apellido: '', estado: 1, foto: ticket.empleadoFoto, telefono: ticket.empleadoTelefono)
       ];
    }
    
    if (ticket.identidad != null && ticket.identidad!.contains(',')) {
       final ids = ticket.identidad!.split(',').map((e) => e.trim()).toList();
       final found = allEmpleados.where((e) => e.identidad != null && ids.contains(e.identidad)).toList();
       if (found.isNotEmpty) return found;
    }
    
    return [
         Empleado(id: 0, nombre: ticket.solicitanteNombre, apellido: '', estado: 1, foto: ticket.empleadoFoto, telefono: ticket.empleadoTelefono)
    ];
  }

  Future<void> _generarPDFTicket(List<Empleado> requesters) async {
    try {
      final respuestasAsync = ref.read(ticketRespuestasProvider(widget.ticket.id));
      final respuestas = respuestasAsync.value ?? [];
      await PdfTicketGenerator.generarPdfTicket(widget.ticket, respuestas, requesters);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al generar PDF: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final ticketAsync = ref.watch(ticketDetailProvider(widget.ticket.id));
    final respuestasAsync = ref.watch(ticketRespuestasProvider(widget.ticket.id));
    final empleadosAsync = ref.watch(empleadosProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Ticket #${widget.ticket.id}'),
        centerTitle: true,
      ),
      body: ticketAsync.when(
        data: (fullTicket) {
          final requesters = _getRequesters(fullTicket, empleadosAsync.value);
          
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(ticketDetailProvider(widget.ticket.id));
              ref.invalidate(ticketRespuestasProvider(widget.ticket.id));
              ref.invalidate(empleadosProvider);
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMainTicketCard(fullTicket, requesters),
                  const SizedBox(height: 16),
                  _buildDetailsCard(fullTicket),
                  const SizedBox(height: 16),
                  _buildStatusChangeCard(fullTicket),
                  const SizedBox(height: 16),
                  _buildRequesterCard(fullTicket, requesters),
                  const SizedBox(height: 16),
                  _buildRespuestasSection(respuestasAsync),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildMainTicketCard(Ticket ticket, List<Empleado> requesters) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey[100]!)),
            ),
            child: Row(
              children: [
                Text(
                  '#${ticket.id}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(ticket.prioridad).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _getPriorityColor(ticket.prioridad).withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    ticket.prioridad,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _getPriorityColor(ticket.prioridad),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(ticket.estado).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _getStatusColor(ticket.estado).withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    ticket.estado,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(ticket.estado),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ticket.tema,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.picture_as_pdf, size: 16),
                    label: const Text('CREAR PDF REPORTE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade800,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () => _generarPDFTicket(requesters),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.grey[300],
                      backgroundImage: requesters.first.foto != null 
                        ? NetworkImage('${ApiConstants.baseUrl}${requesters.first.foto}') 
                        : null,
                      child: requesters.first.foto == null 
                        ? Text(requesters.first.nombre.isNotEmpty ? requesters.first.nombre[0].toUpperCase() : '?')
                        : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${requesters.first.nombre} ${requesters.first.apellido}'.trim() + (requesters.length > 1 ? ' y otros' : ''), style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(_formatDate(ticket.fechaCreacion), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Text(
                    ticket.descripcion,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ),
                if (ticket.archivo != null) ...[
                  const SizedBox(height: 16),
                  Builder(
                    builder: (context) {
                      final url = ticket.archivo!.toLowerCase();
                      final isImage = url.endsWith('.png') || url.endsWith('.jpg') || url.endsWith('.jpeg') || url.endsWith('.gif') || url.endsWith('.webp');
                      
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey[50],
                        ),
                        child: isImage
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Evidencia Adjunta:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    '${ApiConstants.baseUrl}${ticket.archivo}',
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                const Icon(Icons.attach_file, color: Colors.purple),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(ticket.archivo!.split('/').last, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                      const Text('Documento Adjunto', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                      );
                    }
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard(Ticket ticket) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('DETALLES TÉCNICOS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
          const Divider(),
          _detailRow('Categoría', ticket.categoria),
          _detailRow('Prioridad', ticket.prioridad),
          _detailRow('Creación', _formatDate(ticket.fechaCreacion)),
          _detailRow('Última act.', _formatDate(ticket.updatedAt)),
          _detailRow('Asignado a', ticket.asignadoNombre),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildStatusChangeCard(Ticket ticket) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('CAMBIAR ESTADO', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: availableStatuses.contains(ticket.estado) ? ticket.estado : availableStatuses.first,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            items: availableStatuses.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            onChanged: (val) {
              if (val != null && val != ticket.estado) {
                _updateStatus(val);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRequesterCard(Ticket ticket, List<Empleado> requesters) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('INFORMACIÓN DEL SOLICITANTE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
          const Divider(),
          ...requesters.map((req) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.grey[300],
                    backgroundImage: req.foto != null 
                      ? NetworkImage('${ApiConstants.baseUrl}${req.foto}') 
                      : null,
                    child: req.foto == null 
                      ? Text(req.nombre.isNotEmpty ? req.nombre[0].toUpperCase() : '?')
                      : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${req.nombre} ${req.apellido}'.trim(), style: const TextStyle(fontWeight: FontWeight.bold)),
                        Row(
                          children: [
                            const Icon(Icons.phone, size: 12, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(req.telefono ?? 'N/D', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (req.telefono != null && req.telefono!.isNotEmpty) ...[
                    IconButton(
                      icon: const Icon(Icons.phone, color: Colors.green),
                      tooltip: 'Llamar',
                      onPressed: () => _makePhoneCall(req.telefono!),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chat, color: Colors.teal),
                      tooltip: 'WhatsApp',
                      onPressed: () => _openWhatsApp(req.telefono!),
                    ),
                  ]
                ],
              ),
            );
          }),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)),
                  child: Column(
                    children: [
                      const Text('Total tickets', style: TextStyle(fontSize: 10, color: Colors.blue)),
                      Text('${ticket.ticketsTotales ?? 0}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(8)),
                  child: Column(
                    children: [
                      const Text('Resueltos', style: TextStyle(fontSize: 10, color: Colors.green)),
                      Text('${ticket.ticketsResueltos ?? 0}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                    ],
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildRespuestasSection(AsyncValue<List<RespuestaTicket>> respuestasAsync) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              border: Border(bottom: BorderSide(color: Colors.grey[100]!)),
            ),
            child: const Text('Respuestas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          respuestasAsync.when(
            data: (respuestas) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (respuestas.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(child: Text('No hay respuestas en este ticket.', style: TextStyle(color: Colors.grey))),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: respuestas.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final r = respuestas[index];
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: Colors.grey[300],
                                backgroundImage: r.autorFoto != null 
                                  ? NetworkImage('${ApiConstants.baseUrl}${r.autorFoto}') 
                                  : null,
                                child: r.autorFoto == null 
                                  ? Text(r.autorNombre.isNotEmpty ? r.autorNombre[0].toUpperCase() : '?', style: const TextStyle(fontSize: 12))
                                  : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    borderRadius: const BorderRadius.only(
                                      topRight: Radius.circular(12),
                                      bottomLeft: Radius.circular(12),
                                      bottomRight: Radius.circular(12),
                                    ),
                                    border: Border.all(color: Colors.grey[200]!),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(r.autorNombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                          Text(_formatDate(r.fechaCreacion), style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(r.mensaje, style: const TextStyle(fontSize: 14)),
                                      if (r.archivo != null) ...[
                                        const SizedBox(height: 8),
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            border: Border.all(color: Colors.grey[300]!),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.attachment, size: 14, color: Colors.purple),
                                              const SizedBox(width: 4),
                                              Text(
                                                r.archivo!.split('/').last,
                                                style: const TextStyle(color: Colors.purple, fontSize: 12, fontWeight: FontWeight.bold),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        )
                                      ]
                                    ],
                                  ),
                                ),
                              )
                            ],
                          );
                        },
                      ),
                    const Divider(height: 32),
                    const Text('Añadir una respuesta', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _respuestaController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Escribe tu respuesta aquí...',
                        hintStyle: const TextStyle(fontSize: 14),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 2,
                        ),
                        onPressed: _isSending ? null : _enviarRespuesta,
                        child: _isSending
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('Enviar Respuesta', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    )
                  ],
                ),
              );
            },
            loading: () => const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator())),
            error: (e, s) => Padding(padding: const EdgeInsets.all(20), child: Text('Error al cargar respuestas: $e')),
          ),
        ],
      ),
    );
  }
}
