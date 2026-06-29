// CREADO POR: DANIEL INNOVA

import 'dart:async';
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

// StreamProvider para obtener las respuestas de un ticket (Tiempo real vía polling)
final ticketRespuestasProvider = StreamProvider.autoDispose.family<List<RespuestaTicket>, int>((ref, ticketId) async* {
  final repository = ref.watch(ticketRepositoryProvider);
  
  // 1. Emitir la primera respuesta de inmediato
  yield await repository.getRespuestas(ticketId);
  
  // 2. Configurar polling cada 3 segundos
  final stream = Stream.periodic(const Duration(seconds: 3), (_) async {
    return await repository.getRespuestas(ticketId);
  }).asyncMap((event) => event);
  
  await for (final value in stream) {
    yield value;
  }
});
