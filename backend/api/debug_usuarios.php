<?php
// debug_usuarios.php - Endpoint para verificar que la BD funciona correctamente

require_once '../database/database.php';

header('Content-Type: application/json; charset=utf-8');

// Obtener todos los usuarios de la BD
$query = "SELECT id, nombre, email, telefono, rol, password FROM usuarios";
$result = $conn->query($query);

if (!$result) {
    echo json_encode([
        'error' => 'Error en la consulta: ' . $conn->error,
        'query' => $query
    ]);
    exit();
}

$usuarios = [];
while ($row = $result->fetch_assoc()) {
    $usuarios[] = $row;
}

echo json_encode([
    'total_usuarios' => count($usuarios),
    'usuarios' => $usuarios,
    'database_selected' => 'reparapp',
], JSON_UNESCAPED_UNICODE);
?>
