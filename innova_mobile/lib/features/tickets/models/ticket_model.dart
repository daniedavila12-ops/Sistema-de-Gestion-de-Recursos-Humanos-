// CREADO POR: DANIEL INNOVA

class Ticket {
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
  final String? empleadoTelefono;
  final int? ticketsTotales;
  final int? ticketsResueltos;

  // Asignado
  final String? asignadoEmpleadoNombre;
  final String? asignadoEmpleadoApellido;
  final String? asignadoEmpleadoFoto;
  final String? asignadoUsuarioNombre;
  final String? asignadoUsuarioFoto;

  Ticket({
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
    this.empleadoTelefono,
    this.ticketsTotales,
    this.ticketsResueltos,
    this.asignadoEmpleadoNombre,
    this.asignadoEmpleadoApellido,
    this.asignadoEmpleadoFoto,
    this.asignadoUsuarioNombre,
    this.asignadoUsuarioFoto,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'] ?? 0,
      tema: json['tema'] ?? json['Categoria'] ?? json['tipo'] ?? 'Sin tema',
      estado: json['estado'] ?? 'Pendiente',
      categoria: json['Categoria'] ?? json['categoria'] ?? json['tipo'] ?? 'Sin categoría',
      prioridad: json['prioridad'] ?? 'Media',
      descripcion: json['descripcion'] ?? '',
      archivo: json['archivo'],
      fechaCreacion: json['fecha_creacion'] != null ? DateTime.tryParse(json['fecha_creacion']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
      empleadoNombre: json['empleado_nombre'],
      empleadoApellido: json['empleado_apellido'],
      empleadoFoto: json['empleado_foto'],
      empleadoTelefono: json['empleado_telefono'],
      ticketsTotales: json['tickets_totales'],
      ticketsResueltos: json['tickets_resueltos'],
      asignadoEmpleadoNombre: json['asignado_empleado_nombre'],
      asignadoEmpleadoApellido: json['asignado_empleado_apellido'],
      asignadoEmpleadoFoto: json['asignado_empleado_foto'],
      asignadoUsuarioNombre: json['asignado_usuario_nombre'],
      asignadoUsuarioFoto: json['asignado_usuario_foto'],
    );
  }

  String get solicitanteNombre => empleadoNombre != null 
      ? '$empleadoNombre ${empleadoApellido ?? ''}'.trim() 
      : 'Externo';

  String get asignadoNombre {
    if (asignadoEmpleadoNombre != null) {
      return '$asignadoEmpleadoNombre ${asignadoEmpleadoApellido ?? ''}'.trim();
    } else if (asignadoUsuarioNombre != null) {
      return asignadoUsuarioNombre!;
    }
    return 'Sin Asignar';
  }

  String? get asignadoFoto => asignadoEmpleadoFoto ?? asignadoUsuarioFoto;
}

class RespuestaTicket {
  final int id;
  final String mensaje;
  final DateTime? fechaCreacion;
  final String? archivo;
  final String? empleadoNombre;
  final String? empleadoApellido;
  final String? empleadoFoto;
  final String? usuarioNombre;
  final String? usuarioFoto;

  RespuestaTicket({
    required this.id,
    required this.mensaje,
    this.fechaCreacion,
    this.archivo,
    this.empleadoNombre,
    this.empleadoApellido,
    this.empleadoFoto,
    this.usuarioNombre,
    this.usuarioFoto,
  });

  factory RespuestaTicket.fromJson(Map<String, dynamic> json) {
    return RespuestaTicket(
      id: json['id'] ?? 0,
      mensaje: json['mensaje'] ?? '',
      fechaCreacion: json['fecha_creacion'] != null ? DateTime.tryParse(json['fecha_creacion']) : null,
      archivo: json['archivo'],
      empleadoNombre: json['empleado_nombre'],
      empleadoApellido: json['empleado_apellido'],
      empleadoFoto: json['empleado_foto'],
      usuarioNombre: json['usuario_nombre'],
      usuarioFoto: json['usuario_foto'],
    );
  }

  String get autorNombre => empleadoNombre != null 
      ? '$empleadoNombre ${empleadoApellido ?? ''}'.trim() 
      : (usuarioNombre ?? 'Usuario Desconocido');

  String? get autorFoto => empleadoFoto ?? usuarioFoto;
}
