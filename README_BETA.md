# Reparapp - Versión Beta

## Descripción
Reparapp es una aplicación móvil para Android que permite a operarios (técnicos de reparación) gestionar tareas asignadas mediante un calendario interactivo y adjuntar documentos fotográficos del trabajo realizado.

## Características de la Versión Beta

### Pantalla de Login
- Autenticación simple con email y contraseña
- Credenciales de demostración:
  - Email: `juan@reparapp.es`
  - Contraseña: `1234`

### Agenda/Calendario
- Vista de tareas (avisos) filtrada por fecha
- Navegación entre fechas
- Visualización del estado de cada tarea:
  - **Pendiente** (naranja): Tarea no iniciada
  - **En ruta** (azul): Operario accediendo
  - **En curso** (púrpura): Tarea en ejecución
  - **Finalizado** (verde): Tarea completada

### Detalle de Aviso
- Información del cliente (nombre, teléfono, dirección)
- Detalles de la tarea (tipo, fecha, hora, descripción)
- Cambio de estado de la tarea
- Captura de fotos mediante cámara del dispositivo
- Selección de fotos desde la galería
- Escritura de notas del trabajo realizado
- Historial de documentos adjuntos

## Estructura del Proyecto

```
lib/
├── main.dart                 # Punto de entrada
├── models/
│   ├── usuario.dart         # Modelo de Usuario
│   ├── aviso.dart           # Modelo de Aviso/Tarea
│   └── documento.dart       # Modelo de Documento/Foto
├── screens/
│   ├── login_screen.dart    # Pantalla de autenticación
│   ├── home_screen.dart     # Pantalla principal
│   ├── agenda_screen.dart   # Calendario y lista de tareas
│   └── aviso_detalle_screen.dart  # Detalle de tarea
└── services/
    └── api_service.dart     # Servicio de datos (mock)
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

## Notas Importantes para la Siguiente Entrega

- **Datos Mock**: Actualmente, la aplicación usa datos simulados. En la siguiente entrega, se conectará a una API real.
- **Almacenamiento Local**: Las fotos se guardan localmente. Se requiere integración con servidor.
- **Roles**: El rol de administrador está preparado pero sin funcionalidad en esta versión.
- **Diseño**: Interfaz simplificada sin estilos complejos, como se solicitó.

## Credenciales de Demo
- **Usuario Operario**: juan@reparapp.es / 1234
- **Usuario Admin**: admin@reparapp.es / 1234

## Próximas Entregas
- Conexión a API REST real
- Panel de administrador funcional
- Sincronización en tiempo real
- Modo offline
- Integración de base de datos en servidor
- Mejoras visuales y estilos avanzados

---

Versión Beta - Marzo 2026
Proyecto de Fin de Ciclo - Grado Superior DAM
