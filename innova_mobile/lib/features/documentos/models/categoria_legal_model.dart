// CREADO POR: DANIEL INNOVA

class CategoriaLegal {
  final int id;
  final String nombre;

  CategoriaLegal({
    required this.id,
    required this.nombre,
  });

  factory CategoriaLegal.fromJson(Map<String, dynamic> json) {
    return CategoriaLegal(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
    );
  }
}
