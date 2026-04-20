<?php
require_once '../config/database.php';

$method = $_SERVER['REQUEST_METHOD'];
$request = explode('/', trim($_SERVER['PATH_INFO'] ?? '', '/'));

if (empty($request[0])) {
    http_response_code(400);
    echo json_encode(['error' => 'Endpoint no especificado']);
    exit();
}

switch ($request[0]) {
    case 'avisos':
        if ($method === 'GET') {
            getAvisos();
        } elseif ($method === 'POST') {
            createAviso();
        } elseif ($method === 'PUT') {
            updateAviso();
        } elseif ($method === 'DELETE') {
            deleteAviso();
        } else {
            http_response_code(405);
            echo json_encode(['error' => 'Método no permitido']);
        }
        break;
    case 'avisos-por-operario':
        if ($method === 'GET') {
            getAvisosPorOperario();
        } else {
            http_response_code(405);
            echo json_encode(['error' => 'Método no permitido']);
        }
        break;
    default:
        http_response_code(404);
        echo json_encode(['error' => 'Endpoint no encontrado']);
}

function getAvisos() {
    global $conn;
    $query = "SELECT 
        a.id, a.titulo, a.descripcion, a.direccion, a.ciudad, a.fecha, a.hora, a.estado, a.prioridad,
        a.tipo_servicio, a.id_operario, a.notas, a.firma, a.id_cliente,
        c.nombre as nombre_cliente, c.telefono as telefono_cliente
    FROM avisos a
    LEFT JOIN clientes c ON a.id_cliente = c.id
    ORDER BY a.fecha DESC";
    $result = $conn->query($query);

    if (!$result) {
        http_response_code(500);
        echo json_encode(['error' => 'Error en la consulta: ' . $conn->error]);
        exit();
    }

    $avisos = [];
    while ($row = $result->fetch_assoc()) {
        $row['id'] = (int)$row['id'];
        $row['id_cliente'] = (int)$row['id_cliente'];
        $row['id_operario'] = (int)$row['id_operario'];
        // Convertir snake_case a camelCase
        $row['idCliente'] = $row['id_cliente'];
        $row['idOperario'] = $row['id_operario'];
        $row['tipoServicio'] = $row['tipo_servicio'];
        $row['nombreCliente'] = $row['nombre_cliente'] ?? '';
        $row['telefonoCliente'] = $row['telefono_cliente'] ?? '';
        // Remover las versiones snake_case
        unset($row['id_operario']);
        unset($row['id_cliente']);
        unset($row['tipo_servicio']);
        unset($row['nombre_cliente']);
        unset($row['telefono_cliente']);
        $avisos[] = $row;
    }

    echo json_encode(['success' => true, 'data' => $avisos]);
}

function getAvisosPorOperario() {
    global $conn;
    $idOperario = isset($_GET['id_operario']) ? intval($_GET['id_operario']) : 0;

    if ($idOperario === 0) {
        http_response_code(400);
        echo json_encode(['error' => 'id_operario es requerido']);
        exit();
    }

    $query = "SELECT 
        a.id, a.titulo, a.descripcion, a.direccion, a.ciudad, a.fecha, a.hora, a.estado, a.prioridad,
        a.tipo_servicio, a.id_operario, a.notas, a.firma, a.id_cliente,
        c.nombre as nombre_cliente, c.telefono as telefono_cliente
    FROM avisos a
    LEFT JOIN clientes c ON a.id_cliente = c.id
    WHERE a.id_operario = $idOperario
    ORDER BY a.fecha DESC";
    $result = $conn->query($query);

    if (!$result) {
        http_response_code(500);
        echo json_encode(['error' => 'Error en la consulta: ' . $conn->error]);
        exit();
    }

    $avisos = [];
    while ($row = $result->fetch_assoc()) {
        $row['id'] = (int)$row['id'];
        $row['id_cliente'] = (int)$row['id_cliente'];
        $row['id_operario'] = (int)$row['id_operario'];
        // Convertir snake_case a camelCase
        $row['idCliente'] = $row['id_cliente'];
        $row['idOperario'] = $row['id_operario'];
        $row['tipoServicio'] = $row['tipo_servicio'];
        $row['nombreCliente'] = $row['nombre_cliente'] ?? '';
        $row['telefonoCliente'] = $row['telefono_cliente'] ?? '';
        // Remover las versiones snake_case
        unset($row['id_operario']);
        unset($row['tipo_servicio']);
        unset($row['nombre_cliente']);
        unset($row['telefono_cliente']);
        $avisos[] = $row;
    }

    echo json_encode(['success' => true, 'data' => $avisos]);
}

