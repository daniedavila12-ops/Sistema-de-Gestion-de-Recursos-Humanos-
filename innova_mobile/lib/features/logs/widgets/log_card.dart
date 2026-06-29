import 'package:flutter/material.dart';
import '../models/log_model.dart';
import 'package:intl/intl.dart';

class LogCard extends StatelessWidget {
  final LogSistema logData;

  const LogCard({super.key, required this.logData});

  Color _getAccionColor(String accion) {
    final acc = accion.toLowerCase();
    if (acc.contains('crea') || acc.contains('insert') || acc.contains('registr')) {
      return Colors.green;
    } else if (acc.contains('elimina') || acc.contains('delete') || acc.contains('borr') || acc.contains('error')) {
      return Colors.red;
    } else if (acc.contains('actualiza') || acc.contains('edit') || acc.contains('modifica')) {
      return Colors.blue;
    } else if (acc.contains('login') || acc.contains('acceso') || acc.contains('sesi')) {
      return Colors.purple;
    }
    return Colors.grey.shade700;
  }

  @override
  Widget build(BuildContext context) {
    final colorAccion = _getAccionColor(logData.accion);
    final fechaFormat = DateFormat('dd/MM/yyyy HH:mm:ss').format(logData.fechaCreacion);

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('#${logData.id}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                Text(fechaFormat, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
            const Divider(),
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.blue.shade100,
                  child: Text(
                    logData.usuarioNombre.isNotEmpty ? logData.usuarioNombre[0].toUpperCase() : 'U',
                    style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(logData.usuarioNombre, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                      Text(logData.usuarioCorreo, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    logData.modulo,
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorAccion.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: colorAccion.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    logData.accion.toUpperCase(),
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: colorAccion),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              logData.detalles,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'IP: ${logData.ipAddress}',
                style: const TextStyle(fontSize: 10, color: Colors.grey, fontFamily: 'monospace'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
