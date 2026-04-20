# Reparapp - Versión Beta

## Descripción
Reparapp es una aplicación móvil para Android que permite a operarios (técnicos de reparación) gestionar tareas asignadas mediante un calendario interactivo y adjuntar documentos fotográficos del trabajo realizado.

## Características de la Versión Beta

### 🔐 Pantalla de Login
- Autenticación simple con email y contraseña
- Soporte para dos roles: **Operario** y **Administrador**
- Redirección automática según rol del usuario
- Credenciales de demostración:
  - **Operario**: juan@reparapp.es / 1234
  - **Administrador**: admin@reparapp.es / 1234

### 📱 Funcionalidades para Operarios

#### Pantalla de Inicio
- Acceso directo a agenda de tareas
- Información del usuario logueado
- Opción de cerrar sesión

#### Agenda/Calendario
- Vista de tareas (avisos) filtrada por fecha
- Navegación entre fechas
- Visualización del estado de cada tarea:
  - **Pendiente** (naranja): Tarea no iniciada
  - **En ruta** (azul): Operario accediendo
  - **En curso** (púrpura): Tarea en ejecución
  - **Finalizado** (verde): Tarea completada

#### Detalle de Aviso
- Información del cliente (nombre, teléfono, dirección)
- Detalles de la tarea (tipo, fecha, hora, descripción)
- Cambio de estado de la tarea en tiempo real
- Captura de fotos mediante cámara del dispositivo
- Selección de fotos desde la galería
- Escritura de notas del trabajo realizado
- Historial de documentos adjuntos
- Visualización de estado actual del aviso

### 👨‍💼 Funcionalidades para Administrador

#### Panel de Control Administrativo
- Acceso al dashboard principal
- Navegación a gestión de avisos
- Opción de cerrar sesión

#### Gestión de Avisos
- Visualización de todos los avisos en la plataforma
- Filtrado dinámico por estados (todos, pendiente, en ruta, en curso, finalizado)
- Visualización de detalles de cada aviso
- Consulta del historial de documentos/fotos por aviso
- Información del cliente y estado de tareas

## Estructura del Proyecto

```
lib/
├── main.dart                          # Punto de entrada - configuración de la app
├── models/
│   ├── usuario.dart                   # Modelo de Usuario (con rol: operario/admin)
│   ├── aviso.dart                     # Modelo de Aviso/Tarea
│   └── documento.dart                 # Modelo de Documento/Foto adjunta
├── screens/
│   ├── login_screen.dart              # Pantalla de autenticación
│   ├── home_screen.dart               # Pantalla principal (Operario)
│   ├── agenda_screen.dart             # Calendario y lista de tareas (Operario)
│   ├── aviso_detalle_screen.dart      # Detalle de tarea (Operario)
│   ├── admin_home_screen.dart         # Panel principal (Administrador)
│   ├── admin_avisos_list_screen.dart  # Lista de avisos con filtros (Administrador)
│   └── admin_aviso_detalle_screen.dart # Detalle de aviso (Administrador)
└── services/
    └── api_service.dart               # Servicio de datos (mock) - datos simulados
```

## Instalación y Ejecución

### Requisitos
- Flutter 3.9.2 o superior
- Android SDK
- Un dispositivo Android o emulador

### Pasos de Instalación

1. **Clonar/descargar el proyecto**
```bash
cd reparapp
```

2. **Instalar dependencias**
```bash
flutter pub get
```

3. **Ejecutar la aplicación**
```bash
flutter run
```

4. **Build APK para distribución**
```bash
flutter build apk --release
```

## Dependencias Principales
- `image_picker`: Para captura de fotos y selección de galería
- `intl`: Para formato de fechas
- `provider`: Para gestión de estado (preparado para futuras versiones)

## Estado de Implementación

### ✅ Completado
- Autenticación con dos roles (Operario y Administrador)
- Interfaz de operario con agenda y detalles de aviso
- Panel de administrador con visualización y filtrado de avisos
- Captura de fotos y selección desde galería
- Modelos de datos (Usuario, Aviso, Documento)
- Servicio de datos mock para demostración

### ⏳ Pendiente para Próximas Entregas
- **Conexión a API REST real**: Reemplazar mock data por APIs
- **Almacenamiento en servidor**: Las fotos se guardan localmente, requiere integración con servidor
- **Panel de administrador avanzado**: Creación, edición y eliminación de avisos
- **Sincronización en tiempo real**: WebSockets o Firebase
- **Modo offline**: Almacenamiento local con sincronización posterior
- **Mejoras visuales**: Estilos más avanzados y animaciones

## Notas Técnicas

- **Datos Simulados**: Actualmente usa mock data para demostración
- **Estado**: Preparado para integración con API real sin cambios mayores
- **Diseño**: Interfaz simplificada y funcional como se solicitó
- **Roles Implementados**: Sistema completo de bifurcación según rol del usuario
- Mejoras visuales y estilos avanzados

---

Proyecto de Fin de Ciclo - Grado Superior DAM
