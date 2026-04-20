<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

$servername = "localhost";
$username = "root";
$password = "";
$dbname = "reparapp";

// Crear conexión
$conn = new mysqli($servername, $username, $password, $dbname);

// Verificar conexión
if ($conn->connect_error) {
    echo json_encode([
        'success' => false,
        'error' => 'Error de conexión: ' . $conn->connect_error
    ]);
    exit;
}

// Verificar que la tabla usuarios existe
$result = $conn->query("SELECT COUNT(*) as count FROM usuarios");
if (!$result) {
    echo json_encode([
        'success' => false,
        'error' => 'Tabla usuarios no existe: ' . $conn->error
    ]);
    exit;
}

$row = $result->fetch_assoc();

echo json_encode([
    'success' => true,
    'message' => 'Conexión OK',
    'database' => $dbname,
    'usuarios_count' => $row['count']
]);

$conn->close();
?>
