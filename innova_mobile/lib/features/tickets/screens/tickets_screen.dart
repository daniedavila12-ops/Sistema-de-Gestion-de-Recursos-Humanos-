// CREADO POR: DANIEL INNOVA

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/ticket_provider.dart';
import '../../../shared/widgets/innova_card.dart';
import '../../../shared/widgets/innova_loading.dart';

class TicketsScreen extends ConsumerWidget {
  const TicketsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ticketsAsyncValue = ref.watch(ticketsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mesa de Ayuda (Tickets)'),
      ),
      body: ticketsAsyncValue.when(
        data: (tickets) {
          if (tickets.isEmpty) return const Center(child: Text('No hay tickets registrados.'));
          return RefreshIndicator(
            onRefresh: () => ref.refresh(ticketsProvider.future),
            child: ListView.builder(
              itemCount: tickets.length,
              itemBuilder: (context, index) {
                final ticket = tickets[index];
                return InnovaCard(
                  title: ticket.tema,
                  subtitle: 'Estado: ${ticket.estado} | Prioridad: ${ticket.prioridad}\nCategoría: ${ticket.categoria}',
                  icon: Icons.support_agent,
                  onTap: () {
                    // NAVEGACIÓN AL DETALLE
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          context.push('/crear-ticket').then((_) {
            ref.invalidate(ticketsProvider);
          });
        },
      ),
    );
  }
}