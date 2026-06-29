// CREADO POR: DANIEL INNOVA

class ReporteStats {
  final int total;
  final int activos;
  final int inactivos;
  final int tickets;
  final int incidencias;
  final int categorias;
  final int cumpleaneros;
  final int vencimientos;
  final int deVacaciones;
  final int faltasMes;
  final int docLegales;

  ReporteStats({
    required this.total,
    required this.activos,
    required this.inactivos,
    required this.tickets,
    required this.incidencias,
    required this.categorias,
    required this.cumpleaneros,
    required this.vencimientos,
    required this.deVacaciones,
    required this.faltasMes,
    required this.docLegales,
  });

  factory ReporteStats.fromJson(Map<String, dynamic> json) {
    return ReporteStats(
      total: json['total'] ?? 0,
      activos: json['activos'] ?? 0,
      inactivos: json['inactivos'] ?? 0,
      tickets: json['tickets'] ?? 0,
      incidencias: json['incidencias'] ?? 0,
      categorias: json['categorias'] ?? 0,
      cumpleaneros: json['cumpleaneros'] ?? 0,
      vencimientos: json['vencimientos'] ?? 0,
      deVacaciones: json['de_vacaciones'] ?? 0,
      faltasMes: json['faltas_mes'] ?? 0,
      docLegales: json['doc_legales'] ?? 0,
    );
  }
}
