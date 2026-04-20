-- Script para crear la base de datos y tablas de Reparapp

CREATE DATABASE IF NOT EXISTS reparapp;
USE reparapp;

-- ==========================================
-- TABLA DE USUARIOS
-- ==========================================
CREATE TABLE usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    telefono VARCHAR(20),
    dni VARCHAR(20) UNIQUE,
    rol ENUM('admin', 'operario') DEFAULT 'operario',
    password VARCHAR(255) NOT NULL,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE,
    INDEX idx_email (email),
    INDEX idx_rol (rol),
    INDEX idx_dni (dni)
);

-- ==========================================
-- TABLA DE CLIENTES
-- ==========================================
CREATE TABLE clientes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    email VARCHAR(255),
    telefono VARCHAR(20) NOT NULL,
    telefono_alternativo VARCHAR(20),
    direccion VARCHAR(500),
    ciudad VARCHAR(100),
    codigo_postal VARCHAR(10),
    provincia VARCHAR(100),
    tipo_cliente ENUM('residencial', 'comercial', 'industrial') DEFAULT 'residencial',
    notas LONGTEXT,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_telefono (telefono),
    INDEX idx_ciudad (ciudad)
);

-- ==========================================
-- TABLA DE AVISOS
-- ==========================================
CREATE TABLE avisos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    titulo VARCHAR(255) NOT NULL,
    descripcion LONGTEXT,
    id_cliente INT,
    direccion VARCHAR(500),
    ciudad VARCHAR(100),
    fecha DATE NOT NULL,
    hora VARCHAR(5),
    estado ENUM('pendiente', 'en_ruta', 'en_curso', 'finalizado', 'cancelado') DEFAULT 'pendiente',
    prioridad ENUM('baja', 'media', 'alta', 'urgente') DEFAULT 'media',
    tipo_servicio VARCHAR(100),
    id_operario INT,
    notas LONGTEXT,
    firma LONGTEXT,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (id_cliente) REFERENCES clientes(id) ON DELETE SET NULL,
    FOREIGN KEY (id_operario) REFERENCES usuarios(id) ON DELETE SET NULL,
    INDEX idx_estado (estado),
    INDEX idx_operario (id_operario),
    INDEX idx_fecha (fecha),
    INDEX idx_cliente (id_cliente)
);

-- ==========================================
-- TABLA DE DOCUMENTOS
-- ==========================================
CREATE TABLE documentos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_aviso INT NOT NULL,
    tipo ENUM('foto_antes', 'foto_durante', 'foto_despues', 'documento') DEFAULT 'foto_durante',
    nombre_archivo VARCHAR(500) NOT NULL,
    ruta_archivo VARCHAR(500) NOT NULL,
    mime_type VARCHAR(100),
    tamaño_bytes INT,
    descripcion VARCHAR(500),
    fecha_subida TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_aviso) REFERENCES avisos(id) ON DELETE CASCADE,
    INDEX idx_aviso (id_aviso),
    INDEX idx_tipo (tipo)
);

-- ==========================================
-- INSERTAR DATOS INICIALES
-- ==========================================

-- Usuarios
INSERT INTO usuarios (nombre, email, telefono, rol, password) VALUES
('Miguel Rodríguez', 'operario@reparapp.es', '656234567', 'operario', MD5('1234')),
('Francisco Javier López', 'admin@reparapp.es', '655789123', 'admin', MD5('1234')),
('Antonio Moreno', 'antonio@reparapp.es', '654123456', 'operario', MD5('1234'));

-- Clientes
INSERT INTO clientes (nombre, email, telefono, telefono_alternativo, direccion, ciudad, codigo_postal, provincia, tipo_cliente) VALUES
('Rafael Díaz Martínez', 'rafael.diaz@email.com', '956332145', '956332146', 'Calle Larga 45', 'Jerez de la Frontera', '11402', 'Cádiz', 'residencial'),
('Isabel Ruiz Fernández', 'isabel.ruiz@email.com', '956334512', '', 'Avenida Alcalde Álvaro Domecq 78', 'Jerez de la Frontera', '11402', 'Cádiz', 'residencial'),
('José María Gómez', 'josemaria@email.com', '956445789', '956445790', 'Calle Pizarro 23', 'Jerez de la Frontera', '11402', 'Cádiz', 'residencial'),
('Carmen López Pérez', 'carmen.lopez@email.com', '956667234', '', 'Calle Nueva 56', 'Jerez de la Frontera', '11402', 'Cádiz', 'comercial'),
('David García Sánchez', 'david.garcia@email.com', '956778234', '956778235', 'Calle Arcos 12', 'Jerez de la Frontera', '11402', 'Cádiz', 'residencial');

-- Avisos
INSERT INTO avisos (titulo, descripcion, id_cliente, direccion, ciudad, fecha, hora, estado, prioridad, tipo_servicio, id_operario, notas) VALUES
('Reparación fontanería', 'Fuga en baño principal, revisar tuberías', 1, 'Calle Larga 45', 'Jerez de la Frontera', CURDATE(), '09:00', 'pendiente', 'media', 'Fontanería', 1, ''),
('Instalación eléctrica', 'Instalación de toma de corriente en cocina', 2, 'Avenida Alcalde Álvaro Domecq 78', 'Jerez de la Frontera', DATE_ADD(CURDATE(), INTERVAL 1 DAY), '14:00', 'pendiente', 'media', 'Electricidad', 1, ''),
('Desatasco de tuberías', 'Desatasco en el sifón del lavabo', 3, 'Calle Pizarro 23', 'Jerez de la Frontera', DATE_ADD(CURDATE(), INTERVAL 2 DAY), '10:30', 'en_curso', 'alta', 'Desatascalia', 1, ''),
('Reparación calefacción', 'Revisar y reparar sistema de calefacción central', 4, 'Calle Nueva 56', 'Jerez de la Frontera', DATE_ADD(CURDATE(), INTERVAL 3 DAY), '11:00', 'pendiente', 'media', 'Calefacción', 1, ''),
('Instalación sanitarios', 'Instalación de inodoro y lavabo en baño', 5, 'Calle Arcos 12', 'Jerez de la Frontera', DATE_ADD(CURDATE(), INTERVAL 4 DAY), '15:30', 'pendiente', 'baja', 'Fontanería', 1, '');
