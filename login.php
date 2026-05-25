<?php
require __DIR__ . '/config.php';

$email = filter_var(required_post('email'), FILTER_VALIDATE_EMAIL);
$password = $_POST['password'] ?? '';

if (!$email) {
    echo json_encode(['success' => false, 'message' => 'Email invalide.']);
    exit;
}

$stmt = $pdo->prepare('SELECT id, prenom, nom, email, password_hash, role FROM users WHERE email = ? LIMIT 1');
$stmt->execute([$email]);
$user = $stmt->fetch();

if (!$user || !password_verify($password, $user['password_hash'])) {
    echo json_encode(['success' => false, 'message' => 'Email ou mot de passe incorrect.']);
    exit;
}

$_SESSION['user_id'] = $user['id'];
$_SESSION['role'] = $user['role'];
echo json_encode(['success' => true, 'prenom' => $user['prenom'], 'role' => $user['role']]);
