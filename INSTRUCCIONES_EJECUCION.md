# INSTRUCCIONES PARA EJECUTAR REPARAPP - VERSIÓN BETA

## 1. Preparación del Entorno

### Requisitos Previos
- Flutter SDK 3.9.2 o superior instalado
- Android SDK instalado y configurado
- Un emulador Android o dispositivo físico conectado
- Git (opcional, para clonar el proyecto)

### Verificar Instalación
```bash
flutter doctor
```

## 2. Instalación de Dependencias

Desde la carpeta raíz del proyecto:

```bash
flutter pub get
```

Esto descargará las siguientes dependencias:
- flutter (SDK)
- cupertino_icons (iconos)
- image_picker (cámara y galería)
- intl (formato de fechas)
- provider (gestión de estado)

## 3. Ejecutar la Aplicación

### En un Emulador o Dispositivo
```bash
flutter run
```

### Con Debugging
```bash
flutter run -d <device_id> --verbose
```

### En Modo Release
```bash
flutter run --release
```

## 4. Credenciales de Acceso

La aplicación incluye dos usuarios de demostración:

### Operario (Recomendado para esta versión beta)
- Email: `juan@reparapp.es`
- Contraseña: `1234`

### Administrador (Panel en desarrollo)
- Email: `admin@reparapp.es`
- Contraseña: `1234`

## 5. Funcionalidades Disponibles en Esta Versión

### ✅ Implementado
1. **Pantalla de Login**
   - Autenticación con email y contraseña
   - Validación de credenciales
   - Indicadores de carga

2. **Pantalla de Inicio**
   - Bienvenida personalizada
   - Información del usuario
   - Opción de cerrar sesión

3. **Agenda/Calendario**
   - Visualización de tareas por fecha
   - Navegación entre fechas
   - Filtrado de avisos por fecha
   - Estados visuales de tareas

4. **Detalle de Aviso**
   - Información completa del cliente
   - Detalles de la tarea
   - Cambio de estados (En ruta, En curso, Finalizado)
   - Captura de fotos con cámara
   - Selección de múltiples fotos desde galería
   - Notas de trabajo realizado
   - Historial de documentos

### ⏳ Futuras Entregas
- Panel de administrador
- Conexión a API real
- Base de datos en servidor
- Sincronización en tiempo real
- Modo offline
- Notificaciones push
- Firma digital del cliente

## 6. Estructura de Carpetas

```
reparapp/
├── lib/
│   ├── main.dart                 # Punto de entrada
│   ├── models/                   # Modelos de datos
│   │   ├── usuario.dart
│   │   ├── aviso.dart
│   │   └── documento.dart
│   ├── screens/                  # Pantallas de la app
│   │   ├── login_screen.dart
│   │   ├── home_screen.dart
│   │   ├── agenda_screen.dart
│   │   └── aviso_detalle_screen.dart
│   ├── services/                 # Servicios (API, datos)
│   │   └── api_service.dart      # Actualmente con datos mock
│   └── widgets/                  # Componentes reutilizables
├── android/                      # Configuración específica Android
├── ios/                          # Configuración específica iOS (no usada)
├── web/                          # Configuración web (no usada)
├── windows/                      # Configuración Windows (no usada)
├── pubspec.yaml                  # Dependencias del proyecto
└── analysis_options.yaml         # Análisis de código

## 7. Permisos Android

Los siguientes permisos se han configurado en `AndroidManifest.xml`:
- `CAMERA`: Captura de fotos
- `READ_EXTERNAL_STORAGE`: Lectura de galería
- `WRITE_EXTERNAL_STORAGE`: Escritura de archivos
- `INTERNET`: Conexión a servidor (para futuro)

## 8. Notas Importantes

### Estado Actual
- **Tipo de Datos**: Mock (simulados en memoria)
- **Almacenamiento**: Local en el dispositivo
- **API**: No conectada en esta versión
- **Base de Datos**: No implementada

### Para Pruebas
1. Inicia sesión con las credenciales de demo
2. Selecciona una fecha en el calendario
3. Haz clic en un aviso para ver los detalles
4. Prueba cambiar estados de la tarea
5. Intenta capturar fotos o seleccionar de la galería
6. Escribe notas y guarda

### Troubleshooting

**Error de permisos de cámara:**
- Verifica que Android 31+ tenga permisos concedidos
- En emulador, revisa la configuración de permisos

**Error al seleccionar fotos:**
- Asegúrate de que la galería está disponible
- Agrega fotos al emulador: `adb push <archivo> /sdcard/DCIM/`

**Error de dependencias:**
```bash
flutter clean
flutter pub get
```

## 9. Build para Distribución

### Crear APK para Testing
```bash
flutter build apk --debug
```

### Crear APK Release (optimizado)
```bash
flutter build apk --release
```

### Crear App Bundle (para Google Play)
```bash
flutter build appbundle --release
```

El APK se encontrará en: `build/app/outputs/flutter-apk/app-release.apk`

## 10. Continuidad del Proyecto

Para la siguiente entrega:
1. Implementar conexión a API REST
2. Configur ar backend (Node.js/Django/Java)
3. Agregar base de datos (MySQL/PostgreSQL)
4. Implementar panel de administrador
5. Mejoras visuales y UX

---

**Proyecto**: Reparapp - Gestión de Tareas de Reparación
**Versión**: Beta (v0.1.0)
**Fecha**: Marzo 2026
**Grado**: Desarrollo de Aplicaciones Multiplataforma (DAM)
