<?php
session_start();
header('Content-Type: application/json; charset=utf-8');

$DB_HOST = 'localhost';
$DB_NAME = 'yallawork';
$DB_USER = 'root';
$DB_PASS = '';

try {
    $pdo = new PDO(
        "mysql:host=$DB_HOST;dbname=$DB_NAME;charset=utf8mb4",
        $DB_USER,
        $DB_PASS,
        [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        ]
    );
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => 'Database connection failed']);
    exit;
}

function required_post(string $key): string {
    $value = trim($_POST[$key] ?? '');
    if ($value === '') {
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => "Missing field: $key"]);
        exit;
    }
    return $value;
}
