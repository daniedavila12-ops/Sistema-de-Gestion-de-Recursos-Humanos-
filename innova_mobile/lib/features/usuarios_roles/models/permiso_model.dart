class Permiso {
  final int moduloId;
  final String moduloNombre;
  final bool puedeVer;
  final bool puedeCrear;
  final bool puedeEditar;
  final bool puedeEliminar;

  Permiso({
    required this.moduloId,
    required this.moduloNombre,
    this.puedeVer = false,
    this.puedeCrear = false,
    this.puedeEditar = false,
    this.puedeEliminar = false,
  });

  factory Permiso.fromJson(Map<String, dynamic> json) {
    return Permiso(
      moduloId: json['modulo_id'],
      moduloNombre: json['modulo_nombre'] ?? '',
      puedeVer: json['puedeVer'] == 1 || json['puedeVer'] == true,
      puedeCrear: json['puedeCrear'] == 1 || json['puedeCrear'] == true,
      puedeEditar: json['puedeEditar'] == 1 || json['puedeEditar'] == true,
      puedeEliminar: json['puedeEliminar'] == 1 || json['puedeEliminar'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'modulo_id': moduloId,
      'puedeVer': puedeVer ? 1 : 0,
      'puedeCrear': puedeCrear ? 1 : 0,
      'puedeEditar': puedeEditar ? 1 : 0,
      'puedeEliminar': puedeEliminar ? 1 : 0,
    };
  }

  Permiso copyWith({
    bool? puedeVer,
    bool? puedeCrear,
    bool? puedeEditar,
    bool? puedeEliminar,
  }) {
    return Permiso(
      moduloId: moduloId,
      moduloNombre: moduloNombre,
      puedeVer: puedeVer ?? this.puedeVer,
      puedeCrear: puedeCrear ?? this.puedeCrear,
      puedeEditar: puedeEditar ?? this.puedeEditar,
      puedeEliminar: puedeEliminar ?? this.puedeEliminar,
    );
  }
}
