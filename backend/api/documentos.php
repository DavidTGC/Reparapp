<?php
// CORS headers
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');
header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

require_once '../database/database.php';

$method = $_SERVER['REQUEST_METHOD'];
$request = explode('/', trim($_SERVER['PATH_INFO'] ?? '', '/'));

if (empty($request[0])) {
    http_response_code(400);
    echo json_encode(['error' => 'Endpoint no especificado']);
    exit();
}

switch ($request[0]) {
    case 'documentos':
        if ($method === 'GET') {
            getDocumentos();
        } elseif ($method === 'POST') {
            uploadDocumento();
        } elseif ($method === 'DELETE') {
            deleteDocumento();
        } else {
            http_response_code(405);
            echo json_encode(['error' => 'Método no permitido']);
        }
        break;
    case 'documentos-por-aviso':
        if ($method === 'GET') {
            getDocumentosPorAviso();
        } else {
            http_response_code(405);
            echo json_encode(['error' => 'Método no permitido']);
        }
        break;
    default:
        http_response_code(404);
        echo json_encode(['error' => 'Endpoint no encontrado']);
}

function getDocumentos() {
    global $conn;
    $query = "SELECT id, id_aviso, tipo, ruta_archivo, nombre_archivo, mime_type, tamaño_bytes, fecha_subida FROM documentos ORDER BY fecha_subida DESC";
    $result = $conn->query($query);

    if (!$result) {
        http_response_code(500);
        echo json_encode(['error' => 'Error en la consulta: ' . $conn->error]);
        exit();
    }

    $documentos = [];
    while ($row = $result->fetch_assoc()) {
        // Generar URL completa para acceder a la imagen
        $row['url_acceso'] = 'http://' . $_SERVER['HTTP_HOST'] . '/reparapp/backend/' . $row['ruta_archivo'];
        $documentos[] = $row;
    }

    echo json_encode(['success' => true, 'data' => $documentos]);
}

function getDocumentosPorAviso() {
    global $conn;
    $idAviso = isset($_GET['id_aviso']) ? intval($_GET['id_aviso']) : 0;

    if ($idAviso === 0) {
        http_response_code(400);
        echo json_encode(['error' => 'id_aviso es requerido']);
        exit();
    }

    $query = "SELECT id, id_aviso, tipo, ruta_archivo, nombre_archivo, mime_type, tamaño_bytes, fecha_subida FROM documentos WHERE id_aviso = $idAviso ORDER BY fecha_subida DESC";
    $result = $conn->query($query);

    if (!$result) {
        http_response_code(500);
        echo json_encode(['error' => 'Error en la consulta: ' . $conn->error]);
        exit();
    }

    $documentos = [];
    while ($row = $result->fetch_assoc()) {
        // Convertir tipos
        $row['id'] = (int)$row['id'];
        $row['id_aviso'] = (int)$row['id_aviso'];
        $row['tamaño_bytes'] = (int)$row['tamaño_bytes'];
        
        // Generar URL RELATIVA AL DOMINIO (funciona desde cualquier puerto)
        $row['url_acceso'] = '/reparapp/backend/' . $row['ruta_archivo'];
        
        // Convertir snake_case a camelCase
        $row['idAviso'] = $row['id_aviso'];
        $row['ruta'] = $row['ruta_archivo'];
        $row['nombre'] = $row['nombre_archivo'];
        $row['fechaSubida'] = $row['fecha_subida'];
        
        // Eliminar campos snake_case
        unset($row['id_aviso']);
        unset($row['ruta_archivo']);
        unset($row['nombre_archivo']);
        unset($row['fecha_subida']);
        
        $documentos[] = $row;
    }

    echo json_encode(['success' => true, 'data' => $documentos]);
}

