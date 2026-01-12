<!DOCTYPE html>
<html lang="fr">
<!-- Copyrights Titouan Moquet - 2026 -->
<head>
    <meta charset="UTF-8">
    <title>Départements</title>
    <style>
        @page {
            size: A4 landscape;
            margin: 5mm;
        }

        /* vrais tableaux */
        table {
            font-size: 15px;
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
    <header>
        <h1>Somme visiteurs par régions</h1>
        <div class="img-container">
            <img src="Logo-OFT-horizontal.jpg" alt="logo OFT">
        </div>
        
    </header>

    <table>
        <thead>
            <tr>
                <th>Region</th>
                <th>Nombres de visiteurs</th>
            </tr>
        </thead>
            <tbody>
            <?php foreach ($sommeVisiteursParRegion as $region => $nombreVisiteurs): ?>
                <tr>
                    <td><?= htmlspecialchars($region) ?></td>
                    <td><?= (int) $nombreVisiteurs ?></td>
                </tr>
            <?php endforeach; ?>
            </tbody>
    </table>


</body>
</html>