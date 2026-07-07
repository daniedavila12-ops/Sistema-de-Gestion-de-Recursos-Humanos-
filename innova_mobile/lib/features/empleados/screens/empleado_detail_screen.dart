// CREADO POR: DANIEL INNOVA

import 'package:flutter/material.dart';
import '../models/empleado_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../repositories/empleado_repository.dart';
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
import 'package:innova_mobile/core/services/socket_service.dart';
 
class EmpleadoDetailScreen extends StatefulWidget {
  final Empleado empleado;
  final int initialTabIndex;

  const EmpleadoDetailScreen({super.key, required this.empleado, this.initialTabIndex = 0});

  @override
  State<EmpleadoDetailScreen> createState() => _EmpleadoDetailScreenState();
}

class _EmpleadoDetailScreenState extends State<EmpleadoDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _filtroPeriodoHistorial = 'Todos';
  late Empleado _empleado;

  @override
  void initState() {
    super.initState();
    _empleado = widget.empleado;
    // Se crean 6 tabs para las diferentes secciones del perfil del empleado
    _tabController = TabController(length: 6, vsync: this, initialIndex: widget.initialTabIndex);
    
    // Escuchar actualizaciones en tiempo real
    SocketService().socket.on('refresh_empleado_detalle', _onRefreshEmpleadoDetalle);
  }

  void _onRefreshEmpleadoDetalle(dynamic data) {
    if (data != null && data.toString() == _empleado.id.toString()) {
      _reloadEmpleado();
    }
  }

  Future<void> _reloadEmpleado() async {
    try {
      final repo = EmpleadoRepository();
      final updated = await repo.getEmpleado(_empleado.id);
      if (mounted) {
        setState(() {
          _empleado = updated;
        });
      }
    } catch (e) {
      // ignore error
    }
  }

  @override
  void dispose() {
    SocketService().socket.off('refresh_empleado_detalle', _onRefreshEmpleadoDetalle);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final empleado = _empleado;

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
                            // Header: Status, Edit Button and Creators
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade100,
                                            border: Border.all(color: Colors.grey.shade200),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            contrato.tipoContrato.toUpperCase(),
                                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey.shade600),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: isActivo ? Colors.green.shade50 : Colors.red.shade50,
                                            border: Border.all(color: isActivo ? Colors.green.shade200 : Colors.red.shade200),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            contrato.estado.toUpperCase(),
                                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: isActivo ? Colors.green.shade700 : Colors.red.shade700),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Flexible(
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade50,
                                            border: Border.all(color: Colors.grey.shade200),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              RichText(
                                                textAlign: TextAlign.right,
                                                text: TextSpan(
                                                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey),
                                                  children: [
                                                    const TextSpan(text: 'CREADO POR: '),
                                                    TextSpan(text: (contrato.creadoPorNombre ?? 'Admin').toUpperCase(), style: const TextStyle(color: Colors.black54)),
                                                    const TextSpan(text: '  |  FECHA: '),
                                                    TextSpan(text: _formatDate(contrato.fechaCreacion), style: const TextStyle(color: Colors.black54)),
                                                  ],
                                                ),
                                              ),
                                              if (contrato.fechaModificacion != null && contrato.fechaModificacion != contrato.fechaCreacion) ...[
                                                const SizedBox(height: 2),
                                                RichText(
                                                  textAlign: TextAlign.right,
                                                  text: TextSpan(
                                                    style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey),
                                                    children: [
                                                      const TextSpan(text: 'MODIFICADO: '),
                                                      TextSpan(text: (contrato.modificadoPorNombre ?? contrato.creadoPorNombre ?? 'S/D').toUpperCase(), style: const TextStyle(color: Colors.black54)),
                                                      const TextSpan(text: '  |  FECHA: '),
                                                      TextSpan(text: _formatDate(contrato.fechaModificacion!), style: const TextStyle(color: Colors.black54)),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                    InkWell(
                                      onTap: () {
                                        
                                        context.push('/nuevo-contrato', extra: {'empleadoId': empleado.id, 'contrato': contrato});
                                      },
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade50,
                                          border: Border.all(color: Colors.blue.shade100),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(Icons.edit, size: 16, color: Colors.blue.shade600),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Fila de Fechas
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(child: _buildDetailColumn('Fecha Inicio', _formatDate(contrato.fechaInicio))),
                                Expanded(child: _buildDetailColumn('Fecha Fin', contrato.fechaFin != null ? _formatDate(contrato.fechaFin!) : 'N/A', align: CrossAxisAlignment.center)),
                                Expanded(child: _buildDetailColumn('Fecha Salida', contrato.fechaSalida != null ? _formatDate(contrato.fechaSalida!) : 'S/D', align: CrossAxisAlignment.end)),
                              ],
                            ),
                            // Observaciones y Archivo
                            if (contrato.notas?.isNotEmpty == true) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(10),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey.shade100),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('OBSERVACIÓN', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.grey)),
                                    const SizedBox(height: 2),
                                    Text(contrato.notas!, style: TextStyle(fontSize: 12, color: Colors.grey.shade800, fontStyle: FontStyle.italic)),
                                  ],
                                ),
                              ),
                            ],
                            if (contrato.archivo?.isNotEmpty == true) ...[
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
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
                                icon: const Icon(Icons.attach_file, size: 14),
                                label: const Text('Ver Documento Adjunto'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey.shade800,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
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
                                              onPressed: () => _showVacacionDialog(context, ref, empleado, vacacionToEdit: vacacion),
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
            onPressed: () => _showVacacionDialog(context, ref, empleado),
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

  void _showVacacionDialog(BuildContext context, WidgetRef ref, Empleado empleado, {VacacionEmpleado? vacacionToEdit}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _VacacionBottomSheet(
          empleado: empleado,
          vacacionToEdit: vacacionToEdit,
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

  Future<void> _handleMenuSelection(BuildContext context, WidgetRef ref, String value, Empleado empleado) async {
    String message = 'Funcionalidad no implementada.';
    switch (value) {
      case 'editar':
        final result = await context.push('/editar-empleado', extra: empleado);
        if (result == true && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Empleado actualizado, regresa a la lista para ver los cambios.')));
        }
        return;
      case 'contacto':
        // Reuse the edit screen for contacts since it has all the validation logic
        // Alternatively we can use a custom modal but the edit screen already handles emergency contacts perfectly in sections 3 and 4
        final res = await context.push('/editar-empleado', extra: empleado);
        if (res == true && context.mounted) {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Contactos actualizados, regresa a la lista para ver los cambios.')));
        }
        return;
      case 'estado':
        final nuevoEstado = empleado.estado == 1 ? 0 : 1;
        try {
          await EmpleadoRepository().updateEstado(empleado.id, nuevoEstado);
          setState(() {
            empleado.estado = nuevoEstado;
          });
          message = 'Empleado ${nuevoEstado == 1 ? 'activado' : 'desactivado'} con éxito.';
        } catch (e) {
          message = 'Error al cambiar el estado: $e';
        }
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
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }
}

class _VacacionBottomSheet extends ConsumerStatefulWidget {
  final Empleado empleado;
  final VacacionEmpleado? vacacionToEdit;

  const _VacacionBottomSheet({
    required this.empleado,
    this.vacacionToEdit,
  });

  @override
  ConsumerState<_VacacionBottomSheet> createState() => _VacacionBottomSheetState();
}

class _VacacionBottomSheetState extends ConsumerState<_VacacionBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController tipoPermisoController;
  late TextEditingController diasVacacionesController;
  late TextEditingController diasPagadosController;
  late TextEditingController diasPendientesController;
  late TextEditingController fechaInicioController;
  late TextEditingController fechaFinalController;
  late TextEditingController fechaRegresoController;
  late TextEditingController observacionesController;
  
  late TextEditingController fechaSolicitudController;
  late TextEditingController diasCorrespondientesController;
  late TextEditingController autorizadoPorController;

  String? selectedTipoSolicitud;
  String? selectedPeriodo;
  PlatformFile? selectedDocument;
  bool isSaving = false;

  final List<String> tiposSolicitud = ['Normal', 'Adelantadas', 'Pagadas', 'Permiso Especial'];
  List<String> periodosDisponibles = [];

  @override
  void initState() {
    super.initState();
    final v = widget.vacacionToEdit;
    
    selectedTipoSolicitud = v?.tipoSolicitud ?? 'Normal';
    if (!tiposSolicitud.contains(selectedTipoSolicitud)) {
      tiposSolicitud.add(selectedTipoSolicitud!);
    }
    
    selectedPeriodo = v?.periodo;

    tipoPermisoController = TextEditingController(text: v?.tipoPermiso ?? '');
    diasVacacionesController = TextEditingController(text: v?.diasVacaciones.toString() ?? '0');
    diasPagadosController = TextEditingController(text: v?.diasPagados.toString() ?? '0');
    diasPendientesController = TextEditingController(text: v?.diasPendientes.toString() ?? '0');
    
    fechaInicioController = TextEditingController(text: v?.fechaInicio != null ? v!.fechaInicio!.split('T')[0] : '');
    fechaFinalController = TextEditingController(text: v?.fechaFinal != null ? v!.fechaFinal!.split('T')[0] : '');
    fechaRegresoController = TextEditingController(text: v?.fechaRegreso != null ? v!.fechaRegreso!.split('T')[0] : '');
    observacionesController = TextEditingController(text: v?.observaciones ?? '');

    fechaSolicitudController = TextEditingController(text: v?.fechaSolicitud != null ? v!.fechaSolicitud!.split('T')[0] : "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}");
    diasCorrespondientesController = TextEditingController(text: v?.diasCorrespondientes.toString() ?? '0');
    autorizadoPorController = TextEditingController(text: v?.autorizadoPor ?? '');
  }

  @override
  void dispose() {
    tipoPermisoController.dispose();
    diasVacacionesController.dispose();
    diasPagadosController.dispose();
    diasPendientesController.dispose();
    fechaInicioController.dispose();
    fechaFinalController.dispose();
    fechaRegresoController.dispose();
    observacionesController.dispose();
    fechaSolicitudController.dispose();
    diasCorrespondientesController.dispose();
    autorizadoPorController.dispose();
    super.dispose();
  }

  void _calcularPeriodosDisponibles() {
    final vacacionesAsync = ref.read(vacacionesEmpleadoProvider(widget.empleado.id));
    final vacacionesEmpleado = vacacionesAsync.value ?? [];
    
    if (widget.empleado.fechaInicio == null) return;
    DateTime inicio = widget.empleado.fechaInicio!;
    int anioInicio = inicio.year;
    int anioActual = DateTime.now().year;
    List<String> periodos = [];
    
    DateTime hoy = DateTime.now();
    int aniosLaboradosReales = hoy.year - inicio.year;
    if (hoy.month < inicio.month || (hoy.month == inicio.month && hoy.day < inicio.day)) {
      aniosLaboradosReales--;
    }
    
    if (selectedTipoSolicitud == 'Adelantadas') {
      int periodoAnioInicio = anioInicio + (aniosLaboradosReales > 0 ? aniosLaboradosReales : 0);
      String periodoAdelantado = "$periodoAnioInicio-${periodoAnioInicio + 1}";
      bool isRegistrado = vacacionesEmpleado.any((v) => v.periodo == periodoAdelantado && (widget.vacacionToEdit == null || v.id != widget.vacacionToEdit!.id));
      if (!isRegistrado) periodos.add(periodoAdelantado);
    } else if (selectedTipoSolicitud == 'Normal' || selectedTipoSolicitud == 'Pagadas') {
      for (int i = 0; i < aniosLaboradosReales; i++) {
        int periodoAnioInicio = anioInicio + i;
        String periodo = "$periodoAnioInicio-${periodoAnioInicio + 1}";
        bool isRegistrado = vacacionesEmpleado.any((v) => v.periodo == periodo && (widget.vacacionToEdit == null || v.id != widget.vacacionToEdit!.id));
        if (!isRegistrado) periodos.add(periodo);
      }
    } else if (selectedTipoSolicitud == 'Permiso Especial') {
      for (int i = anioInicio; i <= anioActual; i++) {
        periodos.add("$i-${i + 1}");
      }
    } else {
      for (int i = anioInicio; i <= anioActual; i++) {
        String periodo = "$i-${i + 1}";
        bool isRegistrado = vacacionesEmpleado.any((v) => v.periodo == periodo && (widget.vacacionToEdit == null || v.id != widget.vacacionToEdit!.id));
        if (!isRegistrado) periodos.add(periodo);
      }
    }
    
    setState(() {
      periodosDisponibles = periodos.reversed.toList();
      if (selectedPeriodo != null && !periodosDisponibles.contains(selectedPeriodo)) {
        periodosDisponibles.insert(0, selectedPeriodo!);
      } else if (periodosDisponibles.isNotEmpty && selectedPeriodo == null) {
        selectedPeriodo = periodosDisponibles.first;
      }
      _onPeriodoChanged();
    });
  }
  int _aniosLaboradosCalculados() {
    if (widget.empleado.fechaInicio == null) return 0;
    DateTime inicio = widget.empleado.fechaInicio!;
    if (selectedPeriodo != null && selectedPeriodo!.contains('-')) {
      int anioFin = int.tryParse(selectedPeriodo!.split('-')[1]) ?? inicio.year;
      return (anioFin - inicio.year) > 0 ? (anioFin - inicio.year) : 0;
    } else {
      DateTime hoy = DateTime.now();
      int anios = hoy.year - inicio.year;
      if (hoy.month < inicio.month || (hoy.month == inicio.month && hoy.day < inicio.day)) {
        anios--;
      }
      return anios > 0 ? anios : 0;
    }
  }

  int _diasCorrespondientesCalculados() {
    int anios = _aniosLaboradosCalculados();
    if (anios >= 4) return 20;
    if (anios == 3) return 15;
    if (anios == 2) return 12;
    if (anios == 1) return 10;
    return 0;
  }

  void _onPeriodoChanged() {
    if (widget.vacacionToEdit == null) {
      diasCorrespondientesController.text = _diasCorrespondientesCalculados().toString();
      _calcularDiasPendientes();
    }
  }

  bool _isUpdating = false;

  void _calcularDiasPendientes() {
    final correspondientes = double.tryParse(diasCorrespondientesController.text) ?? 0.0;
    final tomados = double.tryParse(diasVacacionesController.text) ?? 0.0;
    final pagados = double.tryParse(diasPagadosController.text) ?? 0.0;
    
    double pendientes;
    if (selectedTipoSolicitud == 'Pagadas') {
      pendientes = correspondientes - pagados - tomados;
    } else {
      pendientes = correspondientes - tomados;
    }
    
    diasPendientesController.text = pendientes.toStringAsFixed(0);
  }

  void _calcularFechas() {
    String inicioStr = fechaInicioController.text;
    double dias = double.tryParse(diasVacacionesController.text) ?? 0.0;
    
    if (inicioStr.isNotEmpty && dias > 0) {
      try {
        DateTime dInicio = DateTime.parse(inicioStr);
        int diasContados = 0;
        DateTime fechaActual = dInicio;

        if (fechaActual.weekday == DateTime.sunday) {
          fechaActual = fechaActual.add(const Duration(days: 1));
        }

        while (diasContados < dias) {
          if (fechaActual.weekday != DateTime.sunday) {
            diasContados++;
          }
          if (diasContados < dias) {
            fechaActual = fechaActual.add(const Duration(days: 1));
          }
        }

        fechaFinalController.text = "${fechaActual.year}-${fechaActual.month.toString().padLeft(2, '0')}-${fechaActual.day.toString().padLeft(2, '0')}";

        DateTime fRegreso = fechaActual.add(const Duration(days: 1));
        while (fRegreso.weekday == DateTime.sunday) {
          fRegreso = fRegreso.add(const Duration(days: 1));
        }
        fechaRegresoController.text = "${fRegreso.year}-${fRegreso.month.toString().padLeft(2, '0')}-${fRegreso.day.toString().padLeft(2, '0')}";

        if (selectedTipoSolicitud == 'Permiso Especial' || selectedTipoSolicitud == 'Normal' || selectedTipoSolicitud == 'Adelantadas') {
          diasPagadosController.text = '0';
        } else if (selectedTipoSolicitud != 'Pagadas') {
          diasPagadosController.text = dias.toStringAsFixed(0);
        }
        _calcularDiasPendientes();
      } catch (e) {
        // Ignore parse error
      }
    } else if (inicioStr.isEmpty) {
      fechaFinalController.text = '';
      fechaRegresoController.text = '';
      if (selectedTipoSolicitud == 'Permiso Especial' || selectedTipoSolicitud == 'Normal' || selectedTipoSolicitud == 'Adelantadas') {
        diasPagadosController.text = '0';
      } else if (selectedTipoSolicitud != 'Pagadas') {
        diasPagadosController.text = dias.toStringAsFixed(0);
      }
      _calcularDiasPendientes();
    }
  }

  void _onDiasVacacionesChanged(String value) {
    if (_isUpdating) return;
    setState(() {
      _isUpdating = true;
      double val = double.tryParse(value) ?? 0.0;
      if (val < 0) {
        diasVacacionesController.text = '0';
        val = 0;
      }
      
      double correspondientes = double.tryParse(diasCorrespondientesController.text) ?? 0.0;

      if (selectedTipoSolicitud == 'Permiso Especial') {
        if (val > 4) {
          diasVacacionesController.text = '4';
          val = 4;
        }
        diasPagadosController.text = '0';
      } else if (selectedTipoSolicitud == 'Normal' || selectedTipoSolicitud == 'Adelantadas') {
        if (val > correspondientes) {
          diasVacacionesController.text = correspondientes.toStringAsFixed(0);
          val = correspondientes;
        }
        diasPagadosController.text = '0';
      } else {
        diasPagadosController.text = val.toStringAsFixed(0);
      }
      
      _calcularFechas();
      _calcularDiasPendientes();
      _isUpdating = false;
    });
  }

  void _onDiasPagadosChanged(String value) {
    if (_isUpdating) return;
    setState(() {
      _isUpdating = true;
      double val = double.tryParse(value) ?? 0.0;
      if (val < 0) {
        diasPagadosController.text = '0';
        val = 0;
      }
      if (selectedTipoSolicitud == 'Pagadas') {
        double correspondientes = double.tryParse(diasCorrespondientesController.text) ?? 0.0;
        if (val > correspondientes) {
          diasPagadosController.text = correspondientes.toStringAsFixed(0);
        }
      }
      _calcularDiasPendientes();
      _isUpdating = false;
    });
  }

  void _onTipoSolicitudChanged() {
    if (_isUpdating) return;
    setState(() {
      _isUpdating = true;
      if (selectedTipoSolicitud == 'Permiso Especial') {
        diasPagadosController.text = '0';
        double val = double.tryParse(diasVacacionesController.text) ?? 0.0;
        if (val > 4) diasVacacionesController.text = '4';
      } else if (selectedTipoSolicitud == 'Normal' || selectedTipoSolicitud == 'Adelantadas') {
        diasPagadosController.text = '0';
      } else {
        diasPagadosController.text = diasVacacionesController.text;
      }
      _calcularFechas();
      _calcularDiasPendientes();
      _isUpdating = false;
    });
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue.shade800,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        controller.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
        if (controller == fechaInicioController) {
          _calcularFechas();
        }
      });
    }
  }

  Future<void> _pickDocument() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
    );
    if (result != null) {
      setState(() {
        selectedDocument = result.files.first;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSaving = true);
    final repository = ref.read(vacacionRepositoryProvider);
    
    try {
      final data = {
        'empleado_id': widget.empleado.id.toString(),
        'periodo': selectedPeriodo ?? '',
        'tipoSolicitud': selectedTipoSolicitud,
        'tipoPermiso': selectedTipoSolicitud == 'Permiso Especial' ? tipoPermisoController.text : null,
        'diasCorrespondientes': diasCorrespondientesController.text,
        'diasVacaciones': diasVacacionesController.text,
        'diasPagados': diasPagadosController.text,
        'diasPendientes': diasPendientesController.text,
        'fechaSolicitud': fechaSolicitudController.text.isNotEmpty ? fechaSolicitudController.text : null,
        'fechaInicio': fechaInicioController.text.isNotEmpty ? fechaInicioController.text : null,
        'fechaFinal': fechaFinalController.text.isNotEmpty ? fechaFinalController.text : null,
        'fechaRegreso': fechaRegresoController.text.isNotEmpty ? fechaRegresoController.text : null,
        'observaciones': observacionesController.text,
        'autorizadoPor': autorizadoPorController.text,
      };

      if (widget.vacacionToEdit == null) {
        await repository.registrarVacacion(data, selectedDocument);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vacaciones registradas con éxito', style: TextStyle(color: Colors.white)), backgroundColor: Colors.green));
      } else {
        await repository.actualizarVacacion(widget.vacacionToEdit!.id, data, selectedDocument);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vacaciones actualizadas con éxito', style: TextStyle(color: Colors.white)), backgroundColor: Colors.green));
      }
      
      ref.invalidate(vacacionesEmpleadoProvider(widget.empleado.id));
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString(), style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  Widget _buildTextField(String label, TextEditingController controller, {IconData? icon, bool readOnly = false, VoidCallback? onTap, TextInputType? keyboardType, bool isRequired = false, bool enabled = true, ValueChanged<String>? onChanged}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        enabled: enabled,
        onTap: onTap,
        onChanged: onChanged,
        keyboardType: keyboardType,
        validator: isRequired ? (value) => value == null || value.isEmpty ? 'Requerido' : null : null,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.blueGrey.shade500, fontSize: 13, fontWeight: FontWeight.w600),
          filled: true,
          fillColor: enabled ? Colors.blueGrey.shade50 : Colors.blueGrey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blueGrey.shade200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blueGrey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue.shade500, width: 2),
          ),
          suffixIcon: icon != null ? IconButton(icon: Icon(icon, color: Colors.blue.shade500), onPressed: onTap) : null,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              color: Colors.blue.shade800,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.vacacionToEdit == null ? 'REGISTRAR VACACIONES' : 'EDITAR VACACIÓN',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 1.2
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Gestión de vacaciones para el empleado',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade100,
                          fontStyle: FontStyle.italic
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          // Body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('DATOS DE VACACIONES'),
                    
                    Row(
                      children: [
                        Expanded(child: _buildTextField('Fecha Solicitud', fechaSolicitudController, icon: Icons.calendar_today, readOnly: true, onTap: () => _selectDate(fechaSolicitudController), isRequired: true)),
                      ],
                    ),
                    
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: DropdownButtonFormField<String>(
                              isExpanded: true,
                              initialValue: selectedTipoSolicitud,
                              items: tiposSolicitud.map((t) => DropdownMenuItem(value: t, child: Text(t, overflow: TextOverflow.ellipsis))).toList(),
                              onChanged: (v) {
                                setState(() {
                                  selectedTipoSolicitud = v;
                                  selectedPeriodo = null;
                                  _calcularPeriodosDisponibles();
                                });
                                _onTipoSolicitudChanged();
                              },
                              decoration: InputDecoration(
                                labelText: 'Tipo Solicitud',
                                labelStyle: TextStyle(color: Colors.blueGrey.shade500, fontSize: 13, fontWeight: FontWeight.w600),
                                filled: true,
                                fillColor: Colors.blueGrey.shade50,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: DropdownButtonFormField<String>(
                              isExpanded: true,
                              initialValue: selectedPeriodo,
                              items: periodosDisponibles.map((p) => DropdownMenuItem(value: p, child: Text(p, overflow: TextOverflow.ellipsis))).toList(),
                              onChanged: (v) {
                                setState(() => selectedPeriodo = v);
                                _onPeriodoChanged();
                              },
                              decoration: InputDecoration(
                                labelText: 'Periodo',
                                labelStyle: TextStyle(color: Colors.blueGrey.shade500, fontSize: 13, fontWeight: FontWeight.w600),
                                filled: true,
                                fillColor: Colors.blueGrey.shade50,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                              ),
                              validator: (val) => val == null || val.isEmpty ? 'Requerido' : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    if (selectedPeriodo != null || selectedTipoSolicitud == 'Permiso Especial') ...[
                      if (selectedTipoSolicitud == 'Permiso Especial')
                        _buildTextField('Tipo de Permiso (Ej. Maternidad)', tipoPermisoController),
                      
                      _buildSectionTitle('CÁLCULO DE DÍAS'),
                      if (selectedTipoSolicitud != 'Permiso Especial') ...[
                        Row(
                          children: [
                            Expanded(child: _buildTextField('Correspondientes', diasCorrespondientesController, keyboardType: TextInputType.number, enabled: selectedTipoSolicitud != 'Pagadas' && selectedTipoSolicitud != 'Adelantadas', onChanged: (_) => _calcularDiasPendientes())),
                            const SizedBox(width: 12),
                            if (selectedTipoSolicitud != 'Pagadas')
                              Expanded(child: _buildTextField('Vac/Disfrutados', diasVacacionesController, keyboardType: TextInputType.number, onChanged: _onDiasVacacionesChanged))
                            else
                              const Spacer(),
                          ],
                        ),
                        Row(
                          children: [
                            if (selectedTipoSolicitud == 'Pagadas')
                              Expanded(child: _buildTextField('Pagados', diasPagadosController, keyboardType: TextInputType.number, onChanged: _onDiasPagadosChanged))
                            else
                              const Spacer(),
                            const SizedBox(width: 12),
                            Expanded(child: _buildTextField('Pendientes', diasPendientesController, keyboardType: TextInputType.number, enabled: !(selectedTipoSolicitud == 'Normal' || selectedTipoSolicitud == 'Pagadas' || selectedTipoSolicitud == 'Adelantadas'))),
                          ],
                        ),
                      ] else ...[
                        Row(
                          children: [
                            Expanded(child: _buildTextField('Días a Tomar', diasVacacionesController, keyboardType: TextInputType.number, onChanged: _onDiasVacacionesChanged)),
                          ],
                        ),
                      ],
  
                      _buildSectionTitle('FECHAS DE AUSENCIA'),
                      if (selectedTipoSolicitud != 'Pagadas') ...[
                        Row(
                          children: [
                            Expanded(child: _buildTextField('Inicio', fechaInicioController, icon: Icons.calendar_today, readOnly: true, onTap: () => _selectDate(fechaInicioController))),
                            const SizedBox(width: 12),
                            Expanded(child: _buildTextField('Final', fechaFinalController, icon: Icons.calendar_today, readOnly: true, onTap: () => _selectDate(fechaFinalController))),
                          ]
                        ),
                        _buildTextField('Fecha Regreso', fechaRegresoController, icon: Icons.calendar_today, readOnly: true, onTap: () => _selectDate(fechaRegresoController)),
                      ],
  
                      _buildSectionTitle('AUTORIZACIÓN Y OBSERVACIONES'),
                      _buildTextField('Autorizado Por', autorizadoPorController, isRequired: true),
                      _buildTextField('Observaciones', observacionesController),
                      
                      // Documento
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blueGrey.shade200, style: BorderStyle.solid),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Documento Adjunto (Opcional)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.blueGrey)),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                ElevatedButton.icon(
                                  onPressed: _pickDocument,
                                  icon: const Icon(Icons.upload_file, size: 18),
                                  label: const Text('Seleccionar'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.blue.shade600,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Colors.blue.shade200)),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    selectedDocument?.name ?? (widget.vacacionToEdit?.documento != null ? 'Documento actual guardado' : 'Ningún archivo seleccionado'),
                                    style: TextStyle(fontSize: 12, color: Colors.blueGrey.shade500, fontStyle: FontStyle.italic),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          // Footer
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.blueGrey.shade100)),
              boxShadow: [
                BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 10, offset: const Offset(0, -5))
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      side: BorderSide(color: Colors.blueGrey.shade300),
                    ),
                    child: Text('Cancelar', style: TextStyle(color: Colors.blueGrey.shade600, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isSaving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade800,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: isSaving
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text(widget.vacacionToEdit == null ? 'Guardar' : 'Actualizar', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0, top: 8.0),
      child: Text(
        title, 
        style: TextStyle(
          fontSize: 11, 
          fontWeight: FontWeight.w900, 
          color: Colors.blue.shade800, 
          letterSpacing: 1.5
        )
      ),
    );
  }
}
