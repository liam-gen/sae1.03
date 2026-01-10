<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Départements</title>
    <style>
        table {
            border-collapse: collapse;
        }
        td, th {
            border: 1px solid black;
            padding: 5px;
        }
    </style>
</head>
<body>
    <table>
        <thead>
            <tr>
                <th>Nom</th>
                <th>Département</th>
                <th>Nom du département</th>
                <th>Visiteurs</th>
            </tr>
        </thead>
        <tbody>
            <?php 
                foreach ($donnees as $ligne): ?>
                <tr>
                    <td><?= htmlspecialchars($ligne['nom']) ?></td>
                    <td><?= htmlspecialchars($ligne['departement']) ?></td>
                    <td><?= htmlspecialchars($ligne['nom_departement']) ?></td>
                    <td><?= (int)$ligne['nombre_visiteurs'] ?></td>
                </tr>
            <?php endforeach; ?>
        </tbody>
    </table>
</body>
</html>