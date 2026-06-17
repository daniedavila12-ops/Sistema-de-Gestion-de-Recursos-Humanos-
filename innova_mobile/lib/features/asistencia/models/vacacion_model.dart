// CREADO POR: DANIEL INNOVA

class Vacacion {
  final int id;
  final String fechaInicio;
  final String fechaFin;
  final String estado;

  Vacacion({
    required this.id,
    required this.fechaInicio,
    required this.fechaFin,
    required this.estado,
  });

  factory Vacacion.fromJson(Map<String, dynamic> json) {
    return Vacacion(
      id: json['id'] ?? 0,
      fechaInicio: json['fecha_inicio'] ?? 'Sin fecha',
      fechaFin: json['fecha_fin'] ?? 'Sin fecha',
      estado: json['estado'] ?? 'Pendiente',
    );
  }
}