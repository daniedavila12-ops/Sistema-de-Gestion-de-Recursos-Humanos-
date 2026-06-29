class Usuario {
  final int id;
  final String nombre;
  final String email;
  final int? rolId;

  Usuario({
    required this.id,
    required this.nombre,
    required this.email,
    this.rolId,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
      email: json['email'] ?? '',
      rolId: json['rol_id'] ?? json['rol'],
    );
  }

  // Si se necesita un mapa para enviar a una API, por ejemplo
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'email': email,
      'rol_id': rolId,
    };
  }
}
