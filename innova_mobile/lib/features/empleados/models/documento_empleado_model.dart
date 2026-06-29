class DocumentoEmpleado {
  final int id;
  final int empleadoId;
  final String titulo;
  final String tipo;
  final String archivoUrl;
  final String? creadoPorNombre;
  final String? modificadoPorNombre;
  final DateTime? fechaCreacion;

  DocumentoEmpleado({
    required this.id,
    required this.empleadoId,
    required this.titulo,
    required this.tipo,
    required this.archivoUrl,
    this.creadoPorNombre,
    this.modificadoPorNombre,
    this.fechaCreacion,
  });

  factory DocumentoEmpleado.fromJson(Map<String, dynamic> json) {
    return DocumentoEmpleado(
      id: json['id'],
      empleadoId: json['empleado_id'],
      titulo: json['titulo'] ?? '',
      tipo: json['tipo'] ?? 'Documento General',
      archivoUrl: json['archivo_url'] ?? '',
      creadoPorNombre: json['creadoPorNombre'],
      modificadoPorNombre: json['modificadoPorNombre'],
      fechaCreacion: json['fecha_creacion'] != null
          ? DateTime.tryParse(json['fecha_creacion'])
          : null,
    );
  }
}
