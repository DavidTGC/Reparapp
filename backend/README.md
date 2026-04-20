# Instalación y Configuración del Backend PHP + MySQL

## Requisitos

- PHP 7.4 o superior
- MySQL 5.7 o superior
- Servidor web (Apache con mod_rewrite habilitado, o similar)

## Pasos de Instalación

### 1. Configurar la Base de Datos

1. Acceder a MySQL:
```bash
mysql -u root -p
```

2. Ejecutar el script SQL para crear la base de datos y tablas:
```bash
mysql -u root -p < backend/database/schema.sql
```

Esto creará:
- Base de datos `reparapp`
- Tablas: `usuarios`, `avisos`, `documentos`
- Datos iniciales de prueba

### 2. Configurar PHP

El archivo de configuración está en `backend/config/database.php`. Ajusta los parámetros según tu entorno:

```php
define('DB_HOST', 'localhost');    // Host del servidor MySQL
define('DB_USER', 'root');         // Usuario MySQL
define('DB_PASS', '');             // Contraseña MySQL
define('DB_NAME', 'reparapp');     // Nombre de la base de datos
```

### 3. Configurar el Servidor Web

**Para Apache:**
1. Copiar la carpeta `backend` a la raíz del servidor web (htdocs en XAMPP)
2. Asegurar que `mod_rewrite` está habilitado
3. El archivo `.htaccess` ya está configurado

**URLs de los endpoints:**
- `http://localhost/reparapp/backend/api/usuarios.php`
- `http://localhost/reparapp/backend/api/avisos.php`
- `http://localhost/reparapp/backend/api/documentos.php`

### 4. Actualizar la URL en Flutter

En `lib/services/api_service.dart`, actualiza la constante `apiBaseUrl`:

```dart
static const String apiBaseUrl = 'http://localhost/reparapp/backend/api';
```

Si usas un servidor remoto, reemplaza `localhost` con la IP o dominio del servidor.

## Endpoints de la API

### Usuarios

**Login**
```
POST /usuarios.php/login
Body: { "email": "...", "password": "..." }
```

**Obtener usuarios**
```
GET /usuarios.php/usuarios
```

**Crear usuario**
```
POST /usuarios.php/usuarios
Body: { "nombre": "...", "email": "...", "password": "...", "telefono": "...", "rol": "operario|admin" }
```

**Actualizar usuario**
```
PUT /usuarios.php/usuarios
Body: { "id": 1, "nombre": "...", "email": "...", ... }
```

**Eliminar usuario**
```
DELETE /usuarios.php/usuarios
Body: { "id": 1 }
```

### Avisos

**Obtener todos los avisos**
```
GET /avisos.php/avisos
```

**Obtener avisos por operario**
```
GET /avisos.php/avisos-por-operario?id_operario=1
```

**Crear aviso**
```
POST /avisos.php/avisos
Body: { "titulo": "...", "descripcion": "...", "fecha": "2024-01-15", "id_operario": 1, ... }
```

**Actualizar aviso**
```
PUT /avisos.php/avisos
Body: { "id": 1, "estado": "en_curso", ... }
```

**Eliminar aviso**
```
DELETE /avisos.php/avisos
Body: { "id": 1 }
```

### Documentos

**Obtener documentos de un aviso**
```
GET /documentos.php/documentos-por-aviso?id_aviso=1
```

**Subir documento**
```
POST /documentos.php/documentos
FormData: { "id_aviso": 1, "tipo": "foto_antes", "archivo": <archivo> }
```

**Eliminar documento**
```
DELETE /documentos.php/documentos
Body: { "id": 1 }
```

## Estructura de Directorios

```
backend/
├── api/
│   ├── index.php          # Router principal
│   ├── usuarios.php       # Endpoints de usuarios
│   ├── avisos.php         # Endpoints de avisos
│   ├── documentos.php     # Endpoints de documentos
│   └── .htaccess          # Reescritura de URLs
├── config/
│   └── database.php       # Configuración de conexión a MySQL
├── database/
│   └── schema.sql         # Script para crear BD y tablas
└── uploads/               # Carpeta para almacenar documentos (fotos)
    └── (se crea automáticamente)
```

## Notas Importantes

1. **Seguridad**: El código incluye validaciones básicas. Para producción, implementar:
   - Validación de entrada más robusta
   - Uso de prepared statements
   - Autenticación con tokens (JWT)
   - HTTPS obligatorio
   - Rate limiting

2. **Contraseñas**: Se almacenan usando MD5 (no recomendado para producción). Usar `password_hash()` y `password_verify()`.

3. **CORS**: Está habilitado para todas las fuentes. Restringir en producción.

4. **Certificados SSL**: Usar HTTPS en producción.

## Troubleshooting

**Error: "Error en la conexión a la base de datos"**
- Verificar que MySQL está corriendo
- Comprobar las credenciales en `database.php`
- Asegurar que la base de datos existe

**Error: "Endpoint no encontrado"**
- Verificar que la URL es correcta
- Asegurar que el archivo .htaccess existe
- Comprobar que mod_rewrite está habilitado en Apache

**Error: "Error al subir archivo"**
- Verificar permisos de la carpeta `uploads/`
- Comprobar el tamaño máximo de upload en PHP
- Verificar tipos de archivo permitidos
