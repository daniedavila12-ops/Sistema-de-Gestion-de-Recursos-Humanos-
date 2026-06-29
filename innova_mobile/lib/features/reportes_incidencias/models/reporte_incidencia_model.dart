// CREADO POR: DANIEL INNOVA

class ReporteIncidencia {
  final int id;
  final String tema;
  final String estado;
  final String categoria;
  final String prioridad;
  final String descripcion;
  final String? archivo;
  final DateTime? fechaCreacion;
  final DateTime? updatedAt;
  
  // Solicitante (Empleado o Externo)
  final String? empleadoNombre;
  final String? empleadoApellido;
  final String? empleadoFoto;
  final String? identidad;
  final String? jefeReporta;

  // Asignado
  final int? asignadoUsuarioId;
  final String? asignadoUsuarioNombre;
  final String? asignadoUsuarioFoto;
  
  final int? respuestasCount;

  ReporteIncidencia({
    required this.id,
    required this.tema,
    required this.estado,
    required this.categoria,
    required this.prioridad,
    required this.descripcion,
    this.archivo,
    this.fechaCreacion,
    this.updatedAt,
    this.empleadoNombre,
    this.empleadoApellido,
    this.empleadoFoto,
    this.identidad,
    this.jefeReporta,
    this.asignadoUsuarioId,
    this.asignadoUsuarioNombre,
    this.asignadoUsuarioFoto,
    this.respuestasCount,
  });

  factory ReporteIncidencia.fromJson(Map<String, dynamic> json) {
    return ReporteIncidencia(
      id: json['id'] ?? 0,
      tema: json['tema'] ?? 'Sin tema',
      estado: json['estado'] ?? 'Pendiente',
      categoria: json['categoria'] ?? 'Sin categoría',
      prioridad: json['prioridad'] ?? 'Media',
      descripcion: json['descripcion'] ?? '',
      archivo: json['archivo'],
      fechaCreacion: json['fecha_creacion'] != null ? DateTime.tryParse(json['fecha_creacion']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
      empleadoNombre: json['empleado_nombre'],
      empleadoApellido: json['empleado_apellido'],
      empleadoFoto: json['empleado_foto'],
      identidad: json['identidad'],
      jefeReporta: json['jefe_reporta'],
      asignadoUsuarioId: json['asignado_usuario_id'],
      asignadoUsuarioNombre: json['asignado_usuario_nombre'],
      asignadoUsuarioFoto: json['asignado_usuario_foto'],
      respuestasCount: json['respuestas_count'] ?? 0,
    );
  }

  String get solicitanteNombre => empleadoNombre != null 
      ? '$empleadoNombre ${empleadoApellido ?? ''}'.trim() 
      : 'Desconocido';

  String get asignadoNombre {
    if (asignadoUsuarioNombre != null) {
      return asignadoUsuarioNombre!;
    }
    return 'Sin Asignar';
  }
}

class CategoriaReporte {
  final int id;
  final String nombre;
  final bool activa;

  CategoriaReporte({
    required this.id,
    required this.nombre,
    required this.activa,
  });

  factory CategoriaReporte.fromJson(Map<String, dynamic> json) {
    return CategoriaReporte(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
      activa: (json['activa'] == 1 || json['activa'] == true),
    );
  }
}

class RespuestaReporteIncidencia {
  final int id;
  final int reporteIncidenciaId;
  final int usuarioId;
  final String usuarioNombre;
  final String? usuarioFoto;
  final String? usuarioRol;
  final String respuesta;
  final String? archivoUrl;
  final DateTime fechaCreacion;

  RespuestaReporteIncidencia({
    required this.id,
    required this.reporteIncidenciaId,
    required this.usuarioId,
    required this.usuarioNombre,
    this.usuarioFoto,
    this.usuarioRol,
    required this.respuesta,
    this.archivoUrl,
    required this.fechaCreacion,
  });

  factory RespuestaReporteIncidencia.fromJson(Map<String, dynamic> json) {
    return RespuestaReporteIncidencia(
      id: json['id'] ?? 0,
      reporteIncidenciaId: json['reporte_incidencia_id'] ?? 0,
      usuarioId: json['usuario_id'] ?? 0,
      usuarioNombre: json['usuario_nombre'] ?? 'Usuario',
      usuarioFoto: json['usuario_foto'],
      usuarioRol: json['usuario_rol'],
      respuesta: json['mensaje'] ?? '',
      archivoUrl: json['archivo'] ?? json['archivo_url'],
      fechaCreacion: json['fecha_creacion'] != null 
          ? DateTime.parse(json['fecha_creacion']) 
          : DateTime.now(),
    );
  }
}
