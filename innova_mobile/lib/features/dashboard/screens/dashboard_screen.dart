import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fecha
          const Text(
            '📅 16 de junio de 2026',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
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
              _buildProfileCard(),
              _buildStatCard('Total Empleados', '26', '👥', Colors.blue.shade50, Colors.blue.shade900),
              _buildStatCard('Tickets Pendientes', '0', '🎫', Colors.orange.shade50, Colors.orange.shade900),
              _buildStatCard('Incidentes Pendientes', '1', '⚠️', Colors.red.shade50, Colors.red.shade900),
              _buildStatCard('Cumpleañeros', '3', '🎂', Colors.pink.shade50, Colors.pink.shade900),
              _buildStatCard('Vencimientos', '2', '📄', Colors.purple.shade50, Colors.purple.shade900),
            ],
          ),
          const SizedBox(height: 24),

          // Cumpleañeros
          _buildSectionHeader('🎂 Cumpleañeros', 'Junio'),
          _buildListCard([
            _buildListItem('Javier Paguada', '5 de junio', 'Pasó hace 11 días', true),
            _buildListItem('Dorian Garcias', '8 de junio', 'Pasó hace 8 días', true),
            _buildListItem('Carlos Flores', '30 de junio', 'Faltan 14 días', false),
          ]),
          const SizedBox(height: 24),

          // Contratos por Vencer
          _buildSectionHeader('📄 Contratos por Vencer', 'Próximos 30 días'),
          _buildListCard([
            _buildListItem('Dorian Garcias', 'Vence: 20/6/2026 (Permanente)', 'Faltan 4 días', false),
            _buildListItem('Javier Paguada', 'Vence: 21/6/2026 (Temporal)', 'Faltan 5 días', false),
          ]),
          const SizedBox(height: 24),

          // Empleados Activos
          _buildSectionHeader('🟢 Empleados Activos', '25'),
          _buildEmployeeList([
            {'name': 'Bryan Leonardo Medina Rodriguez', 'code': 'INST-2758'},
            {'name': 'Carlos Flores', 'code': 'Cod-022'},
            {'name': 'Cristian Regalado Ortega', 'code': 'PROD-3929'},
            {'name': 'Cristian Alberto Navarro Sosa', 'code': 'PROD-3137'},
            {'name': 'Daniel Isaac Valladarez', 'code': 'EMP001'},
            {'name': 'Dorian Garcias', 'code': 'Cod-00377'},
            {'name': 'Elmer Eduardo Caballero Lopez', 'code': 'INST-2156'},
            {'name': 'Fernando Noel Munguia Ocampo', 'code': 'INST-2270'},
            {'name': 'Irvin Yoel Mendoza Sosa', 'code': 'PROD-3261'},
            {'name': 'Javier Paguada', 'code': 'EMP0030'},
            {'name': 'Javier Ramiro Rodriguez Ardon', 'code': 'INST-2709'},
            {'name': 'Jesuar Gabriel Rodriguez Lopez', 'code': 'INST-2886'},
            {'name': 'Jesus Remberto Lopez Morazan', 'code': 'PROD-3845'},
            {'name': 'Jesus Remberto Menjivar Cruz', 'code': 'INST-2707'},
            {'name': 'Joel Grey Banegas Mercado', 'code': 'PROD-3108'},
            {'name': 'Jonathan Emanuel Castro Ocampo', 'code': 'PROD-3089'},
            {'name': 'Jose Arnulfo Medina Ortiz', 'code': 'PROD-3019'},
            {'name': 'Jose Miguel Lopez Morazan', 'code': 'INST-2077'},
            {'name': 'Jose Reynaldo Suazo Ortiz', 'code': 'PROD-3820'},
            {'name': 'Karin Beckan', 'code': 'Cod-378'},
            {'name': 'Luis Fernando Hernandez Calix', 'code': 'INST-2528'},
            {'name': 'Marco Javier Huete Castillo', 'code': 'INST-2508'},
            {'name': 'Omar Alberto Vijil Rivera', 'code': 'INST-2691'},
            {'name': 'Sergio Enrique Rodriguez Nuñez', 'code': 'PROD-3653'},
            {'name': 'Sthephanie Villanueva', 'code': 'Cod320'},
          ]),
          const SizedBox(height: 24),

          // Empleados Inactivos
          _buildSectionHeader('🔴 Empleados Inactivos', '1'),
          _buildEmployeeList([
            {'name': 'Denison Ramirez', 'code': 'Cod-077'},
          ]),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: const Padding(
        padding: EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
              child: Text('G'),
            ),
            SizedBox(height: 8),
            Text('Gerad Cole', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            Text('Usuario Activo', style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, String icon, Color bgColor, Color textColor) {
    return Card(
      elevation: 2,
      color: bgColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 24)),
            const Spacer(),
            Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor)),
            Text(title, style: TextStyle(fontSize: 12, color: textColor.withOpacity(0.8))),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(subtitle, style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w600)),
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

  Widget _buildListItem(String title, String subtitle, String trailing, bool isPast, {String? foto}) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.blue.shade50,
        backgroundImage: foto != null ? NetworkImage('http://10.0.2.2:3007$foto') : null,
        child: foto == null
            ? Text(
                title.isNotEmpty ? title[0].toUpperCase() : 'U',
                style: TextStyle(color: Colors.blue.shade900, fontWeight: FontWeight.bold),
              )
            : null,
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      trailing: Text(
        trailing,
        style: TextStyle(color: isPast ? Colors.red : Colors.green, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildEmployeeList(List<Map<String, String>> employees) {
    return _buildListCard(employees.map((emp) {
      return ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade50,
          backgroundImage: emp.containsKey('foto') && emp['foto'] != null
              ? NetworkImage('http://10.0.2.2:3007${emp['foto']}')
              : null,
          child: !emp.containsKey('foto') || emp['foto'] == null
              ? Text(
                  emp['name']!.isNotEmpty ? emp['name']!.substring(0, 1).toUpperCase() : 'U',
                  style: TextStyle(color: Colors.blue.shade900, fontWeight: FontWeight.bold),
                )
              : null,
        ),
        title: Text(emp['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(emp['code']!),
      );
    }).toList());
  }
}