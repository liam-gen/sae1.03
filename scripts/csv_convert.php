<?php

$nomFichier = $argv[1];
$nomFichierCsv = pathinfo($nomFichier, PATHINFO_FILENAME) . '.csv';

$nomFichierDep = $argv[2];
$lignesDep = file($nomFichierDep);

$tabDep = [];
$numero = 1;

echo "\nCreation tableau département ... \n";

foreach ($lignesDep as $dep) {
    $dep = trim($dep);
    if ($dep === 'Corse-du-Sud') {
        $tabDep[$dep] = '2A';

    } else if ($dep === 'Haute-Corse') {
        $tabDep[$dep] = '2B';
        $numero = 21; // on reprend la numérotation après la Corse

    } else {
        // rajout de 0 avant si < 10 pour avoir 
        // toujours un format avec 2 caractères : 01, 02, ...
        if ($numero < 10) {
            $tabDep[$dep] = '0' . $numero;
        } else {
            $tabDep[$dep] = (string) $numero;
        }
        $numero++;
    }
}
echo "Ok \n";
echo "Creation tableau des sites touristiques ... \n";

function normaliserNumeroDep(string $num): string {
    if (is_numeric($num) && strlen($num) === 1) {
        return '0' . $num;
    }
    return $num;
}

$lignes = file($nomFichierCsv, FILE_IGNORE_NEW_LINES);
$donnees = [];

$depParNumero = array_flip($tabDep); // inverse le tableau : Ain 01 -> 01 - Ain 

foreach ($lignes as $ligne) {

    $champs = str_getcsv($ligne); 

    if (count($champs) === 3) { // verification si il y a bien 3 colonne dans le csv

        $numeroDep = normaliserNumeroDep(trim($champs[1]));

        $donnees[] = [
            'nom' => $champs[0],
            'departement' => $numeroDep,
            'nom_departement' => $depParNumero[$numeroDep] ?? 'Inconnu', // associe le nom du dep avec son numéro 
            'nombre_visiteurs' => (int) $champs[2]
        ];
    }
}

$depsPresents = [];

foreach ($donnees as $ligne) {
    $depsPresents[] = $ligne['departement'];
}
print_r($depsPresents);


foreach ($tabDep as $nomDep => $numDep) {

    if (!in_array($numDep, $depsPresents)) {
        $donnees[] = [
            'nom' => '',
            'departement' => $numDep,
            'nom_departement' => $nomDep,
            'nombre_visiteurs' => ''
        ];
    }
}

//1er sort
usort($donnees, function ($a, $b) {
    return $a['departement'] <=> $b['departement'];
});

echo "Ok \n";

echo "Creation des HTML ...\n";

// inspiré d'un poste sur stackoverflow.com
// récupere le STDOUT du script php pour l'ecrire dans un fichier html 

echo "sites-dept.html\n";

$file1 = 'template-sites-dept.html';
ob_start();
require 'template-sites-dept.php'; 
$contents = ob_get_contents();
ob_end_clean();
file_put_contents($file1,$contents);
//
echo "Ok \n";
echo "sites-visites.html\n";
// 2eme sort et 2eme fichier 


usort($donnees, function ($a, $b) {
    if ($a['nombre_visiteurs'] == $b['nombre_visiteurs']) {
        return $a['departement'] <=> $b['departement'];
    }
    return $b['nombre_visiteurs'] <=> $a['nombre_visiteurs'];
});

$file2 = 'template-sites-visites.html';
ob_start();
require 'template-sites-dept.php'; 
$contents2 = ob_get_contents();
ob_end_clean();
file_put_contents($file2,$contents2);


echo "Ok \n";

echo "Fin du php\n";

?>
