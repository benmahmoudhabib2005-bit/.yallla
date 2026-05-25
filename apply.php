<?php
require __DIR__ . '/config.php';

$prenom = required_post('prenom');
$nom = required_post('nom');
$email = filter_var(required_post('email'), FILTER_VALIDATE_EMAIL);
$lettre = trim($_POST['lettre'] ?? '');
$offre_id = (int)($_POST['offre_id'] ?? 0);

if (!$email) {
    echo json_encode(['success' => false, 'message' => 'Email invalide.']);
    exit;
}

$cvPath = null;
if (!empty($_FILES['cv']['name']) && $_FILES['cv']['error'] === UPLOAD_ERR_OK) {
    $allowed = ['pdf', 'doc', 'docx'];
    $ext = strtolower(pathinfo($_FILES['cv']['name'], PATHINFO_EXTENSION));
    if (!in_array($ext, $allowed, true)) {
        echo json_encode(['success' => false, 'message' => 'CV accepté: PDF, DOC, DOCX uniquement.']);
        exit;
    }
    $uploadDir = __DIR__ . '/../uploads/cv/';
    if (!is_dir($uploadDir)) mkdir($uploadDir, 0775, true);
    $fileName = uniqid('cv_', true) . '.' . $ext;
    $target = $uploadDir . $fileName;
    if (move_uploaded_file($_FILES['cv']['tmp_name'], $target)) {
        $cvPath = 'uploads/cv/' . $fileName;
    }
}

$stmt = $pdo->prepare('INSERT INTO applications (offer_id, prenom, nom, email, lettre, cv_path) VALUES (?, ?, ?, ?, ?, ?)');
$stmt->execute([$offre_id ?: null, $prenom, $nom, $email, $lettre, $cvPath]);
echo json_encode(['success' => true, 'application_id' => $pdo->lastInsertId()]);
