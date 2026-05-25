<?php
require __DIR__ . '/config.php';

$body = required_post('body');
$senderId = $_SESSION['user_id'] ?? null;
$receiverId = isset($_POST['receiver_id']) ? (int)$_POST['receiver_id'] : null;

$stmt = $pdo->prepare('INSERT INTO messages (sender_id, receiver_id, body) VALUES (?, ?, ?)');
$stmt->execute([$senderId, $receiverId, $body]);
echo json_encode(['success' => true, 'message_id' => $pdo->lastInsertId()]);
