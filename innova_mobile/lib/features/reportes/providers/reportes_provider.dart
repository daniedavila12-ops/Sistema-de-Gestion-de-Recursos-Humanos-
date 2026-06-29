// CREADO POR: DANIEL INNOVA
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:innova_mobile/core/api/api_client.dart';
import '../models/reporte_stats_model.dart';

class ReportesState {
  final bool isLoading;
  final String? error;
  final ReporteStats? stats;
  final List<dynamic> empleadosDetalles;

  ReportesState({
    this.isLoading = false,
    this.error,
    this.stats,
    this.empleadosDetalles = const [],
  });

  ReportesState copyWith({
    bool? isLoading,
    String? error,
    ReporteStats? stats,
    List<dynamic>? empleadosDetalles,
  }) {
    return ReportesState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      stats: stats ?? this.stats,
      empleadosDetalles: empleadosDetalles ?? this.empleadosDetalles,
    );
  }

  // Helpers for charts
  Map<String, int> getGenderDistribution() {
    int m = 0;
    int f = 0;
    for (var e in empleadosDetalles) {
      String genero = (e['genero'] ?? '').toString().toLowerCase().trim();
      if (['m', 'masculino', 'hombre'].contains(genero)) {
        m++;
      } else if (['f', 'femenino', 'mujer'].contains(genero)) {
        f++;
      }
    }
    return {'Masculino': m, 'Femenino': f};
  }

  Map<String, int> getAgeDistribution() {
    int g1 = 0, g2 = 0, g3 = 0, g4 = 0;
    for (var e in empleadosDetalles) {
      if (e['fecha_nacimiento'] != null) {
        DateTime birthDate = DateTime.parse(e['fecha_nacimiento']);
        int age = DateTime.now().year - birthDate.year;
        if (DateTime.now().month < birthDate.month || (DateTime.now().month == birthDate.month && DateTime.now().day < birthDate.day)) {
          age--;
        }
        if (age >= 18 && age <= 25) {
          g1++;
        } else if (age >= 26 && age <= 35) {
          g2++;
        } else if (age >= 36 && age <= 45) {
          g3++;
        } else if (age > 45) {
          g4++;
        }
      }
    }
    return {'18-25': g1, '26-35': g2, '36-45': g3, '+45': g4};
  }
}

class ReportesNotifier extends StateNotifier<ReportesState> {
  ReportesNotifier() : super(ReportesState()) {
    fetchData();
  }

  Future<void> fetchData() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final resStats = await apiClient.get('/stats/resumen');
      final resEmpleados = await apiClient.get('/stats/empleados-detalles');
      
      final stats = ReporteStats.fromJson(resStats.data);
      final detalles = List<dynamic>.from(resEmpleados.data);
      
      state = state.copyWith(isLoading: false, stats: stats, empleadosDetalles: detalles);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Error al cargar estadísticas de reportes: $e');
    }
  }
}

final reportesProvider = StateNotifierProvider<ReportesNotifier, ReportesState>((ref) {
  return ReportesNotifier();
});
