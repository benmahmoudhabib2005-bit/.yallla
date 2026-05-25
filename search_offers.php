<?php
require __DIR__ . '/config.php';

$keyword = trim($_GET['keyword'] ?? '');
$location = trim($_GET['location'] ?? '');
$where = [];
$params = [];

if ($keyword !== '') {
    $where[] = '(titre LIKE ? OR entreprise LIKE ? OR description LIKE ? OR type_contrat LIKE ?)';
    $like = "%$keyword%";
    array_push($params, $like, $like, $like, $like);
}
if ($location !== '') {
    $where[] = 'ville LIKE ?';
    $params[] = "%$location%";
}

$sql = 'SELECT id, titre, entreprise, type_contrat, ville, salaire, logo, DATEDIFF(NOW(), created_at) AS jours_passes FROM offers';
if ($where) $sql .= ' WHERE ' . implode(' AND ', $where);
$sql .= ' ORDER BY created_at DESC LIMIT 50';

$stmt = $pdo->prepare($sql);
$stmt->execute($params);
echo json_encode(['success' => true, 'offers' => $stmt->fetchAll()]);
