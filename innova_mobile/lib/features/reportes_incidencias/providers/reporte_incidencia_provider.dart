// CREADO POR: DANIEL INNOVA

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/reporte_incidencia_repository.dart';
import '../models/reporte_incidencia_model.dart';
import '../../auth/models/usuario_model.dart';
import '../../auth/providers/auth_provider.dart';

// Proveedor del repositorio
final reporteIncidenciaRepositoryProvider = Provider<ReporteIncidenciaRepository>((ref) {
  return ReporteIncidenciaRepository();
});

// FutureProvider para listar los reportes
final reportesIncidenciaProvider = FutureProvider<List<ReporteIncidencia>>((ref) async {
  final repository = ref.watch(reporteIncidenciaRepositoryProvider);
  return repository.getReportes();
});

// FutureProvider para obtener los detalles de un reporte específico
final reporteIncidenciaDetailProvider = FutureProvider.family<ReporteIncidencia, int>((ref, id) async {
  final repository = ref.watch(reporteIncidenciaRepositoryProvider);
  return repository.getReporteById(id);
});

// Providers de Estado para Filtros y Búsqueda
final reporteSearchQueryProvider = StateProvider<String>((ref) => '');
final reporteStatusFilterProvider = StateProvider<String>((ref) => 'Todas');
final reportePriorityFilterProvider = StateProvider<String>((ref) => 'todas');
final reporteSortOptionProvider = StateProvider<String>((ref) => 'reciente');
final reporteVistaFilterProvider = StateProvider<String>((ref) => 'todas');
final reporteCategoriaFilterProvider = StateProvider<String>((ref) => 'Todas');

// Proveedor para cargar la lista de categorías
final categoriasReporteProvider = FutureProvider<List<CategoriaReporte>>((ref) async {
  final repository = ref.watch(reporteIncidenciaRepositoryProvider);
  return repository.getCategorias();
});

