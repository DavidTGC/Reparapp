<?php
// Configuración de conexión a la base de datos

$servername = "localhost";
$username = "root";
$password = "";
$dbname = "reparapp";

// Crear conexión
$conn = new mysqli($servername, $username, $password, $dbname);

// Verificar conexión
if ($conn->connect_error) {
    http_response_code(500);
    die(json_encode(['error' => 'Error de conexión a la base de datos: ' . $conn->connect_error]));
}

// Establecer charset
$conn->set_charset("utf8mb4");

// Configurar zona horaria
date_default_timezone_set('Europe/Madrid');

?>
