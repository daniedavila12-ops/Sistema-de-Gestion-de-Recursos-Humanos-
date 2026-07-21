-- ============================================================
-- SCRIPT DE INICIALIZACIÓN - SISTEMA RRHH INNOVA
-- Railway MySQL Database
-- ============================================================

SET FOREIGN_KEY_CHECKS = 0;

-- ============================================================
-- 1. TABLA: roles
-- ============================================================
CREATE TABLE IF NOT EXISTS roles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    descripcion TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT IGNORE INTO roles (id, nombre, descripcion) VALUES
(1, 'Administrador IT', 'Acceso total al sistema'),
(2, 'Recursos Humanos', 'Gestión de personal y RRHH'),
(3, 'Jefe de Area', 'Gestión de su área o departamento'),
(4, 'Empleado', 'Acceso básico al portal');

-- ============================================================
-- 2. TABLA: departamentos
-- ============================================================
CREATE TABLE IF NOT EXISTS departamentos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT IGNORE INTO departamentos (id, nombre) VALUES
(1, 'Tecnología'),
(2, 'Recursos Humanos'),
(3, 'Finanzas'),
(4, 'Operaciones'),
(5, 'Marketing'),
(6, 'Administración');

-- ============================================================
-- 3. TABLA: usuarios
-- ============================================================
CREATE TABLE IF NOT EXISTS usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    rol_id INT DEFAULT 4,
    foto VARCHAR(255) DEFAULT NULL,
    estado TINYINT(1) DEFAULT 1,
    ultimoLogin DATETIME DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (rol_id) REFERENCES roles(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Usuario administrador por defecto (password: admin123)
INSERT IGNORE INTO usuarios (id, nombre, email, password, rol_id, estado) VALUES
(1, 'Administrador', 'admin@innova.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 1, 1);

-- ============================================================
-- 4. TABLA: modulos
-- ============================================================
CREATE TABLE IF NOT EXISTS modulos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT IGNORE INTO modulos (id, nombre) VALUES
(1, 'Empleados'),
(2, '+Nuevo Empleado'),
(3, 'Vacaciones'),
(4, 'Faltas'),
(5, 'Documentos'),
(6, 'Tickets'),
(7, 'Roles'),
(8, 'Usuarios'),
(9, 'Gestión de Manuales'),
(10, 'Reportes de Incidencia'),
(11, 'Módulo de Reportes'),
(12, 'Archivero Legal'),
(13, 'Logs de Sistema'),
(14, 'Reclutamiento'),
(15, 'Evaluaciones de Desempeño');

-- ============================================================
-- 5. TABLA: rol_modulo (permisos por rol)
-- ============================================================
CREATE TABLE IF NOT EXISTS rol_modulo (
    rol_id INT NOT NULL,
    modulo_id INT NOT NULL,
    puedeVer TINYINT(1) DEFAULT 0,
    puedeCrear TINYINT(1) DEFAULT 0,
    puedeEditar TINYINT(1) DEFAULT 0,
    puedeEliminar TINYINT(1) DEFAULT 0,
    PRIMARY KEY (rol_id, modulo_id),
    FOREIGN KEY (rol_id) REFERENCES roles(id) ON DELETE CASCADE,
    FOREIGN KEY (modulo_id) REFERENCES modulos(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Administrador IT: acceso total
INSERT IGNORE INTO rol_modulo (rol_id, modulo_id, puedeVer, puedeCrear, puedeEditar, puedeEliminar)
SELECT 1, id, 1, 1, 1, 1 FROM modulos;

-- Recursos Humanos: acceso a módulos RRHH
INSERT IGNORE INTO rol_modulo (rol_id, modulo_id, puedeVer, puedeCrear, puedeEditar, puedeEliminar)
SELECT 2, id, 1, 1, 1, 0 FROM modulos WHERE nombre IN ('Empleados', '+Nuevo Empleado', 'Vacaciones', 'Faltas', 'Documentos', 'Tickets', 'Gestión de Manuales', 'Reportes de Incidencia', 'Módulo de Reportes', 'Archivero Legal', 'Reclutamiento', 'Evaluaciones de Desempeño');

-- ============================================================
-- 6. TABLA: usuario_modulo (permisos individuales)
-- ============================================================
CREATE TABLE IF NOT EXISTS usuario_modulo (
    usuario_id INT NOT NULL,
    modulo_id INT NOT NULL,
    puedeVer TINYINT(1) DEFAULT 0,
    puedeCrear TINYINT(1) DEFAULT 0,
    puedeEditar TINYINT(1) DEFAULT 0,
    puedeEliminar TINYINT(1) DEFAULT 0,
    PRIMARY KEY (usuario_id, modulo_id),
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    FOREIGN KEY (modulo_id) REFERENCES modulos(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- 7. TABLA: empleados
-- ============================================================
CREATE TABLE IF NOT EXISTS empleados (
    id INT AUTO_INCREMENT PRIMARY KEY,
    codigo_empleado VARCHAR(50) UNIQUE,
    identidad VARCHAR(50) UNIQUE,
    nombre VARCHAR(255) NOT NULL,
    apellido VARCHAR(255) NOT NULL,
    fecha_nacimiento DATE DEFAULT NULL,
    correo VARCHAR(255) DEFAULT NULL,
    telefono VARCHAR(50) DEFAULT NULL,
    direccion TEXT DEFAULT NULL,
    tipo_contrato VARCHAR(50) DEFAULT 'Permanente',
    fecha_inicio DATE DEFAULT NULL,
    ciudad VARCHAR(100) DEFAULT NULL,
    ubicacion VARCHAR(255) DEFAULT NULL,
    emergencia_parentesco VARCHAR(100) DEFAULT NULL,
    emergencia_nombre VARCHAR(255) DEFAULT NULL,
    emergencia_telefono VARCHAR(50) DEFAULT NULL,
    emergencia_parentesco_2 VARCHAR(100) DEFAULT NULL,
    emergencia_nombre_2 VARCHAR(255) DEFAULT NULL,
    emergencia_telefono_2 VARCHAR(50) DEFAULT NULL,
    genero VARCHAR(20) DEFAULT NULL,
    departamento_id INT DEFAULT NULL,
    foto VARCHAR(255) DEFAULT NULL,
    estado VARCHAR(20) DEFAULT 'Activo',
    area VARCHAR(100) DEFAULT NULL,
    puesto VARCHAR(100) DEFAULT NULL,
    supervisor_id INT DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (departamento_id) REFERENCES departamentos(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- 8. TABLA: contratos
-- ============================================================
CREATE TABLE IF NOT EXISTS contratos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    empleado_id INT NOT NULL,
    tipo VARCHAR(100) DEFAULT NULL,
    fechaInicio DATE DEFAULT NULL,
    fechaFinal DATE DEFAULT NULL,
    archivo VARCHAR(255) DEFAULT NULL,
    descripcion TEXT DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (empleado_id) REFERENCES empleados(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- 9. TABLA: contactos_emergencia
-- ============================================================
CREATE TABLE IF NOT EXISTS contactos_emergencia (
    id INT AUTO_INCREMENT PRIMARY KEY,
    empleado_id INT NOT NULL,
    nombre VARCHAR(255) NOT NULL,
    parentesco VARCHAR(100) DEFAULT NULL,
    telefono VARCHAR(50) DEFAULT NULL,
    FOREIGN KEY (empleado_id) REFERENCES empleados(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- 10. TABLA: vacaciones
-- ============================================================
CREATE TABLE IF NOT EXISTS vacaciones (
    id INT AUTO_INCREMENT PRIMARY KEY,
    empleado_id INT NOT NULL,
    fechaInicio DATE NOT NULL,
    fechaFinal DATE NOT NULL,
    fechaRegreso DATE DEFAULT NULL,
    diasSolicitados DECIMAL(5,2) DEFAULT NULL,
    diasHabiles DECIMAL(5,2) DEFAULT NULL,
    tipoPermiso VARCHAR(100) DEFAULT NULL,
    motivo TEXT DEFAULT NULL,
    estado VARCHAR(50) DEFAULT 'Pendiente',
    aprobadoPor INT DEFAULT NULL,
    archivo VARCHAR(255) DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (empleado_id) REFERENCES empleados(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- 11. TABLA: tipos_permiso
-- ============================================================
CREATE TABLE IF NOT EXISTS tipos_permiso (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT IGNORE INTO tipos_permiso (nombre) VALUES
('Médico'), ('Personal'), ('Maternidad/Paternidad'), ('Luto'), ('Vacaciones');

-- ============================================================
-- 12. TABLA: faltas
-- ============================================================
CREATE TABLE IF NOT EXISTS faltas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    empleado_id INT NOT NULL,
    fecha DATE NOT NULL,
    tipo VARCHAR(100) DEFAULT NULL,
    motivo TEXT DEFAULT NULL,
    estado VARCHAR(50) DEFAULT 'Pendiente',
    archivo VARCHAR(255) DEFAULT NULL,
    documento VARCHAR(255) DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (empleado_id) REFERENCES empleados(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- 13. TABLA: documentos
-- ============================================================
CREATE TABLE IF NOT EXISTS documentos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    empleado_id INT NOT NULL,
    tipo VARCHAR(100) DEFAULT 'Documento General',
    nombre VARCHAR(255) DEFAULT NULL,
    archivo VARCHAR(255) DEFAULT NULL,
    descripcion TEXT DEFAULT NULL,
    creadoPor INT DEFAULT NULL,
    fechaCreacion DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (empleado_id) REFERENCES empleados(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- 14. TABLA: tipos_documento
-- ============================================================
CREATE TABLE IF NOT EXISTS tipos_documento (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT IGNORE INTO tipos_documento (nombre) VALUES
('Documento General'), ('Nota'), ('Contrato');

-- ============================================================
-- 15. TABLA: notas
-- ============================================================
CREATE TABLE IF NOT EXISTS notas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    empleado_id INT NOT NULL,
    asunto VARCHAR(255) NOT NULL,
    descripcion TEXT NOT NULL,
    creadoPor INT DEFAULT 1,
    modificadoPor INT DEFAULT 1,
    archivo VARCHAR(255) DEFAULT NULL,
    fechaCreacion DATETIME DEFAULT CURRENT_TIMESTAMP,
    fechaModificacion DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (empleado_id) REFERENCES empleados(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- 16. TABLA: tickets
-- ============================================================
CREATE TABLE IF NOT EXISTS tickets (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT DEFAULT NULL,
    empleado_id INT DEFAULT NULL,
    identidad VARCHAR(50) DEFAULT NULL,
    Categoria VARCHAR(100) DEFAULT NULL,
    descripcion TEXT,
    tema VARCHAR(255) DEFAULT NULL,
    prioridad ENUM('Baja','Media','Alta','Urgente') DEFAULT 'Media',
    archivo VARCHAR(255) DEFAULT NULL,
    estado VARCHAR(50) DEFAULT 'Pendiente',
    asignado_usuario_id INT DEFAULT NULL,
    asignado_empleado_id INT DEFAULT NULL,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- 17. TABLA: ticket_respuestas
-- ============================================================
CREATE TABLE IF NOT EXISTS ticket_respuestas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    ticket_id INT NOT NULL,
    usuario_id INT DEFAULT NULL,
    empleado_id INT DEFAULT NULL,
    mensaje TEXT NOT NULL,
    archivo VARCHAR(255) DEFAULT NULL,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ticket_id) REFERENCES tickets(id) ON DELETE CASCADE,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE SET NULL,
    FOREIGN KEY (empleado_id) REFERENCES empleados(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- 18. TABLA: notificaciones
-- ============================================================
CREATE TABLE IF NOT EXISTS notificaciones (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL,
    titulo VARCHAR(255) NOT NULL,
    mensaje TEXT NOT NULL,
    leido TINYINT(1) DEFAULT 0,
    tipo VARCHAR(50) DEFAULT 'info',
    enlace VARCHAR(255) DEFAULT NULL,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 19. TABLA: biblioteca
-- ============================================================
CREATE TABLE IF NOT EXISTS biblioteca (
    id INT AUTO_INCREMENT PRIMARY KEY,
    titulo VARCHAR(255) NOT NULL,
    archivo VARCHAR(255) NOT NULL,
    descripcion TEXT DEFAULT NULL,
    categoria VARCHAR(100) DEFAULT NULL,
    fechaSubida DATETIME DEFAULT CURRENT_TIMESTAMP,
    subidoPor INT NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- 20. TABLA: categorias_legales
-- ============================================================
CREATE TABLE IF NOT EXISTS categorias_legales (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT IGNORE INTO categorias_legales (nombre) VALUES
('Contratos'), ('Políticas'), ('Normativas'), ('Actas'), ('General');

-- ============================================================
-- 21. TABLA: documentos_legales
-- ============================================================
CREATE TABLE IF NOT EXISTS documentos_legales (
    id INT AUTO_INCREMENT PRIMARY KEY,
    titulo VARCHAR(255) NOT NULL,
    descripcion TEXT DEFAULT NULL,
    categoria VARCHAR(100) DEFAULT NULL,
    archivo VARCHAR(255) DEFAULT NULL,
    link VARCHAR(500) DEFAULT NULL,
    tamano VARCHAR(50) DEFAULT NULL,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    creado_por INT DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- 22. TABLA: documentos_legales_archivos
-- ============================================================
CREATE TABLE IF NOT EXISTS documentos_legales_archivos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    documento_id INT NOT NULL,
    archivo VARCHAR(255) NOT NULL,
    nombre_original VARCHAR(255) DEFAULT NULL,
    tamano VARCHAR(50) DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (documento_id) REFERENCES documentos_legales(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- 23. TABLA: documentos_legales_links
-- ============================================================
CREATE TABLE IF NOT EXISTS documentos_legales_links (
    id INT AUTO_INCREMENT PRIMARY KEY,
    documento_id INT NOT NULL,
    link VARCHAR(500) NOT NULL,
    descripcion VARCHAR(255) DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (documento_id) REFERENCES documentos_legales(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- 24. TABLA: reportes_incidencias
-- ============================================================
CREATE TABLE IF NOT EXISTS reportes_incidencias (
    id INT AUTO_INCREMENT PRIMARY KEY,
    jefe_reporta VARCHAR(255) NOT NULL,
    empleado_reportado_id INT DEFAULT NULL,
    identidad VARCHAR(50) DEFAULT NULL,
    categoria VARCHAR(100) DEFAULT NULL,
    descripcion TEXT,
    tema VARCHAR(255) DEFAULT NULL,
    prioridad ENUM('Baja','Media','Alta','Urgente') DEFAULT 'Media',
    archivo VARCHAR(255) DEFAULT NULL,
    estado VARCHAR(50) DEFAULT 'Pendiente',
    asignado_usuario_id INT DEFAULT NULL,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- 25. TABLA: reporte_incidencia_respuestas
-- ============================================================
CREATE TABLE IF NOT EXISTS reporte_incidencia_respuestas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    reporte_id INT NOT NULL,
    usuario_id INT DEFAULT NULL,
    empleado_id INT DEFAULT NULL,
    mensaje TEXT NOT NULL,
    archivo VARCHAR(255) DEFAULT NULL,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- 26. TABLA: categorias_reportes
-- ============================================================
CREATE TABLE IF NOT EXISTS categorias_reportes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    activa BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT IGNORE INTO categorias_reportes (nombre) VALUES
('Falta Injustificada'), ('Llegada Tarde'), ('Insubordinación'),
('Abandono de Trabajo'), ('Desempeño'), ('Acoso'), ('Robo'), ('Otro');

-- ============================================================
-- 27. TABLA: logs_usuarios
-- ============================================================
CREATE TABLE IF NOT EXISTS logs_usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT DEFAULT NULL,
    accion VARCHAR(255) NOT NULL,
    modulo VARCHAR(100) DEFAULT NULL,
    detalles TEXT DEFAULT NULL,
    ip_address VARCHAR(45) DEFAULT NULL,
    fecha_creacion DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- 28. TABLA: candidatos
-- ============================================================
CREATE TABLE IF NOT EXISTS candidatos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre_completo VARCHAR(255) NOT NULL,
    correo VARCHAR(255) NOT NULL,
    telefono VARCHAR(50) NOT NULL,
    puesto_aplicado VARCHAR(255) NOT NULL,
    cv_url VARCHAR(255) DEFAULT NULL,
    estado VARCHAR(50) DEFAULT 'Recibido',
    notas TEXT DEFAULT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- 29. TABLA: evaluaciones_desempeno
-- ============================================================
CREATE TABLE IF NOT EXISTS evaluaciones_desempeno (
    id INT AUTO_INCREMENT PRIMARY KEY,
    empleado_id INT NOT NULL,
    evaluador_id INT DEFAULT NULL,
    evaluador_nombre VARCHAR(100) DEFAULT NULL,
    area VARCHAR(100) DEFAULT NULL,
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    promedio DECIMAL(5,2) DEFAULT NULL,
    porcentaje DECIMAL(5,2) DEFAULT NULL,
    nivel VARCHAR(50) DEFAULT NULL,
    observaciones TEXT DEFAULT NULL,
    FOREIGN KEY (empleado_id) REFERENCES empleados(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- 30. TABLA: evaluaciones_respuestas
-- ============================================================
CREATE TABLE IF NOT EXISTS evaluaciones_respuestas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    evaluacion_id INT NOT NULL,
    criterio VARCHAR(150) DEFAULT NULL,
    calificacion INT DEFAULT NULL,
    FOREIGN KEY (evaluacion_id) REFERENCES evaluaciones_desempeno(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- 31. TABLA: evaluaciones_enlaces
-- ============================================================
CREATE TABLE IF NOT EXISTS evaluaciones_enlaces (
    id INT AUTO_INCREMENT PRIMARY KEY,
    area VARCHAR(100) NOT NULL,
    token VARCHAR(255) NOT NULL,
    creado_el TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- 32. TABLA: categorias_tickets
-- ============================================================
CREATE TABLE IF NOT EXISTS categorias_tickets (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    activa BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT IGNORE INTO categorias_tickets (nombre) VALUES
('Soporte Técnico'), ('Recursos Humanos'), ('Nómina'), ('Infraestructura'), ('Otro');

SET FOREIGN_KEY_CHECKS = 1;

-- ============================================================
-- FIN DEL SCRIPT - Tablas creadas: 32
-- ============================================================
SELECT 'Script ejecutado exitosamente!' AS resultado;
