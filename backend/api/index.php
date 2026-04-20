<?php
// index.php - Router principal para la API

require_once '../config/database.php';

// Obtener la ruta solicitada
$request = $_SERVER['REQUEST_URI'];
$basePath = '/backend/api/';

if (strpos($request, $basePath) === 0) {
    $path = substr($request, strlen($basePath));
} else {
    $path = $request;
}

// Eliminar parámetros query
$path = explode('?', $path)[0];
$path = trim($path, '/');

// Dividir la ruta en segmentos
$segments = explode('/', $path);
$endpoint = $segments[0] ?? '';

// Enrutar a los archivos correspondientes
switch ($endpoint) {
    case 'usuarios':
    case 'login':
        $_SERVER['PATH_INFO'] = '/' . $path;
        require 'usuarios.php';
        break;
    case 'avisos':
    case 'avisos-por-operario':
        $_SERVER['PATH_INFO'] = '/' . $path;
        require 'avisos.php';
        break;
    case 'documentos':
    case 'documentos-por-aviso':
        $_SERVER['PATH_INFO'] = '/' . $path;
        require 'documentos.php';
        break;
    default:
        http_response_code(404);
        echo json_encode(['error' => 'Endpoint no encontrado']);
}
?>
