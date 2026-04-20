<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');

require_once('../database/database.php');

$query = "SELECT id, nombre, email, rol FROM usuarios";
$result = $conn->query($query);

if ($result) {
    $usuarios = [];
    while ($row = $result->fetch_assoc()) {
        $usuarios[] = $row;
    }
    echo json_encode([
        'success' => true,
        'total' => count($usuarios),
        'usuarios' => $usuarios
    ]);
} else {
    echo json_encode([
        'success' => false,
        'error' => $conn->error
    ]);
}
?>
