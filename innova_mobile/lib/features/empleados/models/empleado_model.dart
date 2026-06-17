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
}