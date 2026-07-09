// CREADO POR: DANIEL INNOVA
// MODIFICADO: DANIEL INNOVA

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/ticket_provider.dart';
import '../providers/tickets_filter_provider.dart';
import '../widgets/ticket_card.dart';
import '../../../shared/widgets/innova_loading.dart';
import '../../../core/services/socket_service.dart';

class TicketsScreen extends ConsumerStatefulWidget {
  const TicketsScreen({super.key});

  @override
  ConsumerState<TicketsScreen> createState() => _TicketsScreenState();
}

class _TicketsScreenState extends ConsumerState<TicketsScreen> {
  @override
  void initState() {
    super.initState();
    SocketService().socket.on('nuevo_ticket', _onRefreshTickets);
    SocketService().socket.on('tickets_actualizados', _onRefreshTickets);
  }

  @override
  void dispose() {
    SocketService().socket.off('nuevo_ticket', _onRefreshTickets);
    SocketService().socket.off('tickets_actualizados', _onRefreshTickets);
    super.dispose();
  }

  void _onRefreshTickets(dynamic data) {
    if (mounted) {
      ref.invalidate(ticketsProvider);
    }
  }

  void _showSortPriorityBottomSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        final currentFilter = ref.watch(ticketsFilterProvider);
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Filtros Avanzados', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              const Text('Prioridad', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              Wrap(
                spacing: 8,
                children: ['todas', 'urgente', 'alta', 'media', 'baja'].map((p) {
                  return ChoiceChip(
                    label: Text(p.toUpperCase(), style: const TextStyle(fontSize: 12)),
                    selected: currentFilter.priorityFilter == p,
                    onSelected: (selected) {
                      if(selected) {
                        ref.read(ticketsFilterProvider.notifier).setPriorityFilter(p);
                        Navigator.pop(ctx);
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              const Text('Ordenar por', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              Wrap(
                spacing: 8,
                children: [
                  {'val': 'reciente', 'label': 'Más Reciente'},
                  {'val': 'antiguo', 'label': 'Más Antiguo'},
                  {'val': 'prioridad', 'label': 'Por Prioridad'},
                ].map((opt) {
                  return ChoiceChip(
                    label: Text(opt['label']!, style: const TextStyle(fontSize: 12)),
                    selected: currentFilter.sortOption == opt['val'],
                    onSelected: (selected) {
                      if(selected) {
                        ref.read(ticketsFilterProvider.notifier).setSortOption(opt['val']!);
                        Navigator.pop(ctx);
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final ticketsAsyncValue = ref.watch(filteredTicketsProvider);
    final currentFilter = ref.watch(ticketsFilterProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Módulo de Tickets'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showSortPriorityBottomSheet(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(ticketsProvider.future),
          ),
        ],
      ),
      body: Column(
        children: [
          // Búsqueda
          Container(
            color: Theme.of(context).appBarTheme.backgroundColor ?? Theme.of(context).primaryColor,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              onChanged: (val) => ref.read(ticketsFilterProvider.notifier).setSearchQuery(val),
              decoration: InputDecoration(
                hintText: 'Buscador Tickets de Registro...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
          
          // Chips de Estado
          Container(
            color: Colors.white,
            width: double.infinity,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  {'val': 'todas', 'label': 'Todas'},
                  {'val': 'abierto', 'label': 'Abierto'},
                  {'val': 'en progreso', 'label': 'En Progreso'},
                  {'val': 'pendiente', 'label': 'Pendiente'},
                  {'val': 'resuelto', 'label': 'Resuelto'},
                  {'val': 'cerrado', 'label': 'Cerrado'},
                ].map((estado) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(estado['label']!),
                      selected: currentFilter.activeFilter == estado['val'],
                      onSelected: (selected) {
                        if (selected) ref.read(ticketsFilterProvider.notifier).setActiveFilter(estado['val']!);
                      },
                      selectedColor: Theme.of(context).primaryColor.withValues(alpha: 0.15),
                      labelStyle: TextStyle(
                        color: currentFilter.activeFilter == estado['val'] ? Theme.of(context).primaryColor : Colors.black87,
                        fontWeight: currentFilter.activeFilter == estado['val'] ? FontWeight.bold : FontWeight.normal
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          
          // Lista de Tickets
          Expanded(
            child: ticketsAsyncValue.when(
              data: (tickets) {
                if (tickets.isEmpty) return const Center(child: Text('No se encontraron tickets.', style: TextStyle(color: Colors.grey)));
                return RefreshIndicator(
                  onRefresh: () => ref.refresh(ticketsProvider.future),
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 80),
                    itemCount: tickets.length,
                    itemBuilder: (context, index) {
                      final ticket = tickets[index];
                      return TicketCard(
                        ticket: ticket,
                        onTap: () {
                          context.push('/ticket', extra: ticket);
                        },
                      );
                    },
                  ),
                );
              },
              loading: () => const InnovaLoading(mensaje: 'Cargando tickets...'),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 60),
                    const SizedBox(height: 16),
                    Text('Ocurrió un error:\n$error', textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.refresh(ticketsProvider.future),
                      child: const Text('Reintentar'),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Theme.of(context).primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('NUEVA SOLICITUD', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: () {
          context.push('/crear-ticket').then((_) {
            ref.invalidate(ticketsProvider);
          });
        },
      ),
    );
  }
}