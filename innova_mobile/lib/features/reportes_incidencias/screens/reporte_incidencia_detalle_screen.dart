// CREADO POR: DANIEL INNOVA

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../models/reporte_incidencia_model.dart';

import '../providers/reporte_incidencia_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../empleados/providers/empleado_provider.dart';
import '../../empleados/models/empleado_model.dart';
import '../utils/pdf_reporte_generator.dart';
import 'package:innova_mobile/core/constants/api_constants.dart';

class ReporteIncidenciaDetalleScreen extends ConsumerStatefulWidget {
  final ReporteIncidencia reporte;

  const ReporteIncidenciaDetalleScreen({super.key, required this.reporte});

  @override
  ConsumerState<ReporteIncidenciaDetalleScreen> createState() => _ReporteIncidenciaDetalleScreenState();
}

class _ReporteIncidenciaDetalleScreenState extends ConsumerState<ReporteIncidenciaDetalleScreen> {
  final _respuestaController = TextEditingController();
  String? _archivoRuta;
  bool _isLoadingResp = false;
  
  late String _estadoActual;
  int? _usuarioAsignadoId;

  @override
  void initState() {
    super.initState();
    _estadoActual = widget.reporte.estado;
    _usuarioAsignadoId = widget.reporte.asignadoUsuarioId;
  }

