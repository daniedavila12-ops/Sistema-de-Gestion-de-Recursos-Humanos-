class Candidato {
  final int id;
  final String nombreCompleto;
  final String correo;
  final String telefono;
  final String puestoAplicado;
  final String cvUrl;
  final String estado;
  final DateTime? createdAt;

  Candidato({
    required this.id,
    required this.nombreCompleto,
    required this.correo,
    required this.telefono,
    required this.puestoAplicado,
    required this.cvUrl,
    required this.estado,
    this.createdAt,
  });

  factory Candidato.fromJson(Map<String, dynamic> json) {
    return Candidato(
      id: json['id'],
      nombreCompleto: json['nombre_completo'] ?? '',
      correo: json['correo'] ?? '',
      telefono: json['telefono'] ?? '',
      puestoAplicado: json['puesto_aplicado'] ?? '',
      cvUrl: json['cv_url'] ?? '',
      estado: json['estado'] ?? 'Recibido',
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre_completo': nombreCompleto,
      'correo': correo,
      'telefono': telefono,
      'puesto_aplicado': puestoAplicado,
      'cv_url': cvUrl,
      'estado': estado,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  Candidato copyWith({
    int? id,
    String? nombreCompleto,
    String? correo,
    String? telefono,
    String? puestoAplicado,
    String? cvUrl,
    String? estado,
    DateTime? createdAt,
  }) {
    return Candidato(
      id: id ?? this.id,
      nombreCompleto: nombreCompleto ?? this.nombreCompleto,
      correo: correo ?? this.correo,
      telefono: telefono ?? this.telefono,
      puestoAplicado: puestoAplicado ?? this.puestoAplicado,
      cvUrl: cvUrl ?? this.cvUrl,
      estado: estado ?? this.estado,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
