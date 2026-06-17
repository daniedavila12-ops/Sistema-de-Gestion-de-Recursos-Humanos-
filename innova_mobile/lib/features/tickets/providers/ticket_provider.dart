// CREADO POR: DANIEL INNOVA

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/ticket_repository.dart';
import '../models/ticket_model.dart';

// Proveedor del repositorio
final ticketRepositoryProvider = Provider<TicketRepository>((ref) {
  return TicketRepository();
});

// FutureProvider para listar los tickets
final ticketsProvider = FutureProvider<List<Ticket>>((ref) async {
  final repository = ref.watch(ticketRepositoryProvider);
  return repository.getTickets();
});

// FutureProvider para obtener los detalles de un ticket específico
final ticketDetailProvider = FutureProvider.family<Ticket, int>((ref, id) async {
  final repository = ref.watch(ticketRepositoryProvider);
  return repository.getTicketById(id);
});

// FutureProvider para obtener las respuestas de un ticket
final ticketRespuestasProvider = FutureProvider.family<List<RespuestaTicket>, int>((ref, ticketId) async {
  final repository = ref.watch(ticketRepositoryProvider);
  return repository.getRespuestas(ticketId);
});
