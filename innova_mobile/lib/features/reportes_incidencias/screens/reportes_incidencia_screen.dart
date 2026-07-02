// CREADO POR: DANIEL INNOVA

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/reporte_incidencia_provider.dart';
import '../models/reporte_incidencia_model.dart';
import '../../../shared/widgets/innova_loading.dart';
import '../widgets/reportes_filter_drawer.dart';
import 'package:innova_mobile/core/constants/api_constants.dart';

class ReportesIncidenciaScreen extends ConsumerWidget {
  const ReportesIncidenciaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportesAsyncValue = ref.watch(filteredReportesIncidenciaProvider);
    final statusFilter = ref.watch(reporteStatusFilterProvider);
    final priorityFilter = ref.watch(reportePriorityFilterProvider);
    final sortOption = ref.watch(reporteSortOptionProvider);

    final estados = ['Todas', 'Pendiente', 'En Proceso', 'Resuelto', 'Cancelado'];

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Reportes de Incidencia'),
        elevation: 0,
        actions: [
          Builder(
            builder: (context) {
              return IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () {
                  Scaffold.of(context).openEndDrawer();
                },
              );
            }
          ),
        ],
      ),
      endDrawer: const ReportesFilterDrawer(),
      body: Column(
        children: [
          // Barra de búsqueda y filtros superiores
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Buscador
                TextField(
                  onChanged: (val) => ref.read(reporteSearchQueryProvider.notifier).state = val,
                  decoration: InputDecoration(
                    hintText: 'Buscador Reportes...',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Dropdowns
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: priorityFilter,
                            icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                            style: const TextStyle(fontSize: 12, color: Colors.black87),
                            onChanged: (val) {
                              if (val != null) ref.read(reportePriorityFilterProvider.notifier).state = val;
                            },
                            items: const [
                              DropdownMenuItem(value: 'todas', child: Text('Todas las prioridades')),
                              DropdownMenuItem(value: 'Urgente', child: Text('URGENTE')),
                              DropdownMenuItem(value: 'Alta', child: Text('ALTO')),
                              DropdownMenuItem(value: 'Media', child: Text('MEDIO')),
                              DropdownMenuItem(value: 'Baja', child: Text('BAJO')),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: sortOption,
                            icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                            style: const TextStyle(fontSize: 12, color: Colors.black87),
                            onChanged: (val) {
                              if (val != null) ref.read(reporteSortOptionProvider.notifier).state = val;
                            },
                            items: const [
                              DropdownMenuItem(value: 'reciente', child: Text('Más reciente')),
                              DropdownMenuItem(value: 'antiguo', child: Text('Más antiguo')),
                              DropdownMenuItem(value: 'prioridad', child: Text('Prioridad (Alta-Baja)')),
                              DropdownMenuItem(value: 'actualizado', child: Text('Actualizado')),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Filtros de Estado Horizontales
          Container(
            height: 50,
            color: Colors.white,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: estados.length,
              itemBuilder: (context, index) {
                final st = estados[index];
                final isSelected = st == statusFilter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(st, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                    selected: isSelected,
                    onSelected: (val) {
                      ref.read(reporteStatusFilterProvider.notifier).state = st;
                    },
                    backgroundColor: Colors.grey.shade100,
                    selectedColor: Colors.red.shade600,
                    showCheckmark: false,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: isSelected ? Colors.red.shade600 : Colors.grey.shade300)),
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Encabezado Historial de Reportes
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'HISTORIAL DE REPORTES',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: Colors.black87,
                    letterSpacing: 0.5,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.grey),
                  tooltip: 'Actualizar',
                  onPressed: () => ref.invalidate(reportesIncidenciaProvider),
                ),
              ],
            ),
          ),

          // Lista de Reportes
          Expanded(
            child: reportesAsyncValue.when(
              data: (reportes) {
                if (reportes.isEmpty) {
                  return const Center(child: Text('No se encontraron reportes con los filtros actuales.', style: TextStyle(color: Colors.grey)));
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(reportesIncidenciaProvider);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: reportes.length,
                    itemBuilder: (context, index) {
                      final reporte = reportes[index];
                      return _ReporteCard(reporte: reporte);
                    },
                  ),
                );
              },
              loading: () => const InnovaLoading(mensaje: 'Cargando reportes...'),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 60),
                    const SizedBox(height: 16),
                    Text('Ocurrió un error:\n$error', textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(reportesIncidenciaProvider),
                      child: const Text('Reintentar'),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.red.shade600,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('NUEVO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: () {
          context.push('/crear-reporte-incidencia').then((_) {
            ref.invalidate(reportesIncidenciaProvider);
          });
        },
      ),
    );
  }
}

class _ReporteCard extends StatelessWidget {
  final ReporteIncidencia reporte;

