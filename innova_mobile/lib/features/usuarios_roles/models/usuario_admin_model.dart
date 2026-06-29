class UsuarioAdmin {
  final int id;
  final String nombre;
  final String email;
  final bool estado;
  final int? rolId;
  final String? rolNombre;
  final DateTime? ultimoLogin;
  final int incidentesPendientes;

  UsuarioAdmin({
    required this.id,
    required this.nombre,
    required this.email,
    required this.estado,
    this.rolId,
    this.rolNombre,
    this.ultimoLogin,
    this.incidentesPendientes = 0,
  });

  factory UsuarioAdmin.fromJson(Map<String, dynamic> json) {
    return UsuarioAdmin(
      id: json['id'],
      nombre: json['nombre'] ?? '',
      email: json['email'] ?? '',
      estado: json['estado'] == 1 || json['estado'] == true,
      rolId: json['rol_id'],
      rolNombre: json['rol_nombre'],
      ultimoLogin: json['ultimoLogin'] != null ? DateTime.parse(json['ultimoLogin']) : null,
      incidentesPendientes: json['incidentes_pendientes'] ?? 0,
    );
  }
}
