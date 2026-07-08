// CREADO POR: DANIEL INNOVA

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/providers/auth_provider.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 60, bottom: 20, left: 20, right: 20),
            color: Colors.blue.shade900,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'RRHH Innova',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Panel de Control',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: const Icon(Icons.dashboard),
                  title: const Text('Dashboard'),
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/dashboard');
                  },
                ),
                if (authState.hasAccess('Empleados') ||
                    authState.hasAccess('Vacaciones') ||
                    authState.hasAccess('Reportes') || authState.hasAccess('Módulo de Reportes') ||
                    authState.hasAccess('Departamentos') ||
                    authState.hasAccess('Reportes de Incidencia') ||
                    authState.hasAccess('Gestión de Manuales') ||
                    authState.hasAccess('Archivero Legal') || authState.hasAccess('Documentos Legales') ||
                    authState.hasAccess('Reclutamiento'))
                  const Padding(
                    padding: EdgeInsets.only(left: 16, top: 16, bottom: 8),
                    child: Text(
                      'RECURSOS HUMANOS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                if (authState.hasAccess('Empleados'))
                  _DrawerItem(
                    icon: Icons.people,
                    title: 'Empleados',
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/empleados');
                    },
                  ),
                if (authState.hasAccess('+Nuevo Empleado'))
                  _DrawerItem(
                    icon: Icons.person_add,
                    title: 'Nuevo Empleado',
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/nuevo-empleado');
                    },
                  ),
                if (authState.hasAccess('Vacaciones'))
                  _DrawerItem(
                    icon: Icons.beach_access,
                    title: 'Registrar Vacaciones',
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/vacaciones');
                    },
                  ),
                if (authState.hasAccess('Reportes') || authState.hasAccess('Módulo de Reportes'))
                  _DrawerItem(
                    icon: Icons.assessment,
                    title: 'Reportes',
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/reportes');
                    },
                  ),
                if (authState.hasAccess('Departamentos'))
                  _DrawerItem(
                    icon: Icons.business,
                    title: 'Departamentos',
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/departamentos');
                    },
                  ),
                if (authState.hasAccess('Reportes de Incidencia'))
                  _DrawerItem(
                    icon: Icons.warning,
                    title: 'Reportes de Incidencias',
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/reportes-incidencias');
                    },
                  ),
                if (authState.hasAccess('Gestión de Manuales'))
                  _DrawerItem(
                    icon: Icons.library_books,
                    title: 'Gestión Manuales',
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/gestion-manuales');
                    },
                  ),
                if (authState.hasAccess('Archivero Legal') || authState.hasAccess('Documentos Legales'))
                  _DrawerItem(
                    icon: Icons.gavel,
                    title: 'Documentos Legales',
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/documentos-legales');
                    },
                  ),
                if (authState.hasAccess('Reclutamiento'))
                  _DrawerItem(
                    icon: Icons.work,
                    title: 'Reclutamiento',
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/reclutamiento');
                    },
                  ),
                if (authState.hasAccess('Tickets') ||
                    authState.hasAccess('Control de Usuarios') || authState.hasAccess('Roles y Permisos') || authState.hasAccess('Control Usuarios y Roles') ||
                    authState.hasAccess('Logs de Sistema'))
                  const Padding(
                    padding: EdgeInsets.only(left: 16, top: 16, bottom: 8),
                    child: Text(
                      'DEPARTAMENTO DE IT',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                if (authState.hasAccess('Tickets'))
                  _DrawerItem(
                    icon: Icons.confirmation_number,
                    title: 'Tickets',
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/tickets');
                    },
                  ),
                if (authState.hasAccess('Control de Usuarios') || authState.hasAccess('Roles y Permisos') || authState.hasAccess('Control Usuarios y Roles'))
                  _DrawerItem(
                    icon: Icons.security,
                    title: 'Control Usuarios y Roles',
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/usuarios-roles');
                    },
                  ),
                if (authState.hasAccess('Logs de Sistema'))
                  _DrawerItem(
                    icon: Icons.list_alt,
                    title: 'Logs de Sistema',
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/logs');
                    },
                  ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: ListTile(
              leading: const Icon(Icons.exit_to_app, color: Colors.red),
              title: const Text(
                'Cerrar Sesión',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
              onTap: () {
                ref.read(authProvider.notifier).logout();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, size: 20),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      dense: true,
      onTap: onTap,
    );
  }
}