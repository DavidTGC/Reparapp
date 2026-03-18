# Arquitectura de Reparapp - Versión Beta

## Descripción General
Reparapp es una aplicación móvil desarrollada en Flutter que sigue una arquitectura modular y escalable. En esta versión beta, se utiliza datos mock para simular la API, que será reemplazada en futuras versiones.

## Capas de la Arquitectura

### 1. Capa de Presentación (UI)
Contiene todos los widgets y pantallas de la aplicación.

#### Pantallas Principales
- **LoginScreen** (`lib/screens/login_screen.dart`)
  - Autenticación del usuario
  - Validación de credenciales
  - Interfaz simple sin estilos complejos

- **HomeScreen** (`lib/screens/home_screen.dart`)
  - Hub principal después del login
  - Diferenciación de roles (operario/admin)
  - Menú de opciones

- **AgendaScreen** (`lib/screens/agenda_screen.dart`)
  - Calendario interactivo
  - Lista de tareas filtrables por fecha
  - Visualización de estados

- **AvisoDetalleScreen** (`lib/screens/aviso_detalle_screen.dart`)
  - Vista completa de una tarea
  - Gestión de documentos
  - Edición de notas

### 2. Capa de Modelos (Data Models)
Define la estructura de datos de la aplicación.

#### Modelos Implementados
```dart
// Usuario
class Usuario {
  int id
  String nombre
  String email
  String telefono
  String rol  // 'admin' o 'operario'
  String password
}

// Aviso (Tarea de Reparación)
class Aviso {
  int id
  String titulo
  String descripcion
  String direccion
  DateTime fecha
  String hora
  String estado  // 'pendiente', 'en_ruta', 'en_curso', 'finalizado'
  String tipoServicio
  String nombreCliente
  String telefonoCliente
  int idOperario
  String notas
}

// Documento (Foto/Archivo)
class Documento {
  int id
  int idAviso
  String tipo  // 'foto_antes', 'foto_durante', 'foto_despues'
  String ruta
  String nombre
  DateTime fechaSubida
}
```

### 3. Capa de Servicios (Business Logic)
Contiene la lógica de negocio y comunicación de datos.

#### ApiService (`lib/services/api_service.dart`)
Proporciona métodos para:
- `login()`: Autenticación del usuario
- `getAvisosOperario()`: Obtener tareas del operario
- `getAvisoDetalle()`: Información completa de una tarea
- `actualizarNotasAviso()`: Guardar notas
- `cambiarEstadoAviso()`: Actualizar estado
- `getDocumentosAviso()`: Listar documentos/fotos
- `agregarDocumento()`: Añadir foto

**Estado actual**: Los datos son mock (en memoria). Serán conectados a una API real en la siguiente entrega.

### 4. Capa de Utilidades
Utilidades comunes y helpers.

- **image_picker**: Plugin para captura de fotos y selección de galería
- **intl**: Formato de fechas y localizaciones

## Flujo de la Aplicación

```
LoginScreen
    ↓
(Usuario se autentica)
    ↓
HomeScreen
    ↓ (Rol: operario)
AgendaScreen (Calendario)
    ↓
(Usuario selecciona fecha y aviso)
    ↓
AvisoDetalleScreen
    ↓
(Captura/Adjunta fotos y escribe notas)
```

## Gestión de Estado

### Estado Actual
- **Gestión**: Simple con `setState()` en widgets StatefulWidget
- **Enrutamiento**: Navigator de Flutter estándar

### Preparación para Futuro
- Provider está importado en `pubspec.yaml` para facilitar escalado
- Estructura preparada para migrar a Provider/Riverpod en versiones futuras

## Temas de Color

El tema de la aplicación usa **tonos azules**:
- Color primario: `Colors.blue[700]`
- Color de fondo: `Colors.blue[50]`
- Estados visuales:
  - Pendiente: Naranja
  - En ruta: Azul
  - En curso: Púrpura
  - Finalizado: Verde

## Estructura del Código

### Convenciones
- **Nombres de pantallas**: `*_screen.dart`
- **Nombres de modelos**: Singular (e.g., `usuario.dart`, `aviso.dart`)
- **Nombres de servicios**: `*_service.dart`
- **Nombres de variables**: camelCase
- **Nombres de clases**: PascalCase

### Organización
```
lib/
├── main.dart                     # Entrada de la app
├── models/                       # Modelos de datos
│   ├── usuario.dart
│   ├── aviso.dart
│   └── documento.dart
├── screens/                      # Pantallas (UI)
│   ├── login_screen.dart
│   ├── home_screen.dart
│   ├── agenda_screen.dart
│   └── aviso_detalle_screen.dart
├── services/                     # Lógica de negocio
│   └── api_service.dart
└── widgets/                      # (Preparado para componentes reutilizables)
```

## Integración de Plugins

### image_picker
```dart
final picker = ImagePicker();
final pickedFile = await picker.pickImage(source: ImageSource.camera);
final pickedFiles = await picker.pickMultiImage();  // Múltiples fotos
```

### intl
```dart
import 'package:intl/intl.dart';
DateFormat('dd/MM/yyyy').format(date);  // Formato de fecha
```

## Manejo de Errores y Estados de Carga

### Patrones Utilizados
- **FutureBuilder**: Para cargar datos asincronamente
- **CircularProgressIndicator**: Indicadores de carga
- **SnackBar**: Notificaciones al usuario
- **AlertDialog**: Confirmaciones

### Ejemplo
```dart
FutureBuilder<List<Aviso>>(
  future: _avisosFuture,
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const CircularProgressIndicator();
    }
    if (snapshot.hasError) {
      return Text('Error: ${snapshot.error}');
    }
    final avisos = snapshot.data ?? [];
    return ListView(children: avisos.map((a) => ...));
  },
)
```

## Seguridad en la Versión Beta

⚠️ **Notas de Seguridad**
- Las contraseñas están en texto plano en datos mock (solo demo)
- No hay encriptación en esta versión
- La API real debe implementar:
  - Autenticación con tokens (JWT)
  - HTTPS
  - Validación de permisos en servidor
  - Encriptación de datos

## Próximas Mejoras (Versión 1.0)

### Backend
- [ ] API REST con Node.js/Django/Java
- [ ] Base de datos PostgreSQL/MySQL
- [ ] Autenticación OAuth2/JWT
- [ ] Almacenamiento de archivos en servidor

### Frontend
- [ ] Integración con API real
- [ ] Panel de administrador
- [ ] Notificaciones push
- [ ] Modo offline con sincronización
- [ ] Firma digital
- [ ] Reportes descargables

### DevOps
- [ ] CI/CD (GitHub Actions)
- [ ] Testing automático
- [ ] APK/Play Store deployment

## Rendimiento y Optimización

### Optimizaciones Actuales
- Uso de `const` constructores
- FutureBuilder para cargas asincrónicas
- SingleChildScrollView para scroll eficiente

### Optimizaciones Futuras
- Caché de datos con Hive/SQLite
- Lazy loading de imágenes
- Paginación en listas grandes
- State management con Provider/Riverpod

## Testing

### Estructura preparada para testing
```
test/
└── widget_test.dart  (existente)
```

### Tests a Implementar
- [ ] Pruebas unitarias de modelos
- [ ] Pruebas de servicios
- [ ] Pruebas de widgets (Screenshot testing)
- [ ] Pruebas de integración

---

**Versión**: 0.1.0-beta
**Última actualización**: Marzo 2026
**Desarrolladores**: [Nombre de los desarrolladores]
