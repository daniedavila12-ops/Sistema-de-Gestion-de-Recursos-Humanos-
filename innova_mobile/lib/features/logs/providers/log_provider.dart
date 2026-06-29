import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/log_repository.dart';
import '../models/log_model.dart';

final logRepositoryProvider = Provider((ref) => LogRepository());

final logsProvider = FutureProvider.autoDispose<List<LogSistema>>((ref) async {
  final repository = ref.watch(logRepositoryProvider);
  return repository.getLogs();
});

final logSearchQueryProvider = StateProvider.autoDispose<String>((ref) => '');

final filteredLogsProvider = Provider.autoDispose<AsyncValue<List<LogSistema>>>((ref) {
  final logsAsync = ref.watch(logsProvider);
  final searchQuery = ref.watch(logSearchQueryProvider).toLowerCase();

  return logsAsync.whenData((logs) {
    if (searchQuery.isEmpty) return logs;

    return logs.where((log) {
      return log.usuarioNombre.toLowerCase().contains(searchQuery) ||
             log.accion.toLowerCase().contains(searchQuery) ||
             log.modulo.toLowerCase().contains(searchQuery) ||
             log.detalles.toLowerCase().contains(searchQuery);
    }).toList();
  });
});