// Provider que combina la data cruda con los filtros
final filteredReportesIncidenciaProvider = Provider<AsyncValue<List<ReporteIncidencia>>>((ref) {
  final reportesAsync = ref.watch(reportesIncidenciaProvider);
  final searchQuery = ref.watch(reporteSearchQueryProvider).toLowerCase();
  final statusFilter = ref.watch(reporteStatusFilterProvider);
  final priorityFilter = ref.watch(reportePriorityFilterProvider);
  final sortOption = ref.watch(reporteSortOptionProvider);
  final vistaFilter = ref.watch(reporteVistaFilterProvider);
  final categoriaFilter = ref.watch(reporteCategoriaFilterProvider);
  final authState = ref.watch(authProvider);

  return reportesAsync.whenData((reportes) {
    var filtered = reportes.where((r) {
      final user = authState.user;
      
      // Filtrar por nivel de acceso (como en la web: solo Admin/RRHH ven todo, los demás ven los propios o asignados)
      if (user != null && user.rolId != null && user.rolId != 1 && user.rolId != 2) {
        if (r.jefeReporta != user.nombre && r.asignadoUsuarioId != user.id) {
          return false;
        }
      }

      // Filtro de Vista
      if (vistaFilter != 'todas') {
        if (vistaFilter == 'misEntradas') {
          if (r.jefeReporta != user?.nombre) return false;
        } else if (vistaFilter == 'asignado') {
          if (r.asignadoUsuarioId != user?.id) return false;
        } else if (vistaFilter == 'sinAsignacion') {
          if (r.asignadoUsuarioId != null) return false;
        }
      }

      // Filtro de Categoría
      if (categoriaFilter != 'Todas') {
        if (r.categoria != categoriaFilter) return false;
      }

      // Filtro de estado
      if (statusFilter != 'Todas') {
        if (statusFilter == 'Cancelado') {
          if (r.estado != 'Cancelado' && r.estado != 'Desestimado') return false;
        } else if (statusFilter == 'Pendiente') {
          if (r.estado != 'Pendiente' && r.estado != '') return false;
        } else {
          if (r.estado != statusFilter) return false;
        }
      }

      // Filtro de prioridad
      if (priorityFilter != 'todas') {
        final prio = r.prioridad.toLowerCase();
        if (prio != priorityFilter.toLowerCase()) return false;
      }

      // Búsqueda
      if (searchQuery.isNotEmpty) {
        final matchTema = r.tema.toLowerCase().contains(searchQuery);
        final matchDesc = r.descripcion.toLowerCase().contains(searchQuery);
        final matchNombre = (r.empleadoNombre ?? '').toLowerCase().contains(searchQuery);
        final matchAsignado = (r.asignadoUsuarioNombre ?? '').toLowerCase().contains(searchQuery);
        final matchIdentidad = (r.identidad ?? '').toLowerCase().contains(searchQuery);
        
        if (!matchTema && !matchDesc && !matchNombre && !matchAsignado && !matchIdentidad) {
          return false;
        }
      }

      return true;
    }).toList();

    // Ordenamiento
    filtered.sort((a, b) {
      bool isAClosed = ['resuelto', 'cerrado', 'cancelado', 'desestimado'].contains(a.estado.toLowerCase());
      bool isBClosed = ['resuelto', 'cerrado', 'cancelado', 'desestimado'].contains(b.estado.toLowerCase());
      
      if (isAClosed && !isBClosed) return 1;
      if (!isAClosed && isBClosed) return -1;

      if (sortOption == 'reciente') {
        final dateA = a.fechaCreacion ?? DateTime.fromMillisecondsSinceEpoch(0);
        final dateB = b.fechaCreacion ?? DateTime.fromMillisecondsSinceEpoch(0);
        return dateB.compareTo(dateA);
      } else if (sortOption == 'antiguo') {
        final dateA = a.fechaCreacion ?? DateTime.fromMillisecondsSinceEpoch(0);
        final dateB = b.fechaCreacion ?? DateTime.fromMillisecondsSinceEpoch(0);
        return dateA.compareTo(dateB);
      } else if (sortOption == 'prioridad') {
        int weight(String p) {
          final lp = p.toLowerCase();
          if (lp == 'urgente') return 4;
          if (lp == 'alta') return 3;
          if (lp == 'media') return 2;
          if (lp == 'baja') return 1;
          return 0;
        }
        final wa = weight(a.prioridad);
        final wb = weight(b.prioridad);
        return wb.compareTo(wa);
      } else if (sortOption == 'actualizado') {
        final dateA = a.updatedAt ?? a.fechaCreacion ?? DateTime.fromMillisecondsSinceEpoch(0);
        final dateB = b.updatedAt ?? b.fechaCreacion ?? DateTime.fromMillisecondsSinceEpoch(0);
        return dateB.compareTo(dateA);
      }
      return 0;
    });

    return filtered;
  });
});

// Proveedor para cargar respuestas de un reporte específico (Tiempo real vía polling)
final respuestasReporteProvider = StreamProvider.autoDispose.family<List<RespuestaReporteIncidencia>, int>((ref, reporteId) async* {
  final repository = ref.watch(reporteIncidenciaRepositoryProvider);
  
  // 1. Emitir la primera respuesta de inmediato
  yield await repository.getRespuestas(reporteId);
  
  // 2. Configurar polling cada 3 segundos
  final stream = Stream.periodic(const Duration(seconds: 3), (_) async {
    return await repository.getRespuestas(reporteId);
  }).asyncMap((event) => event);
  
  await for (final value in stream) {
    yield value;
  }
});

// Proveedor para cargar la lista de usuarios RRHH/Admins
final usuariosRRHHProvider = FutureProvider<List<Usuario>>((ref) async {
  final repository = ref.watch(reporteIncidenciaRepositoryProvider);
  return repository.getUsuariosRRHH();
});
