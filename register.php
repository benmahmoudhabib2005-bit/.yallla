<?php
require __DIR__ . '/config.php';

$prenom = required_post('prenom');
$nom = required_post('nom');
$email = filter_var(required_post('email'), FILTER_VALIDATE_EMAIL);
$password = $_POST['password'] ?? '';
$role = $_POST['role'] ?? 'etudiant';

if (!$email) {
    echo json_encode(['success' => false, 'message' => 'Email invalide.']);
    exit;
}
if (strlen($password) < 8) {
    echo json_encode(['success' => false, 'message' => 'Mot de passe trop court.']);
    exit;
}
if (!in_array($role, ['etudiant', 'entreprise'], true)) {
    $role = 'etudiant';
}

try {
    $stmt = $pdo->prepare('INSERT INTO users (prenom, nom, email, password_hash, role) VALUES (?, ?, ?, ?, ?)');
    $stmt->execute([$prenom, $nom, $email, password_hash($password, PASSWORD_DEFAULT), $role]);
    echo json_encode(['success' => true, 'id' => $pdo->lastInsertId()]);
} catch (PDOException $e) {
    $msg = $e->getCode() === '23000' ? 'Cet email existe déjà.' : 'Erreur inscription.';
    echo json_encode(['success' => false, 'message' => $msg]);
}
