// CREADO POR: DANIEL INNOVA

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/asistencia_provider.dart';
import '../../../shared/widgets/innova_card.dart';

class AsistenciaScreen extends ConsumerWidget {
  const AsistenciaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vacacionesAsyncValue = ref.watch(vacacionesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tiempo y Asistencia'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
      ),
      body: vacacionesAsyncValue.when(
        data: (vacaciones) {
          if (vacaciones.isEmpty) {
            return const Center(child: Text('No hay solicitudes de vacaciones.'));
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(vacacionesProvider.future),
            child: ListView.builder(
              itemCount: vacaciones.length,
              itemBuilder: (context, index) {
                final vacacion = vacaciones[index];
                return InnovaCard(
                  title: 'Solicitud de Vacaciones #${vacacion.id}',
                  subtitle: 'Del: ${vacacion.fechaInicio} al ${vacacion.fechaFin}\nEstado: ${vacacion.estado}',
                  icon: Icons.event_available,
                  onTap: () {
                    // Navegar a los detalles de la solicitud
                  },
                );
              },
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 60),
              const SizedBox(height: 16),
              Text('Error de conexión:\n$error', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(vacacionesProvider.future),
                child: const Text('Reintentar'),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue.shade800,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          // Lógica para registrar nueva solicitud de vacaciones
        },
      ),
    );
  }
}