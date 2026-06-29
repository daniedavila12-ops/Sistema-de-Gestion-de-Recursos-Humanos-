import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/log_provider.dart';
import '../widgets/log_card.dart';

class LogsScreen extends ConsumerWidget {
  const LogsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredLogsAsync = ref.watch(filteredLogsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Logs de Sistema'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) {
                ref.read(logSearchQueryProvider.notifier).state = value;
              },
              decoration: InputDecoration(
                hintText: 'Buscar por usuario, acción o módulo...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
          ),
          Expanded(
            child: filteredLogsAsync.when(
              data: (logs) {
                if (logs.isEmpty) {
                  return const Center(child: Text('No se encontraron registros.', style: TextStyle(fontStyle: FontStyle.italic)));
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(logsProvider);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: logs.length,
                    itemBuilder: (context, index) {
                      return LogCard(logData: logs[index]);
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }
}
