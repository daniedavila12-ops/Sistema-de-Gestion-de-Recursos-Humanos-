// CREADO POR: DANIEL INNOVA

class Reporte {
  final int id;
  final String titulo;
  final String descripcion;
  final String fecha;

  Reporte({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.fecha,
  });

  factory Reporte.fromJson(Map<String, dynamic> json) {
    return Reporte(
      id: json['id'] ?? 0,
      titulo: json['titulo'] ?? 'Sin título',
      descripcion: json['descripcion'] ?? 'Sin descripción',
      fecha: json['fecha'] ?? 'Fecha no disponible',
    );
  }
}