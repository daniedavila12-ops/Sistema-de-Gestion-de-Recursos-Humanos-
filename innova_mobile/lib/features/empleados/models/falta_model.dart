class Falta {
  final int id;
  final int empleadoId;
  final DateTime fecha;
  final String motivo;
  final String? sancion;
  final String? documento;
  final String? creadoPorNombre;
  final String? modificadoPorNombre;
  final DateTime? fechaCreacion;
  final DateTime? fechaModificacion;

  Falta({
    required this.id,
    required this.empleadoId,
    required this.fecha,
    required this.motivo,
    this.sancion,
    this.documento,
    this.creadoPorNombre,
    this.modificadoPorNombre,
    this.fechaCreacion,
    this.fechaModificacion,
  });

  factory Falta.fromJson(Map<String, dynamic> json) {
    return Falta(
      id: json['id'],
      empleadoId: json['empleado_id'],
      fecha: DateTime.parse(json['fecha']),
      motivo: json['motivo'] ?? '',
      sancion: json['sancion'],
      documento: json['documento'],
      creadoPorNombre: json['creadoPorNombre'],
      modificadoPorNombre: json['modificadoPorNombre'],
      fechaCreacion: json['fecha_creacion'] != null
          ? DateTime.parse(json['fecha_creacion'])
          : null,
      fechaModificacion: json['fecha_modificacion'] != null
          ? DateTime.parse(json['fecha_modificacion'])
          : null,
    );
  }
}
