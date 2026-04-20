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

// Incluir archivo de conexión
require_once __DIR__ . '/../database/database.php';

// Obtener la acción desde el PATH_INFO
$action = isset($_SERVER['PATH_INFO']) ? ltrim($_SERVER['PATH_INFO'], '/') : '';

switch ($action) {
    case 'clientes':
        if ($_SERVER['REQUEST_METHOD'] === 'GET') {
            getClientes();
        } elseif ($_SERVER['REQUEST_METHOD'] === 'POST') {
            createCliente();
        } elseif ($_SERVER['REQUEST_METHOD'] === 'PUT') {
            updateCliente();
        } elseif ($_SERVER['REQUEST_METHOD'] === 'DELETE') {
            deleteCliente();
        } else {
            http_response_code(405);
            echo json_encode(['success' => false, 'error' => 'Método no permitido']);
        }
        break;

    default:
        http_response_code(404);
        echo json_encode(['success' => false, 'error' => 'Endpoint no encontrado']);
}

// Obtener todos los clientes
function getClientes() {
    global $conn;

    $query = "SELECT id, nombre, dni, telefono, fecha_creacion 
              FROM clientes 
              ORDER BY nombre ASC";

    $result = $conn->query($query);

    if (!$result) {
        http_response_code(500);
        return json_encode(['success' => false, 'error' => $conn->error]);
    }

    $clientes = [];
    while ($row = $result->fetch_assoc()) {
        // Type casting for numeric fields
        $row['id'] = (int)$row['id'];
        $clientes[] = $row;
    }

    http_response_code(200);
    echo json_encode([
        'success' => true,
        'data' => $clientes
    ]);
}

// Crear nuevo cliente
function createCliente() {
    global $conn;
    $data = json_decode(file_get_contents("php://input"), true);

    $nombre = $conn->real_escape_string($data['nombre']);
    $dni = $conn->real_escape_string(strtoupper($data['dni']));
    $telefono = $conn->real_escape_string($data['telefono']);

    // Validar DNI
    if (!validarDNIEspanol($dni)) {
        http_response_code(400);
        echo json_encode(['success' => false, 'error' => 'DNI inválido. Formato: 12345678A']);
        return;
    }

    $query = "INSERT INTO clientes (nombre, dni, telefono) 
              VALUES ('$nombre', '$dni', '$telefono')";

    if (!$conn->query($query)) {
        // Verificar si es error de DNI duplicado
        if (strpos($conn->error, 'Duplicate entry') !== false) {
            http_response_code(400);
            echo json_encode(['success' => false, 'error' => 'El DNI ya está registrado']);
            return;
        }

        http_response_code(500);
        echo json_encode(['success' => false, 'error' => $conn->error]);
        return;
    }

    $newClienteId = $conn->insert_id;

    http_response_code(201);
    echo json_encode([
        'success' => true,
        'data' => [
            'id' => (int)$newClienteId,
            'nombre' => $nombre,
            'dni' => $dni,
            'telefono' => $telefono
        ]
    ]);
}

// Actualizar cliente
function updateCliente() {
    global $conn;
    $data = json_decode(file_get_contents("php://input"), true);

    if (!isset($data['id'])) {
        http_response_code(400);
        echo json_encode(['success' => false, 'error' => 'ID de cliente requerido']);
        return;
    }

    $id = intval($data['id']);
    $updates = [];

    if (isset($data['nombre']) && $data['nombre'] !== null) {
        $value = $conn->real_escape_string($data['nombre']);
        $updates[] = "`nombre` = '$value'";
    }

    if (isset($data['telefono']) && $data['telefono'] !== null) {
        $value = $conn->real_escape_string($data['telefono']);
        $updates[] = "`telefono` = '$value'";
    }

    if (isset($data['dni']) && $data['dni'] !== null) {
        $dni = strtoupper($conn->real_escape_string($data['dni']));
        if (!validarDNIEspanol($dni)) {
            http_response_code(400);
            echo json_encode(['success' => false, 'error' => 'DNI inválido. Formato: 12345678A']);
            return;
        }
        $updates[] = "`dni` = '$dni'";
    }

    if (empty($updates)) {
        http_response_code(400);
        echo json_encode(['success' => false, 'error' => 'No hay campos para actualizar']);
        return;
    }

    $query = "UPDATE clientes SET " . implode(', ', $updates) . " WHERE id = $id";

    if (!$conn->query($query)) {
        if (strpos($conn->error, 'Duplicate entry') !== false) {
            http_response_code(400);
            echo json_encode(['success' => false, 'error' => 'El DNI ya está registrado']);
            return;
        }

        http_response_code(500);
        echo json_encode(['success' => false, 'error' => $conn->error]);
        return;
    }

    http_response_code(200);
    echo json_encode(['success' => true, 'data' => ['id' => $id]]);
}

// Eliminar cliente
function deleteCliente() {
    global $conn;
    $data = json_decode(file_get_contents("php://input"), true);

    if (!isset($data['id'])) {
        http_response_code(400);
        echo json_encode(['success' => false, 'error' => 'ID de cliente requerido']);
        return;
    }

    $id = intval($data['id']);

    $query = "DELETE FROM clientes WHERE id = $id";

    if (!$conn->query($query)) {
        http_response_code(500);
        echo json_encode(['success' => false, 'error' => $conn->error]);
        return;
    }

    http_response_code(200);
    echo json_encode(['success' => true, 'data' => ['id' => $id]]);
}

// Validar DNI español (formato: 8 dígitos + 1 letra mayúscula)
function validarDNIEspanol($dni) {
    $dni = strtoupper($dni);
    return preg_match('/^\d{8}[A-Z]$/', $dni) === 1;
}

?>
