<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');

require_once('../database/database.php');

// Describir la tabla usuarios
$query = "DESCRIBE usuarios";
$result = $conn->query($query);

if ($result) {
    $columns = [];
    while ($row = $result->fetch_assoc()) {
        $columns[] = $row;
    }
    echo json_encode([
        'success' => true,
        'table' => 'usuarios',
        'columns' => $columns
    ]);
} else {
    echo json_encode([
        'success' => false,
        'error' => $conn->error
    ]);
}
?>
