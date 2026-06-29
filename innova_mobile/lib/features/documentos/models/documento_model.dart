// CREADO POR: DANIEL INNOVA

class ArchivoDocumento {
  final int id;
  final String archivoUrl;
  final String tamano;

  ArchivoDocumento({
    required this.id,
    required this.archivoUrl,
    required this.tamano,
  });

  factory ArchivoDocumento.fromJson(Map<String, dynamic> json) {
    return ArchivoDocumento(
      id: json['id'] ?? 0,
      archivoUrl: json['archivo_url'] ?? '',
      tamano: json['tamano'] ?? '',
    );
  }
}

class LinkDocumento {
  final int id;
  final String linkUrl;

  LinkDocumento({
    required this.id,
    required this.linkUrl,
  });

  factory LinkDocumento.fromJson(Map<String, dynamic> json) {
    return LinkDocumento(
      id: json['id'] ?? 0,
      linkUrl: json['link_url'] ?? '',
    );
  }
}

class Documento {
  final int id;
  final String titulo;
  final String descripcion;
  final String categoria;
  final String fechaCreacion;
  final String creadoPorNombre;
  
  // Archivo y Link legacy por retrocompatibilidad
  final String? archivoLegacy;
  final String? tamanoLegacy;
  final String? linkLegacy;

  final List<ArchivoDocumento> archivos;
  final List<LinkDocumento> links;

  Documento({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.categoria,
    required this.fechaCreacion,
    required this.creadoPorNombre,
    this.archivoLegacy,
    this.tamanoLegacy,
    this.linkLegacy,
    required this.archivos,
    required this.links,
  });

  factory Documento.fromJson(Map<String, dynamic> json) {
    return Documento(
      id: json['id'] ?? 0,
      titulo: json['titulo'] ?? 'Sin título',
      descripcion: json['descripcion'] ?? '',
      categoria: json['categoria'] ?? 'General',
      fechaCreacion: json['fecha_creacion'] ?? '',
      creadoPorNombre: json['creadoPorNombre'] ?? '',
      archivoLegacy: json['archivo'],
      tamanoLegacy: json['tamano'],
      linkLegacy: json['link_web'],
      archivos: (json['archivos'] as List<dynamic>?)
              ?.map((e) => ArchivoDocumento.fromJson(e))
              .toList() ??
          [],
      links: (json['links'] as List<dynamic>?)
              ?.map((e) => LinkDocumento.fromJson(e))
              .toList() ??
          [],
    );
  }
}