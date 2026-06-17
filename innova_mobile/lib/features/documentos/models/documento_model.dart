// CREADO POR: DANIEL INNOVA

class Documento {
  final int id;
  final String titulo;
  final String tipo;
  final String urlOArchivo;

  Documento({
    required this.id,
    required this.titulo,
    required this.tipo,
    required this.urlOArchivo,
  });

  factory Documento.fromJson(Map<String, dynamic> json) {
    return Documento(
      id: json['id'] ?? 0,
      titulo: json['titulo'] ?? 'Documento sin título',
      tipo: json['tipo'] ?? 'General',
      urlOArchivo: json['url'] ?? json['archivo'] ?? '',
    );
  }
}