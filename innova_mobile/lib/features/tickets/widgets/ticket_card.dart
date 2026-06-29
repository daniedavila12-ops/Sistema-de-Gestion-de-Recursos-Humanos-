// CREADO POR: DANIEL INNOVA

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/ticket_model.dart';
import 'package:innova_mobile/core/constants/api_constants.dart';

class TicketCard extends StatelessWidget {
  final Ticket ticket;
  final VoidCallback onTap;

  const TicketCard({
    super.key,
    required this.ticket,
    required this.onTap,
  });

  String _formatId(int id) {
    return '#TKT-${id.toString().padLeft(3, '0')}';
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Desconocido';
    return DateFormat('dd MMM yyyy').format(date);
  }

  Color _getPrioridadColor(String prioridad) {
    switch (prioridad.toLowerCase()) {
      case 'urgente': return Colors.red;
      case 'alta': return Colors.orange;
      case 'baja': return Colors.green;
      default: return Colors.amber;
    }
  }

  Color _getEstadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'resuelto':
      case 'cerrado': return Colors.green;
      case 'abierto': return Colors.blue;
      case 'en progreso': return Colors.purple;
      default: return Colors.grey;
    }
  }

  Widget _buildBadge(String text, Color baseColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: baseColor.withValues(alpha: 0.1),
        border: Border.all(color: baseColor.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: baseColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildAvatar(String nombre, String? avatarUrl) {
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 12,
        backgroundImage: NetworkImage('${ApiConstants.baseUrl}$avatarUrl'),
      );
    }
    return CircleAvatar(
      radius: 12,
      backgroundColor: Colors.grey.shade200,
      child: Text(
        nombre.isNotEmpty ? nombre[0].toUpperCase() : '?',
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fila 1: Header
              Row(
                children: [
                  Text(_formatId(ticket.id), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(width: 8),
                  _buildBadge(ticket.prioridad, _getPrioridadColor(ticket.prioridad)),
                  const SizedBox(width: 4),
                  _buildBadge(ticket.estado, _getEstadoColor(ticket.estado)),
                  const Spacer(),
                  _buildAvatar(ticket.asignadoNombre, ticket.asignadoFoto),
                ],
              ),
              const SizedBox(height: 12),
              
              // Fila 2: Título y Descripción
              Text(
                ticket.tema,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                ticket.descripcion,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              
              // Fila 3: Footer (Creador, Categoría, Fecha, Respuestas)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      _buildAvatar(ticket.solicitanteNombre, ticket.empleadoFoto),
                      const SizedBox(width: 6),
                      SizedBox(
                        width: 70,
                        child: Text(
                          ticket.solicitanteNombre,
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.folder_outlined, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      SizedBox(
                        width: 70,
                        child: Text(
                          ticket.categoria,
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(ticket.fechaCreacion),
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
