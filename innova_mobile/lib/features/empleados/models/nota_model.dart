class Nota {
  final int id;
  final int empleadoId;
  final String asunto;
  final String descripcion;
  final String? documento;
  final String? creadoPorNombre;
  final String? modificadoPorNombre;
  final DateTime? fechaCreacion;
  final DateTime? fechaModificacion;

  Nota({
    required this.id,
    required this.empleadoId,
    required this.asunto,
    required this.descripcion,
    this.documento,
    this.creadoPorNombre,
    this.modificadoPorNombre,
    this.fechaCreacion,
    this.fechaModificacion,
  });

  factory Nota.fromJson(Map<String, dynamic> json) {
    return Nota(
      id: json['id'],
      empleadoId: json['empleado_id'],
      asunto: json['asunto'] ?? '',
      descripcion: json['descripcion'] ?? '',
      documento: json['documento'],
      creadoPorNombre: json['creadoPorNombre'],
      modificadoPorNombre: json['modificadoPorNombre'],
      fechaCreacion: json['fechaCreacion'] != null
          ? DateTime.tryParse(json['fechaCreacion'])
          : null,
      fechaModificacion: json['fechaModificacion'] != null
          ? DateTime.tryParse(json['fechaModificacion'])
          : null,
    );
  }
}
