class LogSistema {
  final int id;
  final int? usuarioId;
  final String accion;
  final String modulo;
  final String detalles;
  final String ipAddress;
  final DateTime fechaCreacion;
  final String usuarioNombre;
  final String usuarioCorreo;

  LogSistema({
    required this.id,
    this.usuarioId,
    required this.accion,
    required this.modulo,
    required this.detalles,
    required this.ipAddress,
    required this.fechaCreacion,
    required this.usuarioNombre,
    required this.usuarioCorreo,
  });

  factory LogSistema.fromJson(Map<String, dynamic> json) {
    return LogSistema(
      id: json['id'],
      usuarioId: json['usuario_id'],
      accion: json['accion'] ?? '',
      modulo: json['modulo'] ?? 'General',
      detalles: json['detalles'] ?? 'Sin detalles',
      ipAddress: json['ip_address'] ?? '0.0.0.0',
      fechaCreacion: DateTime.parse(json['fecha_creacion']),
      usuarioNombre: json['usuario_nombre'] ?? 'Sistema',
      usuarioCorreo: json['usuario_correo'] ?? 'N/A',
    );
  }
}
