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
    case 'login':
        handleLogin();
        break;
    case 'usuarios':
        if ($method === 'GET') {
            getUsuarios();
        } elseif ($method === 'POST') {
            createUsuario();
        } elseif ($method === 'PUT') {
            updateUsuario();
        } elseif ($method === 'DELETE') {
            deleteUsuario();
        } else {
            http_response_code(405);
            echo json_encode(['error' => 'Método no permitido']);
        }
        break;
    default:
        http_response_code(404);
        echo json_encode(['error' => 'Endpoint no encontrado']);
}

function handleLogin() {
    global $conn;
    $data = json_decode(file_get_contents("php://input"), true);

    if (!isset($data['email']) || !isset($data['password'])) {
        http_response_code(400);
        echo json_encode(['error' => 'Email y password son requeridos']);
        exit();
    }

    $email = $conn->real_escape_string($data['email']);
    $password = md5($data['password']);

    $query = "SELECT id, nombre, email, telefono, rol FROM usuarios WHERE email = '$email' AND password = '$password' AND activo = TRUE";
    $result = $conn->query($query);

    if (!$result) {
        http_response_code(500);
        echo json_encode(['error' => 'Error en la consulta: ' . $conn->error]);
        exit();
    }

    if ($result->num_rows > 0) {
        $usuario = $result->fetch_assoc();
        // Convertir id a int, mantener telefono como string
        $usuario['id'] = (int)$usuario['id'];
        $usuario['telefono'] = (string)$usuario['telefono'];
        echo json_encode(['success' => true, 'data' => $usuario]);
    } else {
        http_response_code(401);
        echo json_encode(['error' => 'Credenciales inválidas']);
    }
}

function getUsuarios() {
    global $conn;
    $query = "SELECT id, nombre, email, telefono, rol FROM usuarios WHERE activo = TRUE";
    $result = $conn->query($query);

    if (!$result) {
        http_response_code(500);
        echo json_encode(['error' => 'Error en la consulta: ' . $conn->error]);
        exit();
    }

    $usuarios = [];
    while ($row = $result->fetch_assoc()) {
        // Convertir id a int, mantener telefono como string
        $row['id'] = (int)$row['id'];
        $row['telefono'] = (string)$row['telefono'];
        $usuarios[] = $row;
    }

    echo json_encode(['success' => true, 'data' => $usuarios]);
}

function createUsuario() {
    global $conn;
    $data = json_decode(file_get_contents("php://input"), true);

    if (!isset($data['nombre']) || !isset($data['email']) || !isset($data['password'])) {
        http_response_code(400);
        echo json_encode(['error' => 'Campos requeridos: nombre, email, password']);
        exit();
    }

    $nombre = $conn->real_escape_string($data['nombre']);
    $email = $conn->real_escape_string($data['email']);
    $telefono = $conn->real_escape_string($data['telefono'] ?? '');
    $rol = $conn->real_escape_string($data['rol'] ?? 'operario');
    $password = md5($data['password']);

    $query = "INSERT INTO usuarios (nombre, email, telefono, rol, password) VALUES ('$nombre', '$email', '$telefono', '$rol', '$password')";

    if ($conn->query($query)) {
        http_response_code(201);
        echo json_encode(['success' => true, 'id' => (int)$conn->insert_id]);
    } else {
        http_response_code(400);
        echo json_encode(['error' => 'Error al crear usuario: ' . $conn->error]);
    }
}

function updateUsuario() {
    global $conn;
    $data = json_decode(file_get_contents("php://input"), true);

    if (!isset($data['id'])) {
        http_response_code(400);
        echo json_encode(['error' => 'ID es requerido']);
        exit();
    }

    $id = intval($data['id']);
    $nombre = $conn->real_escape_string($data['nombre'] ?? '');
    $email = $conn->real_escape_string($data['email'] ?? '');
    $telefono = $conn->real_escape_string($data['telefono'] ?? '');
    $rol = $conn->real_escape_string($data['rol'] ?? 'operario');

    $updateFields = [];
    if ($nombre) $updateFields[] = "nombre = '$nombre'";
    if ($email) $updateFields[] = "email = '$email'";
    if ($telefono) $updateFields[] = "telefono = '$telefono'";
    if ($rol) $updateFields[] = "rol = '$rol'";

    if (empty($updateFields)) {
        http_response_code(400);
        echo json_encode(['error' => 'No hay campos para actualizar']);
        exit();
    }

    $query = "UPDATE usuarios SET " . implode(', ', $updateFields) . " WHERE id = $id";

    if ($conn->query($query)) {
        echo json_encode(['success' => true, 'message' => 'Usuario actualizado']);
    } else {
        http_response_code(400);
        echo json_encode(['error' => 'Error al actualizar usuario: ' . $conn->error]);
    }
}

function deleteUsuario() {
    global $conn;
    $data = json_decode(file_get_contents("php://input"), true);

    if (!isset($data['id'])) {
        http_response_code(400);
        echo json_encode(['error' => 'ID es requerido']);
        exit();
    }

    $id = intval($data['id']);
    $query = "UPDATE usuarios SET activo = FALSE WHERE id = $id";

    if ($conn->query($query)) {
        echo json_encode(['success' => true, 'message' => 'Usuario eliminado']);
    } else {
        http_response_code(400);
        echo json_encode(['error' => 'Error al eliminar usuario: ' . $conn->error]);
    }
}
?>
