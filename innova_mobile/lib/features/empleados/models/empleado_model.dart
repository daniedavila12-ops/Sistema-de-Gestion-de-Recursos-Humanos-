// CREADO POR: DANIEL INNOVA

class Empleado {
  final int id;
  final String nombre;
  final String apellido;
  final String? cargo;
  final String? departamento;
  final String? codigoEmpleado;
  final String? identidad;
  final String? correo;
  final String? tipoContrato;
  final String? ubicacion;
  final int estado;
  final String? foto;
  final String? fechaNacimiento;
  final String? telefono;
  final String? direccion;
  final DateTime? fechaInicio;
  final String? ciudad;
  final String? emergenciaNombre;
  final String? emergenciaParentesco;
  final String? emergenciaTelefono;
  final String? emergenciaNombre2;
  final String? emergenciaParentesco2;
  final String? emergenciaTelefono2;

  Empleado({
    required this.id,
    required this.nombre,
    required this.apellido,
    this.cargo,
    this.departamento,
    this.codigoEmpleado,
    this.identidad,
    this.correo,
    this.tipoContrato,
    this.ubicacion,
    required this.estado,
    this.foto,
    this.fechaNacimiento,
    this.telefono,
    this.direccion,
    this.fechaInicio,
    this.ciudad,
    this.emergenciaNombre,
    this.emergenciaParentesco,
    this.emergenciaTelefono,
    this.emergenciaNombre2,
    this.emergenciaParentesco2,
    this.emergenciaTelefono2,
  });

  factory Empleado.fromJson(Map<String, dynamic> json) {
    return Empleado(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
      apellido: json['apellido'] ?? '',
      cargo: json['cargo'],
      departamento: json['departamento_id']?.toString(), // Assuming backend returns ID, or join
      codigoEmpleado: json['codigo_empleado'],
      identidad: json['identidad'],
      correo: json['correo'],
      tipoContrato: json['tipo_contrato'],
      ubicacion: json['ubicacion'],
      estado: json['estado'] ?? 1,
      foto: json['foto'],
      fechaNacimiento: json['fecha_nacimiento'],
      telefono: json['telefono'],
      direccion: json['direccion'],
      fechaInicio: json['fecha_inicio'] != null ? DateTime.tryParse(json['fecha_inicio']) : null,
      ciudad: json['ciudad'],
      emergenciaNombre: json['emergencia_nombre'],
      emergenciaParentesco: json['emergencia_parentesco'],
      emergenciaTelefono: json['emergencia_telefono'],
      emergenciaNombre2: json['emergencia_nombre_2'],
      emergenciaParentesco2: json['emergencia_parentesco_2'],
      emergenciaTelefono2: json['emergencia_telefono_2'],
    );
  }

  String get nombreCompleto => '$nombre $apellido';

  Empleado copyWith({
    int? id,
    String? nombre,
    String? apellido,
    String? cargo,
    String? departamento,
    String? codigoEmpleado,
    String? identidad,
    String? correo,
    String? tipoContrato,
    String? ubicacion,
    int? estado,
    String? foto,
    String? fechaNacimiento,
    String? telefono,
    String? direccion,
    DateTime? fechaInicio,
    String? ciudad,
    String? emergenciaNombre,
    String? emergenciaParentesco,
    String? emergenciaTelefono,
    String? emergenciaNombre2,
    String? emergenciaParentesco2,
    String? emergenciaTelefono2,
  }) {
    return Empleado(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      cargo: cargo ?? this.cargo,
      departamento: departamento ?? this.departamento,
      codigoEmpleado: codigoEmpleado ?? this.codigoEmpleado,
      identidad: identidad ?? this.identidad,
      correo: correo ?? this.correo,
      tipoContrato: tipoContrato ?? this.tipoContrato,
      ubicacion: ubicacion ?? this.ubicacion,
      estado: estado ?? this.estado,
      foto: foto ?? this.foto,
      fechaNacimiento: fechaNacimiento ?? this.fechaNacimiento,
      telefono: telefono ?? this.telefono,
      direccion: direccion ?? this.direccion,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      ciudad: ciudad ?? this.ciudad,
      emergenciaNombre: emergenciaNombre ?? this.emergenciaNombre,
      emergenciaParentesco: emergenciaParentesco ?? this.emergenciaParentesco,
      emergenciaTelefono: emergenciaTelefono ?? this.emergenciaTelefono,
      emergenciaNombre2: emergenciaNombre2 ?? this.emergenciaNombre2,
      emergenciaParentesco2: emergenciaParentesco2 ?? this.emergenciaParentesco2,
      emergenciaTelefono2: emergenciaTelefono2 ?? this.emergenciaTelefono2,
    );
  }
}