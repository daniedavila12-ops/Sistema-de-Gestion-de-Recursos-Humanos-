// CREADO POR: DANIEL INNOVA

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ticket_model.dart';
import 'ticket_provider.dart';

// Definimos el estado del filtro
class TicketsFilterState {
  final String searchQuery;
  final String activeFilter; // 'todas', 'misEntradas', 'abierto', 'resuelto', etc.
  final String priorityFilter; // 'todas', 'urgente', 'alta', 'media', 'baja'
  final String sortOption; // 'reciente', 'antiguo', 'prioridad'

  TicketsFilterState({
    this.searchQuery = '',
    this.activeFilter = 'todas',
    this.priorityFilter = 'todas',
    this.sortOption = 'reciente',
  });

  TicketsFilterState copyWith({
    String? searchQuery,
    String? activeFilter,
    String? priorityFilter,
    String? sortOption,
  }) {
    return TicketsFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      activeFilter: activeFilter ?? this.activeFilter,
      priorityFilter: priorityFilter ?? this.priorityFilter,
      sortOption: sortOption ?? this.sortOption,
    );
  }
}

// StateNotifier para manejar el estado del filtro
class TicketsFilterNotifier extends StateNotifier<TicketsFilterState> {
  TicketsFilterNotifier() : super(TicketsFilterState());

  void setSearchQuery(String query) => state = state.copyWith(searchQuery: query);
  void setActiveFilter(String filter) => state = state.copyWith(activeFilter: filter);
  void setPriorityFilter(String priority) => state = state.copyWith(priorityFilter: priority);
  void setSortOption(String sort) => state = state.copyWith(sortOption: sort);
}

final ticketsFilterProvider = StateNotifierProvider<TicketsFilterNotifier, TicketsFilterState>((ref) {
  return TicketsFilterNotifier();
});

// El provider filtrado combina los tickets de la API con los filtros locales
final filteredTicketsProvider = Provider<AsyncValue<List<Ticket>>>((ref) {
  final ticketsAsync = ref.watch(ticketsProvider);
  final filters = ref.watch(ticketsFilterProvider);

  return ticketsAsync.whenData((tickets) {
    var data = List<Ticket>.from(tickets);

    // 1. Filtro lateral / chips (Estado)
    if (filters.activeFilter != 'todas') {
      if (['abierto', 'en progreso', 'pendiente', 'resuelto', 'cerrado'].contains(filters.activeFilter)) {
        data = data.where((t) => t.estado.toLowerCase() == filters.activeFilter).toList();
      }
    }

    // 2. Filtro de Prioridad
    if (filters.priorityFilter != 'todas') {
      data = data.where((t) => t.prioridad.toLowerCase() == filters.priorityFilter).toList();
    }

    // 3. Filtro de Búsqueda
    if (filters.searchQuery.isNotEmpty) {
      final q = filters.searchQuery.toLowerCase();
      data = data.where((t) => 
        t.tema.toLowerCase().contains(q) || 
        t.descripcion.toLowerCase().contains(q) ||
        (t.id.toString()).contains(q) ||
        t.categoria.toLowerCase().contains(q)
      ).toList();
    }

    // 4. Ordenamiento
    data.sort((a, b) {
      bool isAClosed = a.estado.toLowerCase() == 'resuelto' || a.estado.toLowerCase() == 'cerrado';
      bool isBClosed = b.estado.toLowerCase() == 'resuelto' || b.estado.toLowerCase() == 'cerrado';
      
      if (isAClosed && !isBClosed) return 1;
      if (!isAClosed && isBClosed) return -1;

      if (filters.sortOption == 'reciente') {
        final dA = a.fechaCreacion ?? DateTime(1970);
        final dB = b.fechaCreacion ?? DateTime(1970);
        return dB.compareTo(dA);
      } else if (filters.sortOption == 'antiguo') {
        final dA = a.fechaCreacion ?? DateTime(1970);
        final dB = b.fechaCreacion ?? DateTime(1970);
        return dA.compareTo(dB);
      } else if (filters.sortOption == 'prioridad') {
        int getWeight(String p) {
          switch (p.toLowerCase()) {
            case 'urgente': return 4;
            case 'alta': return 3;
            case 'media': return 2;
            case 'baja': return 1;
            default: return 0;
          }
        }
        return getWeight(b.prioridad).compareTo(getWeight(a.prioridad));
      }
      return 0;
    });

    return data;
  });
});
