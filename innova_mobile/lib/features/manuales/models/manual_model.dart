// CREADO POR: DANIEL INNOVA

class Manual {
  final int id;
  final String titulo;
  final String? categoria;
  final String? descripcion;
  final String? archivo;
  final String? tamano;
  final int? creadoPor;
  final String? creadoPorNombre;
  final DateTime? fechaCreacion;

  Manual({
    required this.id,
    required this.titulo,
    this.categoria,
    this.descripcion,
    this.archivo,
    this.tamano,
    this.creadoPor,
    this.creadoPorNombre,
    this.fechaCreacion,
  });

  factory Manual.fromJson(Map<String, dynamic> json) {
    return Manual(
      id: json['id'] ?? 0,
      titulo: json['titulo'] ?? 'Sin Título',
      categoria: json['categoria'],
      descripcion: json['descripcion'],
      archivo: json['archivo'],
      tamano: json['tamano'],
      creadoPor: json['creado_por'],
      creadoPorNombre: json['creadoPorNombre'],
      fechaCreacion: json['fecha_creacion'] != null ? DateTime.tryParse(json['fecha_creacion']) : null,
    );
  }
}
