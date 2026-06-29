// CREADO POR: DANIEL INNOVA

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'features/notificaciones/widgets/notificaciones_button.dart';
import 'features/notificaciones/providers/notificaciones_provider.dart';
import 'shared/widgets/app_drawer.dart';

// Importaciones de los nuevos módulos (placeholders y existentes)
import 'features/empleados/screens/empleados_screen.dart';
import 'features/empleados/screens/nuevo_empleado_screen.dart';
import 'features/empleados/screens/nuevo_contrato_screen.dart';
import 'features/vacaciones/screens/vacaciones_screen.dart';
import 'features/reportes/screens/reportes_screen.dart';
import 'features/departamentos/departamentos_screen.dart';
import 'features/reportes_incidencias/screens/reportes_incidencia_screen.dart';
import 'features/reportes_incidencias/screens/crear_reporte_incidencia_screen.dart';
import 'features/reportes_incidencias/screens/reporte_incidencia_detalle_screen.dart';
import 'features/reportes_incidencias/models/reporte_incidencia_model.dart';
import 'features/manuales/screens/manuales_screen.dart';
import 'features/manuales/screens/gestion_manuales_screen.dart';
import 'features/documentos/screens/documentos_screen.dart';
import 'features/tickets/screens/tickets_screen.dart';
import 'features/tickets/screens/crear_ticket_screen.dart';
import 'features/usuarios_roles/screens/usuarios_roles_screen.dart';
import 'features/logs/screens/logs_screen.dart';

import 'features/manuales/screens/biblioteca_publica_screen.dart';
import 'features/tickets/screens/tickets_publicos_screen.dart';
import 'features/reportes_incidencias/screens/crear_incidencia_publica_screen.dart';
import 'features/reportes/screens/reporte_sms_publico_screen.dart';

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
        final publicRoutes = [
          '/login',
          '/biblioteca',
          '/tickets-publicos',
          '/incidencia-publica',
          '/reporte-sms-publico'
        ];
        
        final isPublic = publicRoutes.contains(state.matchedLocation);

        if (!authState.isAuthenticated && !isPublic) return '/login';
        if (authState.isAuthenticated && state.matchedLocation == '/login') return '/dashboard';
        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => LoginScreen(),
        ),
        GoRoute(
          path: '/biblioteca',
          builder: (context, state) => const BibliotecaPublicaScreen(),
        ),
        GoRoute(
          path: '/tickets-publicos',
          builder: (context, state) => const TicketsPublicosScreen(),
        ),
        GoRoute(
          path: '/incidencia-publica',
          builder: (context, state) => const CrearIncidenciaPublicaScreen(),
        ),
        GoRoute(
          path: '/reporte-sms-publico',
          builder: (context, state) => const ReporteSmsPublicoScreen(),
        ),
        ShellRoute(
          builder: (context, state, child) {
            // Para acceder al estado de autenticación y mostrar el usuario, usamos un Consumer.
            return Consumer(builder: (context, ref, _) {
              final authState = ref.watch(authProvider);
              // Asumimos que authState.user contiene la información del usuario logueado
              // y que el objeto de usuario tiene una propiedad 'nombre'.
              final user = authState.user;

              ref.listen<AsyncValue<List<dynamic>>>(notificacionesProvider, (previous, next) {
                if (next.hasValue && previous?.hasValue == true) {
                  final oldUnread = previous!.value!.where((n) => n['leida'] == 0).length;
                  final newUnread = next.value!.where((n) => n['leida'] == 0).length;
                  
                  if (newUnread > oldUnread) {
                    HapticFeedback.vibrate();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('¡Tienes nuevas notificaciones! 🎫⚠️', style: TextStyle(fontWeight: FontWeight.bold)),
                        backgroundColor: Colors.blue.shade900,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        duration: const Duration(seconds: 4),
                      ),
                    );
                  }
                }
              });

              return Scaffold(
                appBar: AppBar(
                  title: const Text('INNOVA SISTEMA RRHH', style: TextStyle(fontWeight: FontWeight.bold)),
                  backgroundColor: Colors.blue.shade900,
                  foregroundColor: Colors.white,
                  actions: [
                    if (user != null)
                      const NotificacionesButton(),
                    if (user != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: Center(child: Text(user.nombre, style: const TextStyle(fontSize: 16))),
                      ),
                  ],
                ),
                drawer: const AppDrawer(),
                body: child,
              );
            });
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
              builder: (context, state) => const ReportesIncidenciaScreen(),
            ),
            GoRoute(
              path: '/crear-reporte-incidencia',
              builder: (context, state) => const CrearReporteIncidenciaScreen(),
            ),
            GoRoute(
              path: '/manuales',
              builder: (context, state) => const ManualesScreen(),
            ),
            GoRoute(
              path: '/gestion-manuales',
              builder: (context, state) => const GestionManualesScreen(),
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
              path: '/crear-ticket',
              builder: (context, state) => const CrearTicketScreen(),
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
        GoRoute(
          path: '/reporte-incidencia-detalle',
          builder: (context, state) => ReporteIncidenciaDetalleScreen(reporte: state.extra as ReporteIncidencia),
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