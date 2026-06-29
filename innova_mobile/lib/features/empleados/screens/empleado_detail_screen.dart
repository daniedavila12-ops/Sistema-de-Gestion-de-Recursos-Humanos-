// CREADO POR: DANIEL INNOVA

import 'package:flutter/material.dart';
import '../models/empleado_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'contrato_provider.dart';
import 'vacaciones_empleado_provider.dart';
import 'package:file_picker/file_picker.dart';
import '../models/falta_model.dart';
import 'faltas_empleado_provider.dart';
import '../models/nota_model.dart';
import 'notas_empleado_provider.dart';
import '../models/documento_empleado_model.dart';
import 'documentos_empleado_provider.dart';
import 'package:innova_mobile/core/constants/api_constants.dart';
 
class EmpleadoDetailScreen extends StatefulWidget {
  final Empleado empleado;

  const EmpleadoDetailScreen({super.key, required this.empleado});

  @override
  State<EmpleadoDetailScreen> createState() => _EmpleadoDetailScreenState();
}

class _EmpleadoDetailScreenState extends State<EmpleadoDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _filtroPeriodoHistorial = 'Todos';

  @override
  void initState() {
    super.initState();
    // Se crean 6 tabs para las diferentes secciones del perfil del empleado
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final empleado = widget.empleado;

    return Scaffold(
      appBar: AppBar(
        title: Text(empleado.nombreCompleto),
        actions: [
          Consumer(
            builder: (context, ref, child) {
              return PopupMenuButton<String>(
                onSelected: (value) => _handleMenuSelection(context, ref, value, empleado),
                itemBuilder: (BuildContext context) {
                  final isActivo = empleado.estado == 1;
                  return <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      enabled: false,
                      child: Text('PERFIL', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54, fontSize: 12)),
                    ),
                    const PopupMenuItem<String>(
                      value: 'editar',
                      child: ListTile(leading: Icon(Icons.edit_outlined), title: Text('Editar empleado')),
                    ),
                    const PopupMenuItem<String>(
                      value: 'contacto',
                      child: ListTile(leading: Icon(Icons.person_add_alt_1_outlined), title: Text('Registrar contacto')),
                    ),
                    PopupMenuItem<String>(
                      value: 'estado',
                      child: ListTile(
                        leading: Icon(
                          isActivo ? Icons.do_not_disturb_on_outlined : Icons.check_circle_outline,
                          color: isActivo ? Colors.orange.shade700 : Colors.green.shade700,
                        ),
                        title: Text(isActivo ? 'Desactivar' : 'Activar'),
                      ),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem<String>(
                      enabled: false,
                      child: Text('EXPEDIENTE', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54, fontSize: 12)),
                    ),
                    const PopupMenuItem<String>(
                      value: 'contrato',
                      child: ListTile(leading: Icon(Icons.description_outlined), title: Text('Registrar contrato')),
                    ),
                    const PopupMenuItem<String>(
                      value: 'falta',
                      child: ListTile(leading: Icon(Icons.event_busy_outlined), title: Text('Registrar falta')),
                    ),
                    const PopupMenuItem<String>(
                      value: 'nota',
                      child: ListTile(leading: Icon(Icons.note_add_outlined), title: Text('Registrar nota')),
                    ),
                  ];
                },
                icon: const Icon(Icons.more_vert_outlined),
                tooltip: 'Opciones',
              );
            }
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.person_outline), text: 'General'),
            Tab(icon: Icon(Icons.description_outlined), text: 'Contratos'),
            Tab(icon: Icon(Icons.beach_access_outlined), text: 'Vacaciones'),
            Tab(icon: Icon(Icons.event_busy_outlined), text: 'Faltas'),
            Tab(icon: Icon(Icons.note_alt_outlined), text: 'Notas'),
            Tab(icon: Icon(Icons.folder_open_outlined), text: 'Documentos'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildInformacionGeneralTab(empleado),
          _buildContratosTab(empleado),
          _buildVacacionesTab(empleado),
          _buildFaltasTab(empleado),
          _buildNotasTab(empleado),
          _buildDocumentosTab(empleado),
        ],
      ),
    );
  }

  // Widget para la pestaña de Información General
  Widget _buildInformacionGeneralTab(Empleado empleado) {
    final textTheme = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 45,
                  backgroundColor: Theme.of(context).primaryColor.withAlpha(26),
                  backgroundImage: empleado.foto != null
                      ? NetworkImage('${ApiConstants.baseUrl}${empleado.foto}')
                      : null,
                  child: empleado.foto == null
                      ? Text(
                          empleado.nombre.isNotEmpty
                              ? empleado.nombre[0].toUpperCase()
                              : 'E',
                          style: textTheme.displaySmall
                              ?.copyWith(color: Theme.of(context).primaryColor),
                        )
                      : null,
                ),
                const SizedBox(height: 16),
                Text(empleado.nombreCompleto,
                    style: textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center),
                const SizedBox(height: 4),
                Text(empleado.cargo ?? 'Puesto no especificado',
                    style: textTheme.titleMedium?.copyWith(color: Colors.black54)),
                const SizedBox(height: 12),
                Chip(
                  avatar: Icon(
                    empleado.estado == 1
                        ? Icons.check_circle_outline
                        : Icons.highlight_off_outlined,
                    color: empleado.estado == 1
                        ? Colors.green.shade800
                        : Colors.red.shade800,
                    size: 18,
                  ),
                  label: Text(empleado.estado == 1 ? 'Activo' : 'Inactivo'),
                  backgroundColor: empleado.estado == 1
                      ? Colors.green.shade50
                      : Colors.red.shade50,
                  labelStyle: TextStyle(
                      color: empleado.estado == 1
                          ? Colors.green.shade800
                          : Colors.red.shade800,
                      fontWeight: FontWeight.bold),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        _buildInfoCard('Información Personal', [
          _buildInfoTile(Icons.badge_outlined, 'No. Identidad',
              empleado.identidad ?? 'No disponible'),
          _buildInfoTile(Icons.person_pin_outlined, 'Código Empleado',
              empleado.codigoEmpleado ?? 'No disponible'),
        ]),
        const SizedBox(height: 16),
        _buildInfoCard('Información de Contacto', [
          _buildInfoTile(Icons.email_outlined, 'Correo',
              empleado.correo ?? 'No disponible'),
          _buildInfoTile(
            Icons.phone_outlined, 
            'Teléfono',
            empleado.telefono ?? 'No disponible',
            trailing: empleado.telefono?.isNotEmpty == true ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.call, color: Colors.blue),
                  onPressed: () async {
                    final url = Uri.parse('tel:${empleado.telefono}');
                    if (await canLaunchUrl(url)) await launchUrl(url);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.chat_bubble_outline, color: Colors.green),
                  onPressed: () async {
                    final phone = empleado.telefono!.replaceAll(RegExp(r'[^\d+]'), '');
                    final url = Uri.parse('https://wa.me/$phone');
                    if (await canLaunchUrl(url)) await launchUrl(url, mode: LaunchMode.externalApplication);
                  },
                ),
              ],
            ) : null,
          ),
          _buildInfoTile(Icons.location_on_outlined, 'Dirección',
              empleado.direccion ?? 'No disponible'),
        ]),
        const SizedBox(height: 16),
        _buildInfoCard('Información Laboral', [
          _buildInfoTile(Icons.business_center_outlined, 'Tipo de Contrato',
              empleado.tipoContrato ?? 'No disponible'),
          _buildInfoTile(
              Icons.calendar_today_outlined,
              'Fecha de Ingreso',
              empleado.fechaInicio?.toLocal().toString().split(' ')[0] ??
                  'No disponible'),
          _buildInfoTile(Icons.location_city_outlined, 'Ubicación / Piso',
              empleado.ubicacion?.isNotEmpty == true ? empleado.ubicacion! : 'No disponible'),
        ]),
        const SizedBox(height: 16),
        _buildInfoCard('Contacto de Emergencia 1', [
          _buildInfoTile(Icons.person_outline, 'Nombre',
              empleado.emergenciaNombre?.isNotEmpty == true ? empleado.emergenciaNombre! : 'No disponible'),
          _buildInfoTile(Icons.family_restroom_outlined, 'Parentesco',
              empleado.emergenciaParentesco?.isNotEmpty == true ? empleado.emergenciaParentesco! : 'No disponible'),
          _buildInfoTile(
            Icons.phone_outlined, 
            'Teléfono',
            empleado.emergenciaTelefono?.isNotEmpty == true ? empleado.emergenciaTelefono! : 'No disponible',
            trailing: empleado.emergenciaTelefono?.isNotEmpty == true ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.call, color: Colors.blue),
                  onPressed: () async {
                    final url = Uri.parse('tel:${empleado.emergenciaTelefono}');
                    if (await canLaunchUrl(url)) await launchUrl(url);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.chat_bubble_outline, color: Colors.green),
                  onPressed: () async {
                    final phone = empleado.emergenciaTelefono!.replaceAll(RegExp(r'[^\d+]'), '');
                    final url = Uri.parse('https://wa.me/$phone');
                    if (await canLaunchUrl(url)) await launchUrl(url, mode: LaunchMode.externalApplication);
                  },
                ),
              ],
            ) : null,
          ),
        ]),
        if (empleado.emergenciaNombre2?.isNotEmpty == true) ...[
          const SizedBox(height: 16),
          _buildInfoCard('Contacto de Emergencia 2', [
            _buildInfoTile(Icons.person_outline, 'Nombre',
                empleado.emergenciaNombre2!),
            _buildInfoTile(Icons.family_restroom_outlined, 'Parentesco',
                empleado.emergenciaParentesco2?.isNotEmpty == true ? empleado.emergenciaParentesco2! : 'No disponible'),
            _buildInfoTile(
              Icons.phone_outlined, 
              'Teléfono',
              empleado.emergenciaTelefono2?.isNotEmpty == true ? empleado.emergenciaTelefono2! : 'No disponible',
              trailing: empleado.emergenciaTelefono2?.isNotEmpty == true ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.call, color: Colors.blue),
                    onPressed: () async {
                      final url = Uri.parse('tel:${empleado.emergenciaTelefono2}');
                      if (await canLaunchUrl(url)) await launchUrl(url);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.chat_bubble_outline, color: Colors.green),
                    onPressed: () async {
                      final phone = empleado.emergenciaTelefono2!.replaceAll(RegExp(r'[^\d+]'), '');
                      final url = Uri.parse('https://wa.me/$phone');
                      if (await canLaunchUrl(url)) await launchUrl(url, mode: LaunchMode.externalApplication);
                    },
                  ),
                ],
              ) : null,
            ),
          ]),
        ],
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  // Widget para la pestaña de Historial de Contratos
  Widget _buildContratosTab(Empleado empleado) {
    return Consumer(
      builder: (context, ref, child) {
        final contratosAsync = ref.watch(contratosProvider(empleado.id));
        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          body: contratosAsync.when(
            data: (contratos) {
              if (contratos.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history_toggle_off, size: 60, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      const Text('Sin historial de contratos', style: TextStyle(fontSize: 18, color: Colors.grey)),
                      const SizedBox(height: 8),
                      const Text('Registre el primer contrato para este empleado.', style: TextStyle(color: Colors.grey), textAlign: TextAlign.center),
                    ],
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: () => ref.refresh(contratosProvider(empleado.id).future),
                child: ListView.builder(
                  padding: const EdgeInsets.all(12.0),
                  itemCount: contratos.length,
                  itemBuilder: (context, index) {
                    final contrato = contratos[index];
                    final bool isActivo = contrato.estado == 'Activo';
                    return Card(
                      elevation: 1,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: isActivo ? Colors.green.shade200 : Colors.grey.shade200),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Fila de Título y Estado
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(child: Text(contrato.tipoContrato, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                                Chip(
                                  label: Text(contrato.estado),
                                  backgroundColor: isActivo ? Colors.green.shade50 : Colors.grey.shade100,
                                  labelStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isActivo ? Colors.green.shade800 : Colors.grey.shade700),
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  visualDensity: VisualDensity.compact,
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            // Fila de Fechas
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(child: _buildDetailColumn('Fecha Inicio', _formatDate(contrato.fechaInicio))),
                                Expanded(child: _buildDetailColumn('Fecha Fin', contrato.fechaFin != null ? _formatDate(contrato.fechaFin!) : 'N/A', align: CrossAxisAlignment.center)),
                                Expanded(child: _buildDetailColumn('Fecha Salida', contrato.fechaSalida != null ? _formatDate(contrato.fechaSalida!) : 'N/A', align: CrossAxisAlignment.end)),
                              ],
                            ),
                            // Observaciones y Archivo
                            if (contrato.notas?.isNotEmpty == true) ...[
                              const SizedBox(height: 16),
                              _buildDetailColumn('Observación', contrato.notas!),
                            ],
                            if (contrato.archivo?.isNotEmpty == true) ...[
                              const SizedBox(height: 16),
                              TextButton.icon(
                                onPressed: () async {
                                  final url = Uri.parse('${ApiConstants.baseUrl}${contrato.archivo}');
                                  if (await canLaunchUrl(url)) {
                                    await launchUrl(url, mode: LaunchMode.externalApplication);
                                  } else {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('No se pudo abrir el documento.')),
                                      );
                                    }
                                  }
                                },
                                icon: const Icon(Icons.attach_file, size: 16),
                                label: const Text('Ver Documento Adjunto'),
                              )
                            ]
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error al cargar contratos: $err')),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => context.push('/nuevo-contrato', extra: empleado.id),
            icon: const Icon(Icons.add),
            label: const Text('Nuevo Contrato'),
            tooltip: 'Registrar un nuevo contrato',
          ),
        );
      },
    );
  }

  // Widget reutilizable para las tarjetas de información
  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
          ),
          ...children,
        ],
      ),
    );
  }

  // Widget reutilizable para cada fila de información
  Widget _buildInfoTile(IconData icon, String title, String subtitle, {VoidCallback? onTap, Widget? trailing}) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(title,
          style: const TextStyle(
              fontWeight: FontWeight.w500, color: Colors.black54)),
      subtitle: Text(subtitle,
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(fontWeight: FontWeight.bold, color: Colors.black87)),
      trailing: trailing,
      onTap: onTap,
    );
  }

  Widget _buildDetailColumn(String title, String value, {CrossAxisAlignment? align, Color? color}) {
    return Column(
      crossAxisAlignment: align ?? CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.w500)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color ?? Colors.black)),
      ],
    );
  }

  // Widget para la pestaña de Historial de Vacaciones
  Widget _buildVacacionesTab(Empleado empleado) {
    return Consumer(
      builder: (context, ref, child) {
        final vacacionesAsync = ref.watch(vacacionesEmpleadoProvider(empleado.id));
        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          body: vacacionesAsync.when(
            data: (vacacionesData) {
              if (vacacionesData.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history_toggle_off, size: 60, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      const Text('Sin historial de vacaciones', style: TextStyle(fontSize: 18, color: Colors.grey)),
                      const SizedBox(height: 8),
                      const Text('Registre las vacaciones para este empleado.', style: TextStyle(color: Colors.grey), textAlign: TextAlign.center),
                    ],
                  ),
                );
              }

              // Obtener periodos únicos
              final periodosSet = vacacionesData.map((v) => v.periodo).toSet();
              final periodosList = periodosSet.toList()..sort((a, b) => b.compareTo(a));

              // Filtrar vacaciones por periodo seleccionado
              final opcionesFiltro = ['Todos', ...periodosList];
              final currentFiltro = opcionesFiltro.contains(_filtroPeriodoHistorial) ? _filtroPeriodoHistorial : 'Todos';

              final vacacionesFiltradas = currentFiltro == 'Todos'
                  ? vacacionesData
                  : vacacionesData.where((v) => v.periodo == currentFiltro).toList();

              return RefreshIndicator(
                onRefresh: () => ref.refresh(vacacionesEmpleadoProvider(empleado.id).future),
                child: Column(
                  children: [
                    // Filtro de Periodo
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      color: Colors.white,
                      child: Row(
                        children: [
                          const Icon(Icons.filter_list, size: 20, color: Colors.grey),
                          const SizedBox(width: 8),
                          const Text('Filtrar por Periodo:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black54)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: currentFiltro,
                                items: [
                                  const DropdownMenuItem(value: 'Todos', child: Text('Todos')),
                                  ...periodosList.map((p) => DropdownMenuItem(value: p, child: Text(p))),
                                ],
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      _filtroPeriodoHistorial = value;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    if (vacacionesFiltradas.isEmpty)
                      const Expanded(
                        child: Center(
                          child: Text('No hay registros para el periodo seleccionado.', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                        ),
                      )
                    else
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(12.0),
                          itemCount: vacacionesFiltradas.length,
                          itemBuilder: (context, index) {
                            final vacacion = vacacionesFiltradas[index];
                            final isAdelantadas = vacacion.tipoSolicitud == 'Adelantadas';
                            
                            String formatDateStr(String? dateStr) {
                              if (dateStr == null || dateStr.isEmpty) return 'N/A';
                              try {
                                final d = DateTime.parse(dateStr);
                                return _formatDate(d);
                              } catch (e) {
                                return 'N/A';
                              }
                            }

                            return Card(
                              elevation: 1,
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: Colors.blue.shade100),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Fila de Título (Periodo y Tipo) y Botones
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Wrap(
                                            spacing: 8,
                                            runSpacing: 4,
                                            children: [
                                              Chip(
                                                label: Text('Periodo: ${vacacion.periodo}'),
                                                backgroundColor: Colors.blue.shade50,
                                                labelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blue.shade800),
                                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                                visualDensity: VisualDensity.compact,
                                              ),
                                              Chip(
                                                label: Text(vacacion.tipoSolicitud),
                                                backgroundColor: Colors.grey.shade100,
                                                labelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                                visualDensity: VisualDensity.compact,
                                              ),
                                              if (vacacion.tipoPermiso != null && vacacion.tipoPermiso!.isNotEmpty)
                                                Chip(
                                                  label: Text(vacacion.tipoPermiso!),
                                                  backgroundColor: Colors.purple.shade50,
                                                  labelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.purple.shade800),
                                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                                  visualDensity: VisualDensity.compact,
                                                ),
                                            ],
                                          ),
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                                              tooltip: 'Editar Vacación',
                                              onPressed: () => _showVacacionDialog(context, ref, empleado.id, vacacionToEdit: vacacion),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                                              tooltip: 'Eliminar Vacación',
                                              onPressed: () => _confirmarEliminarVacacion(context, ref, vacacion.id, empleado.id),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    // Auditoría (Creado/Modificado)
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.grey.shade200),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Creado por: ${vacacion.creadoPorNombre ?? "Admin"} | Fecha: ${formatDateStr(vacacion.fechaCreacion)}', style: const TextStyle(fontSize: 10, color: Colors.black54)),
                                          if (vacacion.fechaModificacion != null && vacacion.fechaModificacion != vacacion.fechaCreacion)
                                            Text('Modificado: ${vacacion.modificadoPorNombre ?? "s/d"} | Fecha: ${formatDateStr(vacacion.fechaModificacion)}', style: const TextStyle(fontSize: 10, color: Colors.black54)),
                                        ],
                                      ),
                                    ),
                                    const Divider(height: 24),
                                    // Detalles de Días
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(child: _buildDetailColumn('Disfrutados', (isAdelantadas ? 0 : vacacion.diasVacaciones).toStringAsFixed(0), color: Colors.blue)),
                                        Expanded(child: _buildDetailColumn('Adelantados', (isAdelantadas ? vacacion.diasVacaciones : 0).toStringAsFixed(0), align: CrossAxisAlignment.center, color: Colors.red)),
                                        Expanded(child: _buildDetailColumn('Pagados', vacacion.diasPagados.toStringAsFixed(0), align: CrossAxisAlignment.center, color: Colors.green)),
                                        Expanded(child: _buildDetailColumn('Pendientes', vacacion.diasPendientes.toStringAsFixed(0), align: CrossAxisAlignment.end, color: Colors.orange)),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    // Detalles de Fechas
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(child: _buildDetailColumn('Fecha Inicio', formatDateStr(vacacion.fechaInicio))),
                                        Expanded(child: _buildDetailColumn('Fecha Final', formatDateStr(vacacion.fechaFinal), align: CrossAxisAlignment.center)),
                                        Expanded(child: _buildDetailColumn('Fecha Regreso', formatDateStr(vacacion.fechaRegreso), align: CrossAxisAlignment.end)),
                                      ],
                                    ),
                                    // Observaciones
                                    if (vacacion.observaciones?.isNotEmpty == true) ...[
                                      const SizedBox(height: 16),
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.yellow.shade50,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: Colors.yellow.shade200),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('Observaciones', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.yellow.shade800)),
                                            const SizedBox(height: 4),
                                            Text(vacacion.observaciones!, style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error al cargar historial de vacaciones: $err')),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showVacacionDialog(context, ref, empleado.id),
            icon: const Icon(Icons.add),
            label: const Text('Registrar Vacación'),
            tooltip: 'Registrar nueva vacación',
            backgroundColor: Colors.blue.shade800,
            foregroundColor: Colors.white,
          ),
        );
      },
    );
  }

  void _showVacacionDialog(BuildContext context, WidgetRef ref, int empleadoId, {VacacionEmpleado? vacacionToEdit}) {
    final formKey = GlobalKey<FormState>();
    final periodoController = TextEditingController(text: vacacionToEdit?.periodo ?? '${DateTime.now().year}-${DateTime.now().year + 1}');
    String? selectedTipoSolicitud = vacacionToEdit?.tipoSolicitud ?? 'Normal';
    final tipoPermisoController = TextEditingController(text: vacacionToEdit?.tipoPermiso ?? '');
    
    final diasVacacionesController = TextEditingController(text: vacacionToEdit?.diasVacaciones.toString() ?? '0');
    final diasPagadosController = TextEditingController(text: vacacionToEdit?.diasPagados.toString() ?? '0');
    final diasPendientesController = TextEditingController(text: vacacionToEdit?.diasPendientes.toString() ?? '0');
    
    final fechaInicioController = TextEditingController(text: vacacionToEdit?.fechaInicio != null ? vacacionToEdit!.fechaInicio!.split('T')[0] : '');
    final fechaFinalController = TextEditingController(text: vacacionToEdit?.fechaFinal != null ? vacacionToEdit!.fechaFinal!.split('T')[0] : '');
    final fechaRegresoController = TextEditingController(text: vacacionToEdit?.fechaRegreso != null ? vacacionToEdit!.fechaRegreso!.split('T')[0] : '');
    final observacionesController = TextEditingController(text: vacacionToEdit?.observaciones ?? '');

    final tiposSolicitud = ['Normal', 'Adelantadas', 'Permiso'];
    if (!tiposSolicitud.contains(selectedTipoSolicitud)) {
      tiposSolicitud.add(selectedTipoSolicitud);
    }

    Future<void> selectDate(TextEditingController controller) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
      );
      if (picked != null) {
        controller.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(vacacionToEdit == null ? 'Registrar Vacación' : 'Editar Vacación'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: periodoController,
                        decoration: const InputDecoration(labelText: 'Periodo (Ej. 2023-2024)', border: OutlineInputBorder()),
                        validator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'Tipo de Solicitud', border: OutlineInputBorder()),
                        initialValue: selectedTipoSolicitud,
                        items: tiposSolicitud.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                        onChanged: (v) => setState(() => selectedTipoSolicitud = v),
                      ),
                      const SizedBox(height: 10),
                      if (selectedTipoSolicitud == 'Permiso') ...[
                        TextFormField(
                          controller: tipoPermisoController,
                          decoration: const InputDecoration(labelText: 'Tipo de Permiso (Ej. Maternidad)', border: OutlineInputBorder()),
                        ),
                        const SizedBox(height: 10),
                      ],
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: diasVacacionesController,
                              decoration: const InputDecoration(labelText: 'Días Vac/Disfrut.', border: OutlineInputBorder()),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: diasPagadosController,
                              decoration: const InputDecoration(labelText: 'Días Pagados', border: OutlineInputBorder()),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: diasPendientesController,
                        decoration: const InputDecoration(labelText: 'Días Pendientes', border: OutlineInputBorder()),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: fechaInicioController,
                        decoration: InputDecoration(
                          labelText: 'Fecha Inicio',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(icon: const Icon(Icons.calendar_today), onPressed: () => selectDate(fechaInicioController)),
                        ),
                        readOnly: true,
                        onTap: () => selectDate(fechaInicioController),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: fechaFinalController,
                        decoration: InputDecoration(
                          labelText: 'Fecha Final',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(icon: const Icon(Icons.calendar_today), onPressed: () => selectDate(fechaFinalController)),
                        ),
                        readOnly: true,
                        onTap: () => selectDate(fechaFinalController),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: fechaRegresoController,
                        decoration: InputDecoration(
                          labelText: 'Fecha Regreso',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(icon: const Icon(Icons.calendar_today), onPressed: () => selectDate(fechaRegresoController)),
                        ),
                        readOnly: true,
                        onTap: () => selectDate(fechaRegresoController),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: observacionesController,
                        decoration: const InputDecoration(labelText: 'Observaciones', border: OutlineInputBorder()),
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      final repository = ref.read(vacacionRepositoryProvider);
                      try {
                        final data = {
                          'empleado_id': empleadoId.toString(),
                          'periodo': periodoController.text,
                          'tipoSolicitud': selectedTipoSolicitud,
                          'tipoPermiso': selectedTipoSolicitud == 'Permiso' ? tipoPermisoController.text : null,
                          'diasVacaciones': diasVacacionesController.text,
                          'diasPagados': diasPagadosController.text,
                          'diasPendientes': diasPendientesController.text,
                          'fechaInicio': fechaInicioController.text.isNotEmpty ? fechaInicioController.text : null,
                          'fechaFinal': fechaFinalController.text.isNotEmpty ? fechaFinalController.text : null,
                          'fechaRegreso': fechaRegresoController.text.isNotEmpty ? fechaRegresoController.text : null,
                          'observaciones': observacionesController.text,
                          'usuario_id': '1',
                        };

                        if (vacacionToEdit == null) {
                          await repository.registrarVacacion(data, null);
                          if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vacaciones registradas con éxito')));
                        } else {
                          await repository.actualizarVacacion(vacacionToEdit.id, data, null);
                          if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vacaciones actualizadas con éxito')));
                        }
                        ref.invalidate(vacacionesEmpleadoProvider(empleadoId));
                        if (context.mounted) Navigator.of(context).pop();
                      } catch (e) {
                        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                      }
                    }
                  },
                  child: Text(vacacionToEdit == null ? 'Guardar' : 'Actualizar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmarEliminarVacacion(BuildContext context, WidgetRef ref, int vacacionId, int empleadoId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar Vacación'),
          content: const Text('¿Estás seguro de que deseas eliminar este registro de vacaciones? Esta acción no se puede deshacer.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await ref.read(vacacionRepositoryProvider).eliminarVacacion(vacacionId);
                  ref.invalidate(vacacionesEmpleadoProvider(empleadoId));
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registro de vacaciones eliminado con éxito')));
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // Widget para la pestaña de Historial de Faltas
  Widget _buildFaltasTab(Empleado empleado) {
    return Consumer(
      builder: (context, ref, child) {
        final faltasAsync = ref.watch(faltasEmpleadoProvider(empleado.id));
        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          body: faltasAsync.when(
            data: (faltasData) {
              if (faltasData.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_busy_outlined, size: 60, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      const Text('Sin historial de faltas', style: TextStyle(fontSize: 18, color: Colors.grey)),
                      const SizedBox(height: 8),
                      const Text('No hay faltas registradas para este empleado.', style: TextStyle(color: Colors.grey), textAlign: TextAlign.center),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => ref.refresh(faltasEmpleadoProvider(empleado.id).future),
                child: ListView.builder(
                  padding: const EdgeInsets.all(12.0),
                  itemCount: faltasData.length,
                  itemBuilder: (context, index) {
                    final falta = faltasData[index];

                    String formatDateStr(DateTime? d) {
                      if (d == null) return 'N/A';
                      return _formatDate(d);
                    }

                    return Card(
                      elevation: 1,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.red.shade100),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Fila de Título y Botones
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Chip(
                                  label: const Text('Falta Registrada'),
                                  backgroundColor: Colors.red.shade50,
                                  labelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.red.shade800),
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  visualDensity: VisualDensity.compact,
                                ),
                                Row(
                                  children: [
                                    if (falta.documento != null && falta.documento!.isNotEmpty)
                                      IconButton(
                                        icon: const Icon(Icons.attach_file, color: Colors.blue),
                                        tooltip: 'Ver Documento',
                                        onPressed: () async {
                                          final url = Uri.parse('${ApiConstants.baseUrl}${falta.documento}');
                                          if (await canLaunchUrl(url)) {
                                            await launchUrl(url, mode: LaunchMode.externalApplication);
                                          } else {
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text('No se pudo abrir el documento.')),
                                              );
                                            }
                                          }
                                        },
                                      ),
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                                      tooltip: 'Editar Falta',
                                      onPressed: () => _showFaltaDialog(context, ref, empleado.id, faltaToEdit: falta),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                                      tooltip: 'Eliminar Falta',
                                      onPressed: () => _confirmarEliminarFalta(context, ref, falta.id, empleado.id),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Auditoría (Creado/Modificado)
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Creado por: ${falta.creadoPorNombre ?? "Admin"} | Fecha: ${formatDateStr(falta.fecha)}', style: const TextStyle(fontSize: 10, color: Colors.black54)),
                                  if (falta.fechaModificacion != null && falta.fechaModificacion != falta.fechaCreacion)
                                    Text('Modificado: ${falta.modificadoPorNombre ?? "s/d"} | Fecha: ${formatDateStr(falta.fechaModificacion)}', style: const TextStyle(fontSize: 10, color: Colors.black54)),
                                ],
                              ),
                            ),
                            const Divider(height: 24),
                            // Detalles
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Motivo', style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 2),
                                      Text(falta.motivo, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: Colors.black87)),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Sanción', style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 2),
                                      Text(falta.sancion?.isNotEmpty == true ? falta.sancion! : 'Sin sanción especificada', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: Colors.black87)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error al cargar historial de faltas: $err')),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showFaltaDialog(context, ref, empleado.id),
            icon: const Icon(Icons.add),
            label: const Text('Registrar Falta'),
            tooltip: 'Registrar una nueva falta',
          ),
        );
      },
    );
  }

  void _showFaltaDialog(BuildContext context, WidgetRef ref, int empleadoId, {Falta? faltaToEdit}) {
    final formKey = GlobalKey<FormState>();
    final motivoController = TextEditingController(text: faltaToEdit?.motivo ?? '');
    final sancionController = TextEditingController(text: faltaToEdit?.sancion ?? '');
    DateTime selectedDate = faltaToEdit?.fecha ?? DateTime.now();
    PlatformFile? selectedFile;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(faltaToEdit == null ? 'Registrar Falta' : 'Editar Falta'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Fecha de Falta', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        subtitle: Text('${selectedDate.day}/${selectedDate.month}/${selectedDate.year}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2101),
                          );
                          if (picked != null && picked != selectedDate) {
                            setState(() {
                              selectedDate = picked;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: motivoController,
                        decoration: const InputDecoration(
                          labelText: 'Motivo',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingrese el motivo';
                          }
                          return null;
                        },
                        maxLines: 2,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: sancionController,
                        decoration: const InputDecoration(
                          labelText: 'Sanción (Opcional)',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: () async {
                          FilePickerResult? result = await FilePicker.pickFiles(
                            type: FileType.custom,
                            allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'png'],
                          );
                          if (result != null) {
                            setState(() {
                              selectedFile = result.files.first;
                            });
                          }
                        },
                        icon: const Icon(Icons.attach_file),
                        label: Text(selectedFile != null ? 'Archivo: ${selectedFile!.name}' : 'Adjuntar Documento'),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      final repository = ref.read(faltaRepositoryProvider);
                      try {
                        // Mapear a formato 'yyyy-MM-dd' 
                        final String fechaStr = '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';

                        if (faltaToEdit == null) {
                          await repository.registrarFalta({
                            'empleado_id': empleadoId.toString(),
                            'fecha': fechaStr,
                            'motivo': motivoController.text,
                            'sancion': sancionController.text,
                            'creadoPor': '1', // Hardcoded o desde auth
                          }, selectedFile);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Falta registrada con éxito')));
                          }
                        } else {
                          await repository.actualizarFalta(faltaToEdit.id, {
                            'fecha': fechaStr,
                            'motivo': motivoController.text,
                            'sancion': sancionController.text,
                            'modificadoPor': '1',
                          }, selectedFile);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Falta actualizada con éxito')));
                          }
                        }
                        ref.invalidate(faltasEmpleadoProvider(empleadoId));
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                        }
                      }
                    }
                  },
                  child: Text(faltaToEdit == null ? 'Guardar' : 'Actualizar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmarEliminarFalta(BuildContext context, WidgetRef ref, int faltaId, int empleadoId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar Falta'),
          content: const Text('¿Estás seguro de que deseas eliminar este registro de falta? Esta acción no se puede deshacer.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await ref.read(faltaRepositoryProvider).eliminarFalta(faltaId);
                  ref.invalidate(faltasEmpleadoProvider(empleadoId));
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Falta eliminada con éxito')));
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // Widget para la pestaña de Historial de Notas
  Widget _buildNotasTab(Empleado empleado) {
    return Consumer(
      builder: (context, ref, child) {
        final notasAsync = ref.watch(notasEmpleadoProvider(empleado.id));
        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          body: notasAsync.when(
            data: (notasData) {
              if (notasData.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.note_alt_outlined, size: 60, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      const Text('Sin historial de notas', style: TextStyle(fontSize: 18, color: Colors.grey)),
                      const SizedBox(height: 8),
                      const Text('No hay registros de notas para este empleado.', style: TextStyle(color: Colors.grey), textAlign: TextAlign.center),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => ref.refresh(notasEmpleadoProvider(empleado.id).future),
                child: ListView.builder(
                  padding: const EdgeInsets.all(12.0),
                  itemCount: notasData.length,
                  itemBuilder: (context, index) {
                    final nota = notasData[index];

                    String formatDateStr(DateTime? d) {
                      if (d == null) return 'N/A';
                      return _formatDate(d);
                    }

                    return Card(
                      elevation: 1,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.blue.shade100),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Fila de Título y Botones
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    nota.asunto,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Row(
                                  children: [
                                    if (nota.documento != null && nota.documento!.isNotEmpty)
                                      IconButton(
                                        icon: const Icon(Icons.attach_file, color: Colors.blue),
                                        tooltip: 'Ver Documento',
                                        onPressed: () async {
                                          final url = Uri.parse('${ApiConstants.baseUrl}${nota.documento}');
                                          if (await canLaunchUrl(url)) {
                                            await launchUrl(url, mode: LaunchMode.externalApplication);
                                          } else {
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text('No se pudo abrir el documento.')),
                                              );
                                            }
                                          }
                                        },
                                      ),
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                                      tooltip: 'Editar Nota',
                                      onPressed: () => _showNotaDialog(context, ref, empleado.id, notaToEdit: nota),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                                      tooltip: 'Eliminar Nota',
                                      onPressed: () => _confirmarEliminarNota(context, ref, nota.id, empleado.id),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Auditoría (Creado/Modificado)
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Creado por: ${nota.creadoPorNombre ?? "Admin"} | Fecha: ${formatDateStr(nota.fechaCreacion)}', style: const TextStyle(fontSize: 10, color: Colors.black54)),
                                  if (nota.fechaModificacion != null && nota.fechaModificacion != nota.fechaCreacion)
                                    Text('Modificado: ${nota.modificadoPorNombre ?? "s/d"} | Fecha: ${formatDateStr(nota.fechaModificacion)}', style: const TextStyle(fontSize: 10, color: Colors.black54)),
                                ],
                              ),
                            ),
                            const Divider(height: 16),
                            // Detalles
                            Text('Descripción', style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(nota.descripcion, style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 13, color: Colors.black87)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error al cargar historial de notas: $err')),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showNotaDialog(context, ref, empleado.id),
            icon: const Icon(Icons.add),
            label: const Text('Registrar Nota'),
            tooltip: 'Registrar una nueva nota',
            backgroundColor: Colors.blue.shade800,
            foregroundColor: Colors.white,
          ),
        );
      },
    );
  }

  void _showNotaDialog(BuildContext context, WidgetRef ref, int empleadoId, {Nota? notaToEdit}) {
    final formKey = GlobalKey<FormState>();
    final asuntoController = TextEditingController(text: notaToEdit?.asunto ?? '');
    final descripcionController = TextEditingController(text: notaToEdit?.descripcion ?? '');
    PlatformFile? selectedFile;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(notaToEdit == null ? 'Registrar Nota' : 'Editar Nota'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: asuntoController,
                        decoration: const InputDecoration(
                          labelText: 'Asunto',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingrese el asunto';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: descripcionController,
                        decoration: const InputDecoration(
                          labelText: 'Descripción',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingrese una descripción';
                          }
                          return null;
                        },
                        maxLines: 4,
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: () async {
                          FilePickerResult? result = await FilePicker.pickFiles(
                            type: FileType.custom,
                            allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'png'],
                          );
                          if (result != null) {
                            setState(() {
                              selectedFile = result.files.first;
                            });
                          }
                        },
                        icon: const Icon(Icons.attach_file),
                        label: Text(selectedFile != null ? 'Archivo: ${selectedFile!.name}' : 'Adjuntar Documento'),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      final repository = ref.read(notaRepositoryProvider);
                      try {
                        if (notaToEdit == null) {
                          await repository.registrarNota({
                            'empleado_id': empleadoId.toString(),
                            'asunto': asuntoController.text,
                            'descripcion': descripcionController.text,
                            'creadoPor': '1', // Hardcoded o desde auth
                          }, selectedFile);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nota registrada con éxito')));
                          }
                        } else {
                          await repository.actualizarNota(notaToEdit.id, {
                            'asunto': asuntoController.text,
                            'descripcion': descripcionController.text,
                            'modificadoPor': '1',
                          }, selectedFile);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nota actualizada con éxito')));
                          }
                        }
                        ref.invalidate(notasEmpleadoProvider(empleadoId));
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                        }
                      }
                    }
                  },
                  child: Text(notaToEdit == null ? 'Guardar' : 'Actualizar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmarEliminarNota(BuildContext context, WidgetRef ref, int notaId, int empleadoId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar Nota'),
          content: const Text('¿Estás seguro de que deseas eliminar este registro de nota? Esta acción no se puede deshacer.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await ref.read(notaRepositoryProvider).eliminarNota(notaId);
                  ref.invalidate(notasEmpleadoProvider(empleadoId));
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nota eliminada con éxito')));
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // Widget para la pestaña de Documentos
  Widget _buildDocumentosTab(Empleado empleado) {
    return Consumer(
      builder: (context, ref, child) {
        final documentosAsync = ref.watch(documentosEmpleadoProvider(empleado.id));
        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          body: documentosAsync.when(
            data: (documentosData) {
              if (documentosData.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.folder_open_outlined, size: 60, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      const Text('Sin historial de documentos', style: TextStyle(fontSize: 18, color: Colors.grey)),
                      const SizedBox(height: 8),
                      const Text('No hay registros de documentos para este empleado.', style: TextStyle(color: Colors.grey), textAlign: TextAlign.center),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => ref.refresh(documentosEmpleadoProvider(empleado.id).future),
                child: ListView.builder(
                  padding: const EdgeInsets.all(12.0),
                  itemCount: documentosData.length,
                  itemBuilder: (context, index) {
                    final documento = documentosData[index];

                    String formatDateStr(DateTime? d) {
                      if (d == null) return 'N/A';
                      return _formatDate(d);
                    }

                    return Card(
                      elevation: 1,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.orange.shade100),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Fila de Título y Botones
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    documento.titulo,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Row(
                                  children: [
                                    if (documento.archivoUrl.isNotEmpty)
                                      IconButton(
                                        icon: const Icon(Icons.attach_file, color: Colors.blue),
                                        tooltip: 'Ver Archivo',
                                        onPressed: () async {
                                          final url = Uri.parse('${ApiConstants.baseUrl}${documento.archivoUrl}');
                                          if (await canLaunchUrl(url)) {
                                            await launchUrl(url, mode: LaunchMode.externalApplication);
                                          } else {
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text('No se pudo abrir el archivo.')),
                                              );
                                            }
                                          }
                                        },
                                      ),
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                                      tooltip: 'Editar Documento',
                                      onPressed: () => _showDocumentoDialog(context, ref, empleado.id, documentoToEdit: documento),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                                      tooltip: 'Eliminar Documento',
                                      onPressed: () => _confirmarEliminarDocumento(context, ref, documento.id, empleado.id),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Auditoría (Creado/Modificado)
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Creado por: ${documento.creadoPorNombre ?? "Admin"} | Fecha: ${formatDateStr(documento.fechaCreacion)}', style: const TextStyle(fontSize: 10, color: Colors.black54)),
                                ],
                              ),
                            ),
                            const Divider(height: 16),
                            // Detalles
                            Text('Tipo de Documento', style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(documento.tipo, style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 13, color: Colors.black87)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error al cargar historial de documentos: $err')),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showDocumentoDialog(context, ref, empleado.id),
            icon: const Icon(Icons.upload_file),
            label: const Text('Subir Documento'),
            tooltip: 'Registrar un nuevo documento',
            backgroundColor: Colors.orange.shade800,
            foregroundColor: Colors.white,
          ),
        );
      },
    );
  }

  void _showDocumentoDialog(BuildContext context, WidgetRef ref, int empleadoId, {DocumentoEmpleado? documentoToEdit}) {
    final formKey = GlobalKey<FormState>();
    final tituloController = TextEditingController(text: documentoToEdit?.titulo ?? '');
    String? selectedTipo = documentoToEdit?.tipo ?? 'Documento General';
    PlatformFile? selectedFile;

    final tiposDisponibles = ['Documento General', 'Identificación', 'Comprobante de Domicilio', 'Certificado Médico', 'Carta de Recomendación'];
    if (!tiposDisponibles.contains(selectedTipo)) {
      tiposDisponibles.add(selectedTipo);
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(documentoToEdit == null ? 'Subir Documento' : 'Editar Documento'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: tituloController,
                        decoration: const InputDecoration(
                          labelText: 'Título del Documento',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingrese un título';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Tipo',
                          border: OutlineInputBorder(),
                        ),
                        initialValue: selectedTipo,
                        items: tiposDisponibles.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                        onChanged: (v) => setState(() => selectedTipo = v),
                      ),
                      const SizedBox(height: 15),
                      OutlinedButton.icon(
                        onPressed: () async {
                          FilePickerResult? result = await FilePicker.pickFiles(
                            type: FileType.custom,
                            allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'png'],
                          );
                          if (result != null) {
                            setState(() {
                              selectedFile = result.files.first;
                            });
                          }
                        },
                        icon: const Icon(Icons.attach_file),
                        label: Text(selectedFile != null ? 'Archivo: ${selectedFile!.name}' : (documentoToEdit == null ? 'Seleccionar Archivo (Requerido)' : 'Reemplazar Archivo (Opcional)')),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      if (documentoToEdit == null && selectedFile == null) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor, selecciona un archivo para subir')));
                        return;
                      }

                      final repository = ref.read(documentoRepositoryProvider);
                      try {
                        if (documentoToEdit == null) {
                          await repository.registrarDocumento({
                            'empleado_id': empleadoId.toString(),
                            'titulo': tituloController.text,
                            'tipo': selectedTipo,
                            'creadoPor': '1', // Hardcoded o desde auth
                          }, selectedFile);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Documento registrado con éxito')));
                          }
                        } else {
                          await repository.actualizarDocumento(documentoToEdit.id, {
                            'titulo': tituloController.text,
                            'tipo': selectedTipo,
                            'modificadoPor': '1',
                          }, selectedFile);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Documento actualizado con éxito')));
                          }
                        }
                        ref.invalidate(documentosEmpleadoProvider(empleadoId));
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                        }
                      }
                    }
                  },
                  child: Text(documentoToEdit == null ? 'Subir' : 'Actualizar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmarEliminarDocumento(BuildContext context, WidgetRef ref, int docId, int empleadoId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar Documento'),
          content: const Text('¿Estás seguro de que deseas eliminar este documento? El archivo se perderá permanentemente.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await ref.read(documentoRepositoryProvider).eliminarDocumento(docId);
                  ref.invalidate(documentosEmpleadoProvider(empleadoId));
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Documento eliminado con éxito')));
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _handleMenuSelection(BuildContext context, WidgetRef ref, String value, Empleado empleado) {
    String message = 'Funcionalidad no implementada.';
    switch (value) {
      case 'editar':
        message = 'Navegación a editar empleado no implementada.';
        break;
      case 'contacto':
        message = 'Registro de contacto no implementado.';
        break;
      case 'estado':
        final nuevoEstado = empleado.estado == 1 ? 'desactivar' : 'activar';
        message = 'Cambio de estado a $nuevoEstado no implementado.';
        break;
      case 'contrato':
        context.push('/nuevo-contrato', extra: empleado.id);
        return;
      case 'falta':
        _showFaltaDialog(context, ref, empleado.id);
        return;
      case 'nota':
        _showNotaDialog(context, ref, empleado.id);
        break;
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }
}