function uploadDocumento() {
    global $conn;

    if (!isset($_POST['id_aviso']) || !isset($_FILES['archivo'])) {
        http_response_code(400);
        echo json_encode(['error' => 'id_aviso y archivo son requeridos']);
        exit();
    }

    $idAviso = intval($_POST['id_aviso']);
    $tipo = $_POST['tipo'] ?? 'foto_durante';
    $archivo = $_FILES['archivo'];

    // Validar que el aviso existe
    $queryAviso = "SELECT id FROM avisos WHERE id = $idAviso";
    $result = $conn->query($queryAviso);
    if ($result->num_rows === 0) {
        http_response_code(404);
        echo json_encode(['error' => 'Aviso no encontrado']);
        exit();
    }

    // Validar archivo
    if ($archivo['error'] !== UPLOAD_ERR_OK) {
        http_response_code(400);
        echo json_encode(['error' => 'Error al subir archivo: ' . $archivo['error']]);
        exit();
    }

    // Crear directorio de uploads si no existe
    $uploadDir = __DIR__ . '/../uploads/';
    if (!is_dir($uploadDir)) {
        if (!mkdir($uploadDir, 0755, true)) {
            http_response_code(500);
            echo json_encode(['error' => 'No se pudo crear directorio de uploads']);
            exit();
        }
    }

    // Crear subdirectorio por aviso
    $avisoDir = $uploadDir . 'aviso_' . $idAviso . '/';
    if (!is_dir($avisoDir)) {
        if (!mkdir($avisoDir, 0755, true)) {
            http_response_code(500);
            echo json_encode(['error' => 'No se pudo crear directorio para el aviso']);
            exit();
        }
    }

    // Generar nombre único para el archivo
    $nombreOriginal = basename($archivo['name']);
    $extension = strtolower(pathinfo($nombreOriginal, PATHINFO_EXTENSION));
    $nombreSinExt = pathinfo($nombreOriginal, PATHINFO_FILENAME);
    $nombreUnico = preg_replace('/[^a-zA-Z0-9_-]/', '_', $nombreSinExt) . '_' . time() . '.' . $extension;
    $rutaCompleta = $avisoDir . $nombreUnico;

    // Validar tipo de archivo
    $tiposPermitidos = ['jpg', 'jpeg', 'png', 'gif', 'pdf', 'doc', 'docx'];
    if (!in_array($extension, $tiposPermitidos)) {
        http_response_code(400);
        echo json_encode(['error' => 'Tipo de archivo no permitido. Formatos: jpg, jpeg, png, gif, pdf, doc, docx']);
        exit();
    }

    // Validar tamaño máximo (10MB)
    $tamañoMaximo = 10 * 1024 * 1024; // 10MB
    if ($archivo['size'] > $tamañoMaximo) {
        http_response_code(400);
        echo json_encode(['error' => 'Archivo demasiado grande. Máximo 10MB']);
        exit();
    }

    // Mover archivo
    if (!move_uploaded_file($archivo['tmp_name'], $rutaCompleta)) {
        http_response_code(500);
        echo json_encode(['error' => 'Error al guardar archivo. Verifica permisos de carpeta']);
        exit();
    }

    // Obtener información del archivo
    $mimeType = mime_content_type($rutaCompleta) ?: 'application/octet-stream';
    $tamaño = filesize($rutaCompleta);

    // Guardar en base de datos - IMPORTANTE: Usar los nombres de columnas correctos
    $tipo = $conn->real_escape_string($tipo);
    $nombreArchivo = $conn->real_escape_string($nombreOriginal);
    // Guardar ruta relativa desde el backend
    $rutaRelativa = 'uploads/aviso_' . $idAviso . '/' . $nombreUnico;
    $rutaRelativa = $conn->real_escape_string($rutaRelativa);

    $query = "INSERT INTO documentos (id_aviso, tipo, nombre_archivo, ruta_archivo, mime_type, tamaño_bytes) 
              VALUES ($idAviso, '$tipo', '$nombreArchivo', '$rutaRelativa', '$mimeType', $tamaño)";

    if ($conn->query($query)) {
        http_response_code(201);
        $urlAcceso = 'http://' . $_SERVER['HTTP_HOST'] . '/reparapp/backend/' . $rutaRelativa;
        echo json_encode([
            'success' => true,
            'id' => $conn->insert_id,
            'nombre_archivo' => $nombreOriginal,
            'ruta_archivo' => $rutaRelativa,
            'url_acceso' => $urlAcceso,
            'mime_type' => $mimeType,
            'tamaño_bytes' => $tamaño
        ]);
    } else {
        // Eliminar archivo si falla la inserción en BD
        unlink($rutaCompleta);
        http_response_code(500);
        echo json_encode(['error' => 'Error al guardar documento en BD: ' . $conn->error]);
    }
}

function deleteDocumento() {
    global $conn;
    $data = json_decode(file_get_contents("php://input"), true);

    if (!isset($data['id'])) {
        http_response_code(400);
        echo json_encode(['error' => 'ID es requerido']);
        exit();
    }

    $id = intval($data['id']);

    // Obtener ruta del documento
    $query = "SELECT ruta_archivo FROM documentos WHERE id = $id";
    $result = $conn->query($query);

    if ($result->num_rows === 0) {
        http_response_code(404);
        echo json_encode(['error' => 'Documento no encontrado']);
        exit();
    }

    $documento = $result->fetch_assoc();
    // Construir ruta completa
    $rutaCompleta = __DIR__ . '/../' . $documento['ruta_archivo'];

    // Eliminar de base de datos primero
    $queryDelete = "DELETE FROM documentos WHERE id = $id";
    if ($conn->query($queryDelete)) {
        // Eliminar archivo físico
        if (file_exists($rutaCompleta)) {
            unlink($rutaCompleta);
        }
        echo json_encode(['success' => true, 'message' => 'Documento eliminado']);
    } else {
        http_response_code(400);
        echo json_encode(['error' => 'Error al eliminar documento: ' . $conn->error]);
    }
}
?>
