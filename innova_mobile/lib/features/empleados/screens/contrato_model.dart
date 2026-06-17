// CREADO POR: DANIEL INNOVA

class Contrato {
  final int id;
  final int empleadoId;
  final String tipoContrato;
  final DateTime fechaInicio;
  final DateTime? fechaFin;
  final double salario;
  final String puesto;
  final String? notas;
  final DateTime fechaCreacion;
  final String estado;
  final DateTime? fechaSalida;
  final String? archivo;
  final String? creadoPorNombre;
  final DateTime? fechaModificacion;
  final String? modificadoPorNombre;

  Contrato({
    required this.id,
    required this.empleadoId,
    required this.tipoContrato,
    required this.fechaInicio,
    this.fechaFin,
    required this.salario,
    required this.puesto,
    this.notas,
    required this.fechaCreacion,
    required this.estado,
    this.fechaSalida,
    this.archivo,
    this.creadoPorNombre,
    this.fechaModificacion,
    this.modificadoPorNombre,
  });

  factory Contrato.fromJson(Map<String, dynamic> json) {
    return Contrato(
      id: json['id'] ?? 0,
      empleadoId: json['empleado_id'] ?? json['empleadoId'] ?? 0,
      tipoContrato: json['tipo_contrato'] ?? json['tipoContrato'] ?? 'No especificado',
      fechaInicio: DateTime.parse(json['fecha_inicio'] ?? json['fechaInicio']),
      fechaFin: json['fecha_fin'] != null ? DateTime.parse(json['fecha_fin']) : (json['fechaFinal'] != null ? DateTime.parse(json['fechaFinal']) : null),
      salario: (json['salario'] as num?)?.toDouble() ?? 0.0,
      puesto: json['puesto'] ?? 'No especificado',
      notas: json['notas'] ?? json['observacion'],
      fechaCreacion: DateTime.parse(json['fecha_creacion'] ?? json['fechaCreacion']),
      estado: json['estado'] ?? 'Activo',
      fechaSalida: json['fecha_salida'] != null ? DateTime.parse(json['fecha_salida']) : (json['fechaSalida'] != null ? DateTime.parse(json['fechaSalida']) : null),
      archivo: json['archivo'],
      creadoPorNombre: json['creadoPorNombre'],
      fechaModificacion: json['fecha_modificacion'] != null ? DateTime.parse(json['fecha_modificacion']) : (json['fechaModificacion'] != null ? DateTime.parse(json['fechaModificacion']) : null),
      modificadoPorNombre: json['modificadoPorNombre'],
    );
  }
}