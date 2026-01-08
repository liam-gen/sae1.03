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

<h1>Liste des départements</h1>

<table>
    <thead>
        <tr>
            <th>Nom</th>
            <th>Numéro</th>
        </tr>
    </thead>
    <tbody>

        <?php foreach ($departements as $nom => $numero): ?>
            <tr>
                <td><?= htmlspecialchars($nom) ?></td>
                <td><?= htmlspecialchars($numero) ?></td>
            </tr>
        <?php endforeach; ?>

    </tbody>
</table>

</body>
</html>
