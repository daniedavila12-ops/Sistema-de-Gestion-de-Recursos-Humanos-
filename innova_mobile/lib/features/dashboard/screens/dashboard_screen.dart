import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/screens/perfil_usuario_dialog.dart';
import '../providers/dashboard_lists_provider.dart';
import '../../empleados/models/empleado_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:innova_mobile/core/constants/api_constants.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final _cumpleanerosKey = GlobalKey();
  final _vencimientosKey = GlobalKey();


  String _calcularDiasRestantesContratoTexto(String? fechaFinal) {
    if (fechaFinal == null) return '';
    final hoy = DateTime.now();
    final todayDate = DateTime(hoy.year, hoy.month, hoy.day);
    final finalDate = DateTime.parse(fechaFinal).toUtc();
    final finalDateLocal = DateTime(finalDate.year, finalDate.month, finalDate.day);
    
    final diffDays = finalDateLocal.difference(todayDate).inDays;
    
    if (diffDays < 0) return 'Vencido';
    if (diffDays == 0) return 'Vence hoy';
    if (diffDays == 1) return 'Falta 1 día';
    return 'Faltan $diffDays días';
  }

  String _calcularDiasRestantesTexto(String? fechaNacimiento) {
    if (fechaNacimiento == null) return '';
    final hoy = DateTime.now();
    final todayDate = DateTime(hoy.year, hoy.month, hoy.day);
    final nacimiento = DateTime.parse(fechaNacimiento).toUtc();
    
    final cumpleEsteAnio = DateTime(hoy.year, nacimiento.month, nacimiento.day);
    final diffDays = cumpleEsteAnio.difference(todayDate).inDays;
    
    if (diffDays == 0) return '¡Hoy!';
    if (diffDays < 0) {
      final diasPasados = diffDays.abs();
      if (diasPasados == 1) return 'Pasó hace 1 día';
      return 'Pasó hace $diasPasados días';
    }
    
    if (diffDays == 1) return 'Falta 1 día';
    return 'Faltan $diffDays días';
  }

  @override
  Widget build(BuildContext context) {
    final listsState = ref.watch(dashboardListsProvider);
    final statsState = ref.watch(dashboardStatsProvider);
    final filters = ref.watch(dashboardFiltersProvider);
    final authState = ref.watch(authProvider);

    final stats = statsState.value ?? {};
    final totalEmpleados = stats['total']?.toString() ?? '0';
    final ticketsPendientes = stats['tickets']?.toString() ?? '0';
    final incidentesPendientes = stats['incidencias']?.toString() ?? '0';
    final cumpleaneros = stats['cumpleaneros']?.toString() ?? '0';
    final vencimientosCount = stats['vencimientos']?.toString() ?? '0';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📅 ${DateTime.now().day} / ${DateTime.now().month} / ${DateTime.now().year}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 16),

          // Tarjetas de Resumen
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.25,
            children: [
              _buildProfileCard(context, ref),
              if (authState.hasAccess('Empleados'))
                _buildStatCard('Total Empleados', totalEmpleados, '👥', Colors.blue.shade50, Colors.blue.shade900, onTap: () {
                  context.push('/empleados');
                }),
              if (authState.hasAccess('Tickets de IT'))
                _buildStatCard('Tickets Pendientes', ticketsPendientes, '🎫', Colors.orange.shade50, Colors.orange.shade900, onTap: () {
                  context.push('/tickets');
                }),
              if (authState.hasAccess('Reportes de Incidencia'))
                _buildStatCard('Incidentes Pendientes', incidentesPendientes, '⚠️', Colors.red.shade50, Colors.red.shade900, onTap: () {
                  context.push('/reportes-incidencias');
                }),
              if (authState.hasAccess('Empleados'))
                _buildStatCard('Cumpleañeros', cumpleaneros, '🎂', Colors.pink.shade50, Colors.pink.shade900, onTap: () {
                  if (_cumpleanerosKey.currentContext != null) {
                    Scrollable.ensureVisible(
                      _cumpleanerosKey.currentContext!,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    );
                  }
                }),
              if (authState.hasAccess('Empleados'))
                _buildStatCard('Vencimientos', vencimientosCount, '📄', Colors.purple.shade50, Colors.purple.shade900, onTap: () {
                  if (_vencimientosKey.currentContext != null) {
                    Scrollable.ensureVisible(
                      _vencimientosKey.currentContext!,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    );
                  }
                }),
            ],
          ),
          const SizedBox(height: 24),

          listsState.when(
            data: (data) {
              final cumpleaneros = data['cumpleaneros'] as List<dynamic>? ?? [];
              final vencimientos = data['vencimientos'] as List<dynamic>? ?? [];
              final activos = data['activos'] as List<dynamic>? ?? [];
              final inactivos = data['inactivos'] as List<dynamic>? ?? [];

              return Column(
                children: [
                  // CUMPLEAÑEROS
                  if (authState.hasAccess('Empleados'))
                    Container(
                      key: _cumpleanerosKey,
                      child: Column(
                        children: [
                          _buildSectionHeaderWithFilter(
                      '🎂 Cumpleañeros', 
                      DropdownButton<int>(
                        value: filters.mesCumpleaneros,
                        items: List.generate(12, (index) => DropdownMenuItem(
                          value: index + 1,
                          child: Text(_nombreMes(index + 1), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        )),
                        onChanged: (val) {
                          if (val != null) {
                            ref.read(dashboardFiltersProvider.notifier).state = filters.copyWith(mesCumpleaneros: val);
                          }
                        },
                        underline: const SizedBox(),
                        icon: const Icon(Icons.arrow_drop_down, size: 20),
                      ),
                    ),
                    if (cumpleaneros.isEmpty)
                      const Padding(padding: EdgeInsets.all(16.0), child: Text('No hay cumpleañeros este mes', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)))
                    else
                      _buildListCard(cumpleaneros.map((emp) {
                        final texto = _calcularDiasRestantesTexto(emp['fecha_nacimiento']);
                        final isPast = texto.contains('Pasó');
                        final isToday = texto == '¡Hoy!';
                        
                        return _buildListItem(
                          context,
                          emp,
                          '${emp['nombre']} ${emp['apellido']}',
                          emp['fecha_nacimiento'] != null ? emp['fecha_nacimiento'].toString().split('T')[0] : '',
                          texto,
                          isPast,
                          isToday: isToday,
                          foto: emp['foto'],
                          trailingColor: isToday ? Colors.pink : (isPast ? Colors.grey : Colors.green),
                        );
                      }).toList()),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),

                  // VENCIMIENTOS
                  if (authState.hasAccess('Empleados'))
                    Container(
                      key: _vencimientosKey,
                      child: Column(
                        children: [
                          _buildSectionHeaderWithFilter(
                      '📄 Contratos por Vencer', 
                      DropdownButton<String>(
                        value: filters.mesVencimiento,
                        items: [
                          const DropdownMenuItem(value: 'proximos', child: Text('Próximos 30 días', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                          const DropdownMenuItem(value: 'todos', child: Text('Todos', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                          ...List.generate(12, (index) => DropdownMenuItem(
                            value: '${index + 1}',
                            child: Text(_nombreMes(index + 1), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ))
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            ref.read(dashboardFiltersProvider.notifier).state = filters.copyWith(mesVencimiento: val);
                          }
                        },
                        underline: const SizedBox(),
                        icon: const Icon(Icons.arrow_drop_down, size: 20),
                      ),
                    ),
                    if (vencimientos.isEmpty)
                      const Padding(padding: EdgeInsets.all(16.0), child: Text('No hay contratos por vencer pronto', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)))
                    else
                      _buildListCard(vencimientos.map((emp) {
                        final texto = _calcularDiasRestantesContratoTexto(emp['fechaFinal']);
                        return _buildListItem(
                          context,
                          emp,
                          '${emp['nombre']} ${emp['apellido']}',
                          'Vence: ${emp['fechaFinal']?.toString().split('T')[0]} (${emp['tipoContrato']})',
                          texto,
                          false,
                          foto: emp['foto'],
                          trailingColor: texto == 'Vencido' ? Colors.red : Colors.orange,
                        );
                      }).toList()),
                    const SizedBox(height: 24),
                        ],
                      ),
                    ),

                    // ACTIVOS
                    if (authState.hasAccess('Empleados')) ...[
                      _buildSectionHeader('🟢 Empleados Activos', activos.length.toString()),
                    if (activos.isEmpty)
                      const Padding(padding: EdgeInsets.all(16.0), child: Text('No hay empleados activos', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)))
                    else
                      _buildEmployeeList(context, activos, Colors.green),
                    const SizedBox(height: 24),

                    // INACTIVOS
                    _buildSectionHeader('🔴 Empleados Inactivos', inactivos.length.toString()),
                    if (inactivos.isEmpty)
                      const Padding(padding: EdgeInsets.all(16.0), child: Text('No hay empleados inactivos', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)))
                    else
                      _buildEmployeeList(context, inactivos, Colors.red),
                    const SizedBox(height: 32),
                  ],
                ],
              );
            },
            loading: () => const Center(child: Padding(padding: EdgeInsets.all(32.0), child: CircularProgressIndicator())),
            error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
          ),
        ],
      ),
    );
  }

  String _nombreMes(int mes) {
    const meses = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    return meses[mes - 1];
  }

  Widget _buildProfileCard(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final userName = user?.nombre ?? 'Usuario';
    final initial = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';

    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => const PerfilUsuarioDialog(),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                child: Text(initial),
              ),
              const SizedBox(height: 8),
              Text(userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
              Text(user?.email ?? 'Activo', style: const TextStyle(color: Colors.grey, fontSize: 12), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, String icon, Color bgColor, Color textColor, {VoidCallback? onTap}) {
    LinearGradient gradient;
    if (textColor == Colors.blue.shade900) {
      gradient = const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF4F46E5)], begin: Alignment.topLeft, end: Alignment.bottomRight); 
    } else if (textColor == Colors.orange.shade900) {
      gradient = const LinearGradient(colors: [Color(0xFFFBBF24), Color(0xFFF97316)], begin: Alignment.topLeft, end: Alignment.bottomRight); 
    } else if (textColor == Colors.red.shade900) {
      gradient = const LinearGradient(colors: [Color(0xFFF87171), Color(0xFFDC2626)], begin: Alignment.topLeft, end: Alignment.bottomRight); 
    } else if (textColor == Colors.pink.shade900) {
      gradient = const LinearGradient(colors: [Color(0xFFF472B6), Color(0xFFDB2777)], begin: Alignment.topLeft, end: Alignment.bottomRight); 
    } else if (textColor == Colors.purple.shade900) {
      gradient = const LinearGradient(colors: [Color(0xFFA855F7), Color(0xFF9333EA)], begin: Alignment.topLeft, end: Alignment.bottomRight); 
    } else {
      gradient = const LinearGradient(colors: [Color(0xFF34D399), Color(0xFF14B8A6)], begin: Alignment.topLeft, end: Alignment.bottomRight); 
    }

    final card = Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.last.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -15,
            top: -15,
            child: Opacity(
              opacity: 0.15,
              child: Text(icon, style: const TextStyle(fontSize: 70)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(title.toUpperCase(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.2), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(icon, style: const TextStyle(fontSize: 14)),
                    )
                  ],
                ),
                const Spacer(),
                Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                Text(title, style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.8), fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: card,
        ),
      );
    }
    return card;
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
            child: Text(subtitle, style: TextStyle(fontSize: 14, color: Colors.blue.shade800, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeaderWithFilter(String title, Widget filterWidget) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(color: Colors.grey.shade100, border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
            child: filterWidget,
          ),
        ],
      ),
    );
  }

  Widget _buildListCard(List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(children: children),
    );
  }

  Widget _buildListItem(BuildContext context, dynamic empRaw, String title, String subtitle, String trailing, bool isPast, {String? foto, bool isToday = false, Color trailingColor = Colors.green}) {
    return InkWell(
      onTap: () async {
        // Mapeamos temporalmente el empleado_id a id si viene de vencimientos
        final map = Map<String, dynamic>.from(empRaw);
        final empId = map['id'] ?? map['empleado_id'];
        
        try {
          final res = await http.get(Uri.parse('${ApiConstants.baseUrl}/api/empleados/$empId'));
          if (res.statusCode == 200) {
            final data = json.decode(res.body);
            if (context.mounted) context.push('/empleado', extra: Empleado.fromJson(data));
          } else {
            if (context.mounted) context.push('/empleado', extra: Empleado.fromJson(map));
          }
        } catch (e) {
          if (context.mounted) context.push('/empleado', extra: Empleado.fromJson(map));
        }
      },
      child: ListTile(
        visualDensity: VisualDensity.compact,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        leading: SizedBox(
          width: 32,
          height: 32,
          child: CircleAvatar(
            backgroundColor: isToday ? Colors.pink.shade100 : Colors.blue.shade50,
            backgroundImage: foto != null ? NetworkImage('${ApiConstants.baseUrl}$foto') : null,
            child: foto == null
                ? Text(
                    title.isNotEmpty ? title[0].toUpperCase() : 'U',
                    style: TextStyle(color: isToday ? Colors.pink.shade900 : Colors.blue.shade900, fontWeight: FontWeight.bold, fontSize: 12),
                  )
                : null,
          ),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(color: trailingColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
          child: Text(
            trailing,
            style: TextStyle(color: trailingColor, fontWeight: FontWeight.bold, fontSize: 10),
          ),
        ),
      ),
    );
  }

  Widget _buildEmployeeList(BuildContext context, List<dynamic> employees, Color statusColor) {
    return _buildListCard(employees.map((emp) {
      final foto = emp['foto'];
      final nombre = '${emp['nombre']} ${emp['apellido']}';
      final codigo = emp['codigo_empleado'] ?? 'Sin código';

      return InkWell(
        onTap: () async {
          final empId = emp['id'];
          try {
            final res = await http.get(Uri.parse('${ApiConstants.baseUrl}/api/empleados/$empId'));
            if (res.statusCode == 200) {
              final data = json.decode(res.body);
              if (context.mounted) context.push('/empleado', extra: Empleado.fromJson(data));
            } else {
              if (context.mounted) context.push('/empleado', extra: Empleado.fromJson(emp));
            }
          } catch (e) {
            if (context.mounted) context.push('/empleado', extra: Empleado.fromJson(emp));
          }
        },
        child: ListTile(
          visualDensity: VisualDensity.compact,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          leading: SizedBox(
            width: 32,
            height: 32,
            child: CircleAvatar(
              backgroundColor: statusColor.withValues(alpha: 0.1),
              backgroundImage: foto != null ? NetworkImage('${ApiConstants.baseUrl}$foto') : null,
              child: foto == null
                  ? Text(
                      nombre.isNotEmpty ? nombre.substring(0, 1).toUpperCase() : 'U',
                      style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                    )
                  : null,
            ),
          ),
          title: Text(nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          subtitle: Text(codigo, style: const TextStyle(fontSize: 11)),
        ),
      );
    }).toList());
  }
}