function createAviso() {
    global $conn;
    $data = json_decode(file_get_contents("php://input"), true);

    if (!isset($data['titulo']) || !isset($data['fecha']) || !isset($data['id_operario'])) {
        http_response_code(400);
        echo json_encode(['error' => 'Campos requeridos: titulo, fecha, id_operario']);
        exit();
    }

    $titulo = $conn->real_escape_string($data['titulo']);
    $descripcion = $conn->real_escape_string($data['descripcion'] ?? '');
    $direccion = $conn->real_escape_string($data['direccion'] ?? '');
    $fecha = $conn->real_escape_string($data['fecha']);
    $hora = $conn->real_escape_string($data['hora'] ?? '');
    $estado = $conn->real_escape_string($data['estado'] ?? 'pendiente');
    $tipoServicio = $conn->real_escape_string($data['tipoServicio'] ?? '');
    $nombreCliente = $conn->real_escape_string($data['nombreCliente'] ?? '');
    $telefonoCliente = $conn->real_escape_string($data['telefonoCliente'] ?? '');
    $idOperario = intval($data['id_operario']);
    $notas = $conn->real_escape_string($data['notas'] ?? '');

    $query = "INSERT INTO avisos (titulo, descripcion, direccion, fecha, hora, estado, tipo_servicio, nombre_cliente, telefono_cliente, id_operario, notas) VALUES ('$titulo', '$descripcion', '$direccion', '$fecha', '$hora', '$estado', '$tipoServicio', '$nombreCliente', '$telefonoCliente', $idOperario, '$notas')";

    if ($conn->query($query)) {
        http_response_code(201);
        echo json_encode(['success' => true, 'id' => $conn->insert_id]);
    } else {
        http_response_code(400);
        echo json_encode(['error' => 'Error al crear aviso: ' . $conn->error]);
    }
}

function updateAviso() {
    global $conn;
    $data = json_decode(file_get_contents("php://input"), true);

    if (!isset($data['id'])) {
        http_response_code(400);
        echo json_encode(['error' => 'ID es requerido']);
        exit();
    }

    $id = intval($data['id']);
    $updateFields = [];

    if (isset($data['titulo'])) $updateFields[] = "titulo = '" . $conn->real_escape_string($data['titulo']) . "'";
    if (isset($data['descripcion'])) $updateFields[] = "descripcion = '" . $conn->real_escape_string($data['descripcion']) . "'";
    if (isset($data['direccion'])) $updateFields[] = "direccion = '" . $conn->real_escape_string($data['direccion']) . "'";
    if (isset($data['fecha'])) $updateFields[] = "fecha = '" . $conn->real_escape_string($data['fecha']) . "'";
    if (isset($data['hora'])) $updateFields[] = "hora = '" . $conn->real_escape_string($data['hora']) . "'";
    if (isset($data['estado'])) $updateFields[] = "estado = '" . $conn->real_escape_string($data['estado']) . "'";
    if (isset($data['tipoServicio'])) $updateFields[] = "tipo_servicio = '" . $conn->real_escape_string($data['tipoServicio']) . "'";
    if (isset($data['nombreCliente'])) $updateFields[] = "nombre_cliente = '" . $conn->real_escape_string($data['nombreCliente']) . "'";
    if (isset($data['telefonoCliente'])) $updateFields[] = "telefono_cliente = '" . $conn->real_escape_string($data['telefonoCliente']) . "'";
    if (isset($data['notas'])) $updateFields[] = "notas = '" . $conn->real_escape_string($data['notas']) . "'";
    if (isset($data['firma'])) $updateFields[] = "firma = '" . $conn->real_escape_string($data['firma']) . "'";

    if (empty($updateFields)) {
        http_response_code(400);
        echo json_encode(['error' => 'No hay campos para actualizar']);
        exit();
    }

    $query = "UPDATE avisos SET " . implode(', ', $updateFields) . " WHERE id = $id";

    if ($conn->query($query)) {
        echo json_encode(['success' => true, 'message' => 'Aviso actualizado']);
    } else {
        http_response_code(400);
        echo json_encode(['error' => 'Error al actualizar aviso: ' . $conn->error]);
    }
}

function deleteAviso() {
    global $conn;
    $data = json_decode(file_get_contents("php://input"), true);

    if (!isset($data['id'])) {
        http_response_code(400);
        echo json_encode(['error' => 'ID es requerido']);
        exit();
    }

    $id = intval($data['id']);
    $query = "DELETE FROM avisos WHERE id = $id";

    if ($conn->query($query)) {
        echo json_encode(['success' => true, 'message' => 'Aviso eliminado']);
    } else {
        http_response_code(400);
        echo json_encode(['error' => 'Error al eliminar aviso: ' . $conn->error]);
    }
}
?>
