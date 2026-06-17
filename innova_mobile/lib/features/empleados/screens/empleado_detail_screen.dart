// CREADO POR: DANIEL INNOVA

import 'package:flutter/material.dart';
import '../models/empleado_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'contrato_provider.dart';
 
class EmpleadoDetailScreen extends StatefulWidget {
  final Empleado empleado;

  const EmpleadoDetailScreen({super.key, required this.empleado});

  @override
  State<EmpleadoDetailScreen> createState() => _EmpleadoDetailScreenState();
}

class _EmpleadoDetailScreenState extends State<EmpleadoDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Se crean 5 tabs para las diferentes secciones del perfil del empleado
    _tabController = TabController(length: 5, vsync: this);
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
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuSelection(value, empleado),
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
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.person_outline), text: 'General'),
            Tab(icon: Icon(Icons.description_outlined), text: 'Contratos'),
            Tab(icon: Icon(Icons.beach_access_outlined), text: 'Vacaciones'),
            Tab(icon: Icon(Icons.warning_amber_outlined), text: 'Incidencias'),
            Tab(icon: Icon(Icons.folder_open_outlined), text: 'Documentos'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildInformacionGeneralTab(empleado),
          _buildContratosTab(empleado),
          _buildPlaceholderTab('Gestión de Vacaciones', Icons.beach_access),
          _buildPlaceholderTab('Reportes de Incidencias', Icons.warning),
          _buildPlaceholderTab('Documentos del Empleado', Icons.folder),
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
                      ? NetworkImage('http://10.0.2.2:3007${empleado.foto}')
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
          _buildInfoTile(Icons.phone_outlined, 'Teléfono',
              empleado.telefono ?? 'No disponible'),
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
          _buildInfoTile(Icons.phone_outlined, 'Teléfono',
              empleado.emergenciaTelefono?.isNotEmpty == true ? empleado.emergenciaTelefono! : 'No disponible'),
        ]),
        if (empleado.emergenciaNombre2?.isNotEmpty == true) ...[
          const SizedBox(height: 16),
          _buildInfoCard('Contacto de Emergencia 2', [
            _buildInfoTile(Icons.person_outline, 'Nombre',
                empleado.emergenciaNombre2!),
            _buildInfoTile(Icons.family_restroom_outlined, 'Parentesco',
                empleado.emergenciaParentesco2?.isNotEmpty == true ? empleado.emergenciaParentesco2! : 'No disponible'),
            _buildInfoTile(Icons.phone_outlined, 'Teléfono',
                empleado.emergenciaTelefono2?.isNotEmpty == true ? empleado.emergenciaTelefono2! : 'No disponible'),
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
                                _buildDetailColumn('Fecha Inicio', _formatDate(contrato.fechaInicio)),
                                _buildDetailColumn('Fecha Fin', contrato.fechaFin != null ? _formatDate(contrato.fechaFin!) : 'N/A', align: CrossAxisAlignment.center),
                                _buildDetailColumn('Fecha Salida', contrato.fechaSalida != null ? _formatDate(contrato.fechaSalida!) : 'N/A', align: CrossAxisAlignment.end),
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
                                  final url = Uri.parse('http://10.0.2.2:3007${contrato.archivo}');
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
  Widget _buildInfoTile(IconData icon, String title, String subtitle) {
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
    );
  }

  Widget _buildDetailColumn(String title, String value, {CrossAxisAlignment? align}) {
    return Column(
      crossAxisAlignment: align ?? CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.w500)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }

  // Widget para las pestañas que aún no están implementadas
  Widget _buildPlaceholderTab(String title, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 60, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(fontSize: 18, color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Esta sección se implementará próximamente.',
            style: TextStyle(color: Colors.grey.shade400),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _handleMenuSelection(String value, Empleado empleado) {
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
        message = 'Registro de falta no implementado.';
        break;
      case 'nota':
        message = 'Registro de nota no implementado.';
        break;
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }
}