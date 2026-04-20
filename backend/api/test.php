<?php
// test.php - Script de prueba para verificar la conexión

header('Content-Type: application/json; charset=utf-8');

echo json_encode([
    'mensaje' => 'Backend PHP funcionando correctamente',
    'php_version' => phpversion(),
    'servidor' => $_SERVER['SERVER_SOFTWARE'],
    'directorio' => __DIR__,
], JSON_UNESCAPED_UNICODE);

// Intentar conectar a MySQL
if (file_exists('../config/database.php')) {
    require_once '../database/database.php';
    
    if ($conn->connect_error) {
        echo json_encode(['error_mysql' => 'No se puede conectar a MySQL: ' . $conn->connect_error]);
    } else {
        echo json_encode([
            'mysql' => 'Conectado correctamente a MySQL',
            'base_datos' => 'reparapp',
        ]);
    }
} else {
    echo json_encode(['error' => 'database.php no encontrado']);
}
?>
