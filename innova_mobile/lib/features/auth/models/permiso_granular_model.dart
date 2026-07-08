class PermisoGranular {
  final String moduloNombre;
  final bool puedeVer;
  final bool puedeCrear;
  final bool puedeEditar;
  final bool puedeEliminar;

  PermisoGranular({
    required this.moduloNombre,
    required this.puedeVer,
    required this.puedeCrear,
    required this.puedeEditar,
    required this.puedeEliminar,
  });

  factory PermisoGranular.fromJson(Map<String, dynamic> json) {
    return PermisoGranular(
      moduloNombre: json['nombre'] ?? json['moduloNombre'] ?? '',
      puedeVer: _parseBool(json['puedeVer'] ?? json['uVer'] ?? json['rVer']),
      puedeCrear: _parseBool(json['puedeCrear'] ?? json['uCrear'] ?? json['rCrear']),
      puedeEditar: _parseBool(json['puedeEditar'] ?? json['uEditar'] ?? json['rEditar']),
      puedeEliminar: _parseBool(json['puedeEliminar'] ?? json['uEliminar'] ?? json['rEliminar']),
    );
  }

  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value == '1' || value.toLowerCase() == 'true';
    return false;
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': moduloNombre,
      'uVer': puedeVer ? 1 : 0,
      'uCrear': puedeCrear ? 1 : 0,
      'uEditar': puedeEditar ? 1 : 0,
      'uEliminar': puedeEliminar ? 1 : 0,
    };
  }
}
