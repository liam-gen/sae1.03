<?php
// Copyright Titouan Moquet - 2026

$ROUGE = "\033[31m";
$RESET = "\033[0m";
$CYAN = "\033[36m";
$GREEN = "\033[32m";

$nomFichier = $argv[1];
$nomFichierCsv = pathinfo($nomFichier, PATHINFO_FILENAME) . '.csv';

$nomFichierDep = $argv[2];
$lignesDep = file($nomFichierDep);

$nomFichierReg = $argv[3];
$lignesRegions = file($nomFichierReg);

$tabDep = [];
$numero = 1;

echo "${GREEN}INFO : Création tableau département ... $RESET\n\n";

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

echo "${GREEN}INFO : Création tableau des sites touristiques ... $RESET\n\n";

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


$regions = [];


foreach ($lignesRegions as $ligne) {

    $ligne = trim($ligne);
    if ($ligne === '') {
        continue;
    }

    $parts = explode('=', $ligne);
    $region = trim($parts[0]);

    $depsBruts = explode(',', $parts[1]);
    $departements = [];

    foreach ($depsBruts as $dep) {
        $departements[] = trim($dep);
    }

    $regions[$region] = $departements;
}

$sommeVisiteursParRegion = [];

// Initialisation : toutes les régions à 0
foreach ($regions as $region => $departements) {
    $sommeVisiteursParRegion[$region] = 0;
}

// Parcours des sites touristiques
foreach ($donnees as $site) {

    $departementSite = (string) $site['departement'];
    $visiteurs = (int) $site['nombre_visiteurs'];

    // Recherche de la région
    foreach ($regions as $region => $departements) {

        if (in_array($departementSite, $departements)) { // si le departemement est dans la region 
            $sommeVisiteursParRegion[$region] += $visiteurs;
            break; // on a trouvé la région, on sort
        }
    }
}


# CREATION DES HTML 

//1er sort sites-dept.html
usort($donnees, function ($a, $b) {
    return $a['departement'] <=> $b['departement'];
});


echo "${GREEN}INFO : Creation des HTML ...$RESET\n";

echo "${CYAN} |- sites-dept.html $RESET\n";
// inspiré d'un poste sur stackoverflow.com
// récupere le STDOUT du script php pour l'ecrire dans un fichier html 
$file1 = 'template-sites-dept.html';
ob_start();
require 'template-sites-dept.php'; 
$contents = ob_get_contents();
ob_end_clean();
file_put_contents($file1,$contents);

// 2eme sort sites-visites.html
echo "${CYAN} |- sites-visites.html  $RESET\n";

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

// sites-regions.html
echo "${CYAN} |- sites-regions.html  $RESET\n";

$file3 = 'template-sites-regions.html';
ob_start();
require 'template-sites-regions.php'; 
$contents3 = ob_get_contents();
ob_end_clean();
file_put_contents($file3,$contents3);


echo "${GREEN}\nINFO : Fin du PHP, copie des fichiers générés$RESET\n";

?>