  @override
  void dispose() {
    _respuestaController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarArchivo() async {
    FilePickerResult? result = await FilePicker.pickFiles();
    if (result != null) {
      setState(() {
        _archivoRuta = result.files.single.path;
      });
    }
  }

  Future<void> _enviarRespuesta() async {
    final texto = _respuestaController.text.trim();
    if (texto.isEmpty && _archivoRuta == null) return;

    final user = ref.read(authProvider).user;

    setState(() => _isLoadingResp = true);
    try {
      final repo = ref.read(reporteIncidenciaRepositoryProvider);
      await repo.addRespuesta(widget.reporte.id, texto, usuarioId: user?.id, archivoPath: _archivoRuta);
      
      _respuestaController.clear();
      setState(() => _archivoRuta = null);
      
      ref.invalidate(respuestasReporteProvider(widget.reporte.id));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Respuesta enviada')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoadingResp = false);
    }
  }

  Future<void> _cambiarEstado(String nuevoEstado) async {
    try {
      final repo = ref.read(reporteIncidenciaRepositoryProvider);
      await repo.updateEstado(widget.reporte.id, nuevoEstado);
      setState(() => _estadoActual = nuevoEstado);
      ref.invalidate(reportesIncidenciaProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Estado actualizado')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _asignarUsuario(int usuarioId) async {
    try {
      final repo = ref.read(reporteIncidenciaRepositoryProvider);
      await repo.asignarReporte(widget.reporte.id, usuarioId);
      setState(() => _usuarioAsignadoId = usuarioId);
      ref.invalidate(reportesIncidenciaProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reporte asignado')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  List<Empleado> _getEmpleadosReportados() {
    final empleadosAsync = ref.read(empleadosProvider);
    if (empleadosAsync is AsyncData) {
      final empleados = empleadosAsync.value!;
      final r = widget.reporte;
      if (r.identidad != null && r.identidad!.isNotEmpty) {
        final identidadesArr = r.identidad!.split(',').map((e) => e.trim()).toList();
        return empleados.where((e) => identidadesArr.contains(e.identidad)).toList();
      }
    }
    return [];
  }

  Future<void> _generarPDFBasico() async {
    try {
      final empleadosReportados = _getEmpleadosReportados();
      await PdfReporteGenerator.generarPdfBasico(widget.reporte, empleadosReportados);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al generar PDF: $e')));
    }
  }

  Future<void> _generarPDFResoluciones() async {
    try {
      final respuestasAsync = ref.read(respuestasReporteProvider(widget.reporte.id));
      final respuestas = respuestasAsync.value ?? [];
      final empleadosReportados = _getEmpleadosReportados();
      await PdfReporteGenerator.generarPdfResoluciones(widget.reporte, respuestas, empleadosReportados);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al generar PDF: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text('Reporte #${widget.reporte.id}'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildInfoCard(),
            const SizedBox(height: 16),
            _buildGestionSection(), // Equivalente al sidebar derecho en web
            const SizedBox(height: 16),
            _buildRespuestasSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Reporte #${widget.reporte.id}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.black87)),
              Row(
                children: [
                  _buildPrioridadBadge(widget.reporte.prioridad),
                  const SizedBox(width: 8),
                  _buildEstadoBadge(_estadoActual),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(widget.reporte.tema, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.picture_as_pdf, size: 16),
                  label: const Text('CREAR PDF', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade800,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: _generarPDFBasico,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.picture_as_pdf, size: 16),
                  label: const Text('PDF RESOLUCIONES', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: _generarPDFResoluciones,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    final r = widget.reporte;
    final empleadosAsync = ref.watch(empleadosProvider);
    
    List<String> identidadesArr = [];
    if (r.identidad != null && r.identidad!.isNotEmpty) {
      identidadesArr = r.identidad!.split(',').map((e) => e.trim()).toList();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('EMPLEADO(S) REPORTADO(S)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
          const SizedBox(height: 12),
          
          empleadosAsync.when(
            data: (empleados) {
              final empleadosReportados = empleados.where((e) => identidadesArr.contains(e.identidad)).toList();
              
              if (empleadosReportados.isNotEmpty) {
                return Column(
                  children: empleadosReportados.map((emp) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.grey.shade200,
                            backgroundImage: emp.foto != null ? NetworkImage('${ApiConstants.baseUrl}${emp.foto}') : null,
                            onBackgroundImageError: emp.foto != null ? (e, s) {} : null,
                            child: emp.foto == null ? Text(emp.nombre.isNotEmpty ? emp.nombre[0].toUpperCase() : '?', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)) : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${emp.nombre} ${emp.apellido}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
                                const SizedBox(height: 2),
                                Text('IDENTIDAD: ${emp.identidad}', style: TextStyle(color: Colors.grey.shade500, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              }
              
              // Fallback
              return _buildFallbackEmpleado(r);
            },
            loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
            error: (err, stack) => _buildFallbackEmpleado(r),
          ),
          
          const Divider(height: 32),
          _buildInfoRow(Icons.person, 'Reportado por', r.jefeReporta ?? 'N/A'),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.folder, 'Categoría', r.categoria),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.calendar_today, 'Fecha', r.fechaCreacion?.toString() ?? 'Desconocida'),
          const Divider(height: 32),
          const Text('Descripción', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
          const SizedBox(height: 8),
          Text(r.descripcion, style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.5)),
          if (r.archivo != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
              child: Row(
                children: [
                  const Icon(Icons.attach_file, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(child: Text(r.archivo!.split('/').last, style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold))),
                ],
              ),
            )
          ]
        ],
      ),
    );
  }

  Widget _buildFallbackEmpleado(ReporteIncidencia r) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: Colors.grey.shade200,
          backgroundImage: r.empleadoFoto != null ? NetworkImage('${ApiConstants.baseUrl}${r.empleadoFoto}') : null,
          onBackgroundImageError: r.empleadoFoto != null ? (e, s) {} : null,
          child: r.empleadoFoto == null ? Text(r.empleadoNombre != null && r.empleadoNombre!.isNotEmpty ? r.empleadoNombre![0].toUpperCase() : '?', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)) : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${r.empleadoNombre ?? 'Desconocido'} ${r.empleadoApellido ?? ''}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 2),
              Text(r.identidad ?? 'Sin Identidad', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGestionSection() {
    final usuariosAsync = ref.watch(usuariosRRHHProvider);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('GESTIÓN DEL REPORTE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
          const SizedBox(height: 16),
          const Text('Asignar a', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 8),
          usuariosAsync.when(
            data: (usuarios) {
              return DropdownButtonFormField<int>(
                initialValue: _usuarioAsignadoId,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade200)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade200)),
                ),
                hint: const Text('Seleccionar usuario', style: TextStyle(fontSize: 14)),
                items: usuarios.map((u) => DropdownMenuItem(value: u.id, child: Text(u.nombre))).toList(),
                onChanged: (val) {
                  if (val != null) _asignarUsuario(val);
                },
              );
            },
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('Error al cargar usuarios: $e', style: const TextStyle(color: Colors.red)),
          ),
          const SizedBox(height: 16),
          const Text('Cambiar Estado', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _estadoActual,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey.shade50,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade200)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade200)),
            ),
            items: const [
              DropdownMenuItem(value: 'Pendiente', child: Text('Pendiente')),
              DropdownMenuItem(value: 'En Proceso', child: Text('En Proceso')),
              DropdownMenuItem(value: 'Resuelto', child: Text('Resuelto')),
              DropdownMenuItem(value: 'Cancelado', child: Text('Cancelado')),
            ],
            onChanged: (val) {
              if (val != null) _cambiarEstado(val);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRespuestasSection() {
    final respuestasAsync = ref.watch(respuestasReporteProvider(widget.reporte.id));
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('RESPUESTAS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
              respuestasAsync.maybeWhen(
                data: (r) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12)),
                  child: Text('${r.length} mensajes', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54)),
                ),
                orElse: () => const SizedBox(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Lista de respuestas
          respuestasAsync.when(
            data: (respuestas) {
              if (respuestas.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: Text('No hay respuestas registradas aún.', style: TextStyle(color: Colors.grey))),
                );
              }
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: respuestas.length,
                separatorBuilder: (context, index) => const Divider(height: 24),
                itemBuilder: (context, index) {
                  final res = respuestas[index];
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: res.usuarioFoto != null ? NetworkImage('${ApiConstants.baseUrl}${res.usuarioFoto}') : null,
                        onBackgroundImageError: res.usuarioFoto != null ? (e, s) {} : null,
                        child: res.usuarioFoto == null ? Text(res.usuarioNombre.isNotEmpty ? res.usuarioNombre[0].toUpperCase() : '?', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue)) : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(res.usuarioNombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                const SizedBox(width: 8),
                                if (res.usuarioRol != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(4)),
                                    child: Text(res.usuarioRol!, style: TextStyle(fontSize: 9, color: Colors.blue.shade700, fontWeight: FontWeight.bold)),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(res.respuesta, style: const TextStyle(fontSize: 14, color: Colors.black87)),
                            if (res.archivoUrl != null) ...[
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () {
                                  // Podríamos abrir el archivo, por ahora solo mostramos el enlace visual.
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.attachment, size: 16, color: Colors.blue),
                                      const SizedBox(width: 4),
                                      Text('Archivo adjunto', style: TextStyle(color: Colors.blue.shade700, fontSize: 12, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 8),
                            Text('${res.fechaCreacion.day}/${res.fechaCreacion.month}/${res.fechaCreacion.year} ${res.fechaCreacion.hour}:${res.fechaCreacion.minute.toString().padLeft(2,'0')}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Error: $e', style: const TextStyle(color: Colors.red)),
          ),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          
          // Formulario para nueva respuesta
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_archivoRuta != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.file_present, size: 14, color: Colors.blue),
                            const SizedBox(width: 4),
                            Flexible(child: Text(_archivoRuta!.split('/').last, style: const TextStyle(fontSize: 12, color: Colors.blue), overflow: TextOverflow.ellipsis)),
                            IconButton(
                              icon: const Icon(Icons.close, size: 14, color: Colors.red),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () => setState(() => _archivoRuta = null),
                            )
                          ],
                        ),
                      ),
                    ],
                    TextField(
                      controller: _respuestaController,
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: 'Escribe una respuesta...',
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.attach_file),
                color: Colors.grey.shade600,
                onPressed: _seleccionarArchivo,
              ),
              CircleAvatar(
                backgroundColor: Colors.blue.shade600,
                child: _isLoadingResp 
                    ? const Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : IconButton(
                        icon: const Icon(Icons.send, color: Colors.white, size: 18),
                        onPressed: _enviarRespuesta,
                      ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade500),
        const SizedBox(width: 8),
        Text('$label: ', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
        Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87))),
      ],
    );
  }

  Widget _buildPrioridadBadge(String prioridad) {
    final p = prioridad.toUpperCase();
    Color color = Colors.yellow.shade800;
    Color bg = Colors.yellow.shade50;
    if (p == 'URGENTE') { color = Colors.red.shade700; bg = Colors.red.shade50; }
    if (p == 'ALTA') { color = Colors.orange.shade700; bg = Colors.orange.shade50; }
    if (p == 'BAJA') { color = Colors.green.shade700; bg = Colors.green.shade50; }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withValues(alpha: 0.3))),
      child: Text(p, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
    );
  }

  Widget _buildEstadoBadge(String estado) {
    Color color = Colors.grey.shade700;
    Color bg = Colors.grey.shade50;
    if (estado == 'En Proceso') { color = Colors.blue.shade700; bg = Colors.blue.shade50; }
    if (estado == 'Pendiente') { color = Colors.orange.shade700; bg = Colors.orange.shade50; }
    if (estado == 'Resuelto') { color = Colors.green.shade700; bg = Colors.green.shade50; }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withValues(alpha: 0.3))),
      child: Text(estado.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
    );
  }
}
