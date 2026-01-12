<!DOCTYPE html>
<html lang="fr">
<!-- Copyrights Titouan Moquet - 2026 -->
<head>
    <meta charset="UTF-8">
    <title>Départements</title>
    <style>
        @page {
            size: A4 landscape;
            margin: 1mm;
        }

        /* tableau de mise en page */
        table.layout {
            width: 100%;
            border-collapse: collapse;
        }

        table.layout td.col {
            width: 45%;
            vertical-align: top;
            padding: 2px;
            border: none;
        }

        /* vrais tableaux */
        table {
            width: 100%;
            font-size: 9px;
            border-collapse: collapse;
        }

        th, td {
            border: 1px solid black;
            padding: 1px 3px;
        }

        .img-container{
            align-self:center;
            justify-self:flex-end;
            margin-right:10px;
            margin-left:auto;
        }

        img{
            height: 40px;

            
        }
        header{
            display: flex;
            
        }
        h1{
            margin:10px;
            font-family:sans-serif;
            font-size:30px;
        }
        th{
            background-color:#bdbdbd;
        }

    </style>
</head>
<body>
    <?php
        $total = count($donnees);
        $milieu = ceil($total / 2); // arrondie au nb sup
        $donnees_gauche = array_slice($donnees, 0, $milieu);
        $donnees_droite = array_slice($donnees, $milieu);
    ?>
    <header>
        <h1><?= htmlspecialchars($TITRE) ?></h1>
        <div class="img-container">
            <img src="Logo-OFT-horizontal.jpg" alt="logo OFT">
        </div>
        
    </header>

    <table class="layout">
        <tr>
            <td class="col">
                <table>
                    <thead>
                        <tr>
                            <th>Nom du site</th>
                            <th>Code département</th>
                            <th>Nom département</th>
                            <th>Visiteurs</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php foreach ($donnees_gauche as $ligne): ?>
                            <tr>
                                <td><?= htmlspecialchars($ligne['nom']) ?></td>
                                <td><?= htmlspecialchars($ligne['departement']) ?></td>
                                <td><?= htmlspecialchars($ligne['nom_departement']) ?></td>
                                <td><?= (int)$ligne['nombre_visiteurs'] ?></td>
                            </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            </td>

            <td class="col">
                <table>
                    <thead>
                        <tr>
                            <th>Nom du site</th>
                            <th>Code département</th>
                            <th>Nom du département</th>
                            <th>Visiteurs</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php foreach ($donnees_droite as $ligne): ?>
                            <tr>
                                <td><?= htmlspecialchars($ligne['nom']) ?></td>
                                <td><?= htmlspecialchars($ligne['departement']) ?></td>
                                <td><?= htmlspecialchars($ligne['nom_departement']) ?></td>
                                <td><?= (int)$ligne['nombre_visiteurs'] ?></td>
                            </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            </td>
        </tr>
    </table>

</body>
</html>