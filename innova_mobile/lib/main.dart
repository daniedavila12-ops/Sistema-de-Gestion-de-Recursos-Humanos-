// CREADO POR: DANIEL INNOVA

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/dashboard/screens/dashboard_screen.dart';
import 'features/tickets/screens/ticket_detail_screen.dart';
import 'features/tickets/models/ticket_model.dart';
import 'features/empleados/screens/empleado_detail_screen.dart';
import 'features/empleados/models/empleado_model.dart';
import 'shared/widgets/app_drawer.dart';

// Importaciones de los nuevos módulos (placeholders y existentes)
import 'features/empleados/screens/empleados_screen.dart';
import 'features/empleados/screens/nuevo_empleado_screen.dart';
import 'features/empleados/screens/nuevo_contrato_screen.dart';
import 'features/vacaciones/screens/vacaciones_screen.dart';
import 'features/reportes/screens/reportes_screen.dart';
import 'features/departamentos/screens/departamentos_screen.dart';
import 'features/reportes_incidencias/screens/reportes_incidencias_screen.dart';
import 'features/manuales/screens/manuales_screen.dart';
import 'features/documentos/screens/documentos_screen.dart';
import 'features/tickets/screens/tickets_screen.dart';
import 'features/usuarios_roles/screens/usuarios_roles_screen.dart';
import 'features/logs/screens/logs_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: InnovaApp(),
    ),
  );
}

class InnovaApp extends ConsumerWidget {
  const InnovaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    final router = GoRouter(
      initialLocation: '/login',
      redirect: (context, state) {
        final isGoingToLogin = state.matchedLocation == '/login';
        if (!authState.isAuthenticated && !isGoingToLogin) return '/login';
        if (authState.isAuthenticated && isGoingToLogin) return '/dashboard';
        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => LoginScreen(),
        ),
        ShellRoute(
          builder: (context, state, child) {
            // Un Scaffold maestro que provee el Drawer y el AppBar común
            return Scaffold(
              appBar: AppBar(
                title: const Text('INNOVA SISTEMA RRHH ', style: TextStyle(fontWeight: FontWeight.bold)),
                backgroundColor: Colors.blue.shade900,
                foregroundColor: Colors.white,
              ),
              drawer: const AppDrawer(),
              body: child,
            );
          },
          routes: [
            GoRoute(
              path: '/dashboard',
              builder: (context, state) => const DashboardScreen(),
            ),
            GoRoute(
              path: '/empleados',
              builder: (context, state) => const EmpleadosScreen(),
            ),
            GoRoute(
              path: '/nuevo-empleado',
              builder: (context, state) => const NuevoEmpleadoScreen(),
            ),
            GoRoute(
              path: '/vacaciones',
              builder: (context, state) => const VacacionesScreen(),
            ),
            GoRoute(
              path: '/reportes',
              builder: (context, state) => const ReportesScreen(),
            ),
            GoRoute(
              path: '/departamentos',
              builder: (context, state) => const DepartamentosScreen(),
            ),
            GoRoute(
              path: '/reportes-incidencias',
              builder: (context, state) => const ReportesIncidenciasScreen(),
            ),
            GoRoute(
              path: '/manuales',
              builder: (context, state) => const ManualesScreen(),
            ),
            GoRoute(
              path: '/documentos-legales',
              builder: (context, state) => const DocumentosScreen(),
            ),
            GoRoute(
              path: '/tickets',
              builder: (context, state) => const TicketsScreen(),
            ),
            GoRoute(
              path: '/usuarios-roles',
              builder: (context, state) => const UsuariosRolesScreen(),
            ),
            GoRoute(
              path: '/logs',
              builder: (context, state) => const LogsScreen(),
            ),
          ],
        ),
        // RUTAS DE DETALLE (Sin el Drawer para navegación tipo Stack)
        GoRoute(
          path: '/ticket',
          builder: (context, state) => TicketDetailScreen(ticket: state.extra as Ticket),
        ),
        GoRoute(
          path: '/empleado',
          builder: (context, state) => EmpleadoDetailScreen(empleado: state.extra as Empleado),
        ),
        GoRoute(
          path: '/nuevo-contrato',
          builder: (context, state) => NuevoContratoScreen(empleadoId: state.extra as int),
        ),
      ],
    );

    return MaterialApp.router(
      title: 'INNOVA HHRR',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      routerConfig: router,
    );
  }
}