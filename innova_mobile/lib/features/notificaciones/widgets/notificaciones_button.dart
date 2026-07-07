import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/notificaciones_provider.dart';
import '../../tickets/providers/ticket_provider.dart';
import '../../reportes_incidencias/providers/reporte_incidencia_provider.dart';
import '../../empleados/providers/empleado_provider.dart';

class NotificacionesButton extends ConsumerWidget {
  const NotificacionesButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificacionesState = ref.watch(notificacionesProvider);

    return notificacionesState.when(
      data: (notificaciones) {
        final unreadCount = notificaciones.where((n) => n['leido'] == 0 || n['leido'] == false).length;

        return Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () => _mostrarNotificaciones(context, ref, notificaciones),
            ),
            if (unreadCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    unreadCount > 9 ? '9+' : unreadCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
      loading: () => const IconButton(icon: Icon(Icons.notifications_none), onPressed: null),
      error: (err, stack) => const IconButton(icon: Icon(Icons.notifications_none), onPressed: null),
    );
  }

  void _mostrarNotificaciones(BuildContext context, WidgetRef ref, List<dynamic> notificaciones) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Notificaciones', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    if (notificaciones.any((n) => n['leido'] == 0 || n['leido'] == false))
                      TextButton(
                        onPressed: () {
                          ref.read(marcarNotificacionesLeidasProvider)();
                          Navigator.pop(context);
                        },
                        child: const Text('Marcar todas como leídas'),
                      ),
                  ],
                ),
              ),
              const Divider(),
              if (notificaciones.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text('No tienes notificaciones.', style: TextStyle(color: Colors.grey)),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: notificaciones.length,
                    itemBuilder: (context, index) {
                      final n = notificaciones[index];
                      final isUnread = n['leido'] == 0 || n['leido'] == false;
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isUnread ? Colors.blue.shade100 : Colors.grey.shade100,
                          child: Icon(Icons.info_outline, color: isUnread ? Colors.blue : Colors.grey),
                        ),
                        title: Text(n['titulo'] ?? 'Notificación', style: TextStyle(fontWeight: isUnread ? FontWeight.bold : FontWeight.normal)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(n['mensaje'] ?? ''),
                            const SizedBox(height: 4),
                            Text(n['tiempo'] ?? '', style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
                          ],
                        ),
                        tileColor: isUnread ? Colors.blue.withValues(alpha: 0.05) : null,
                        onTap: () async {
                          // Marcar como leída
                          ref.read(marcarNotificacionesLeidasProvider)();
                          Navigator.pop(context); // Cerrar el modal
                          
                          // Redirección
                          final titulo = (n['titulo'] ?? '').toString().toLowerCase();
                          final mensaje = (n['mensaje'] ?? '').toString();
                          
                          final idMatch = RegExp(r'(?:#|ID:\s*)(\d+)', caseSensitive: false).firstMatch(mensaje);
                          int? entityId;
                          if (idMatch != null) {
                            entityId = int.tryParse(idMatch.group(1)!);
                          }

                          if (titulo.contains('ticket')) {
                            if (entityId != null) {
                              try {
                                final ticket = await ref.read(ticketDetailProvider(entityId).future);
                                if (context.mounted) context.push('/ticket', extra: ticket);
                              } catch (e) {
                                if (context.mounted) context.push('/tickets');
                              }
                            } else {
                              if (context.mounted) context.push('/tickets');
                            }
                          } else if (titulo.contains('incidente') || titulo.contains('reporte')) {
                            if (entityId != null) {
                              try {
                                final reporte = await ref.read(reporteIncidenciaDetailProvider(entityId).future);
                                if (context.mounted) context.push('/reporte-incidencia-detalle', extra: reporte);
                              } catch (e) {
                                if (context.mounted) context.push('/reportes-incidencias');
                              }
                            } else {
                              if (context.mounted) context.push('/reportes-incidencias');
                            }
                          } else if (titulo.contains('vacacion') || titulo.contains('vacaciones')) {
                            if (entityId != null) {
                              try {
                                final empleados = await ref.read(empleadosProvider.future);
                                final empleado = empleados.firstWhere((e) => e.id == entityId);
                                if (context.mounted) {
                                  context.push('/empleado', extra: {
                                    'empleado': empleado,
                                    'initialTabIndex': 2,
                                  });
                                }
                              } catch (e) {
                                if (context.mounted) context.push('/empleados');
                              }
                            } else {
                              if (context.mounted) context.push('/empleados');
                            }
                          } else if (titulo.contains('empleado inactivo')) {
                            if (context.mounted) context.push('/empleados', extra: 'inactivos');
                          } else if (titulo.contains('empleado') || titulo.contains('cumpleaños') || titulo.contains('contrato')) {
                            if (context.mounted) context.push('/empleados');
                          } else if (titulo.contains('departamento')) {
                            if (context.mounted) context.push('/departamentos');
                          }
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    ).whenComplete(() {
      // Opcional: Marcar como leídas al cerrar si se desea.
      // ref.read(marcarNotificacionesLeidasProvider)();
    });
  }
}