  const _ReporteCard({required this.reporte});

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return '${date.day.toString().padLeft(2,'0')}/${date.month.toString().padLeft(2,'0')}/${date.year} ${date.hour.toString().padLeft(2,'0')}:${date.minute.toString().padLeft(2,'0')}';
  }

  Color _getPriorityColor(String prioridad) {
    final p = prioridad.toUpperCase();
    if (p == 'URGENTE') return Colors.red.shade700;
    if (p == 'ALTA') return Colors.orange.shade600;
    if (p == 'BAJA') return Colors.green.shade600;
    return Colors.yellow.shade800; // Media
  }

  Color _getPriorityBgColor(String prioridad) {
    final p = prioridad.toUpperCase();
    if (p == 'URGENTE') return Colors.red.shade50;
    if (p == 'ALTA') return Colors.orange.shade50;
    if (p == 'BAJA') return Colors.green.shade50;
    return Colors.yellow.shade50; // Media
  }

  Color _getStatusColor(String estado) {
    final e = estado;
    if (e == 'En Proceso') return Colors.blue.shade700;
    if (e == 'Pendiente') return Colors.orange.shade700;
    if (e == 'Resuelto') return Colors.green.shade700;
    return Colors.grey.shade700;
  }

  Color _getStatusBgColor(String estado) {
    final e = estado;
    if (e == 'En Proceso') return Colors.blue.shade50;
    if (e == 'Pendiente') return Colors.orange.shade50;
    if (e == 'Resuelto') return Colors.green.shade50;
    return Colors.grey.shade50;
  }

  @override
  Widget build(BuildContext context) {
    final prioColor = _getPriorityColor(reporte.prioridad);
    final prioBg = _getPriorityBgColor(reporte.prioridad);
    final stColor = _getStatusColor(reporte.estado);
    final stBg = _getStatusBgColor(reporte.estado);
    final isUrgente = reporte.prioridad.toUpperCase() == 'URGENTE';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUrgente ? Colors.redAccent.withValues(alpha: 0.5) : Colors.grey.shade100,
          width: isUrgente ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            context.push('/reporte-incidencia-detalle', extra: reporte);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                CircleAvatar(
                  radius: 14,
                  backgroundColor: Colors.grey.shade100,
                  backgroundImage: reporte.asignadoUsuarioFoto != null ? NetworkImage('${ApiConstants.baseUrl}${reporte.asignadoUsuarioFoto}') : null,
                  onBackgroundImageError: reporte.asignadoUsuarioFoto != null ? (e, s) {} : null,
                  child: reporte.asignadoUsuarioFoto == null 
                    ? Text(reporte.asignadoUsuarioNombre?.isNotEmpty == true ? reporte.asignadoUsuarioNombre![0].toUpperCase() : '?', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)) 
                    : null,
                ),
                const SizedBox(width: 10),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('#INC-${reporte.id.toString().padLeft(3, '0')}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black45, fontSize: 10, fontFamily: 'monospace')),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                            decoration: BoxDecoration(color: prioBg, borderRadius: BorderRadius.circular(6)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 4, height: 4,
                                  decoration: BoxDecoration(color: prioColor, shape: BoxShape.circle),
                                ),
                                const SizedBox(width: 3),
                                Text((reporte.prioridad).toUpperCase(), style: TextStyle(color: prioColor, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 0.3)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                            decoration: BoxDecoration(color: stBg, borderRadius: BorderRadius.circular(6)),
                            child: Text((reporte.estado).toUpperCase(), style: TextStyle(color: stColor, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 0.3)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      
                      // Tema y Descripcion
                      Text(reporte.tema, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      RichText(
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
                          children: [
                            TextSpan(text: '${reporte.empleadoNombre ?? 'Desconocido'} ${reporte.empleadoApellido ?? ''}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            const TextSpan(text: ' · '),
                            TextSpan(text: reporte.descripcion),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Footer row
                      Row(
                        children: [
                          Expanded(child: _IconTextBadge(icon: Icons.folder_outlined, text: reporte.categoria)),
                          const SizedBox(width: 4),
                          Expanded(flex: 2, child: _IconTextBadge(icon: Icons.access_time, text: _formatDate(reporte.fechaCreacion))),
                          const SizedBox(width: 4),
                          _IconTextBadge(icon: Icons.chat_bubble_outline, text: '${reporte.respuestasCount ?? 0}'),
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.chevron_right, color: Colors.grey.shade300, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IconTextBadge extends StatelessWidget {
  final IconData icon;
  final String text;

  const _IconTextBadge({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 10, color: Colors.grey.shade400),
        const SizedBox(width: 3),
        Flexible(child: Text(text, style: TextStyle(fontSize: 9, color: Colors.grey.shade500, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}
