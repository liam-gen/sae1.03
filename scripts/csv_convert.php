<?php
// Copyrights Titouan Moquet - 2026

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

$tabDep = [];// nomDep => numDep

$numero = 1;

echo "${GREEN}INFO : Création tableau département ... $RESET\n\n";

foreach ($lignesDep as $ligne) {

    $ligne = trim($ligne);
    if ($ligne === '') {
        continue;
    }

    $champs = explode(',', $ligne);

    // sécurité 
    if (count($champs) < 2) {
        continue;
    }

    $numDep = trim($champs[0]);
    $nomDep = trim($champs[1]);

    $tabDep[$nomDep] = $numDep;
    
}

$lignes = file($nomFichierCsv, FILE_IGNORE_NEW_LINES);
$donnees = [];

echo "${GREEN}INFO : Création tableau des sites touristiques ... $RESET\n\n";

$depParNumero = array_flip($tabDep);

function normaliserNumeroDep(string $num): string {
    if (strlen($num) === 1) {
        return '0' . $num;
    }
    return $num;
}


foreach ($lignes as $ligne) {

    $champs = explode(',', $ligne);

    if (count($champs) === 3) {

        $numeroDep = $numeroDep = normaliserNumeroDep(trim($champs[1]));

        $donnees[] = [
            'nom' => trim($champs[0]),
            'departement' => $numeroDep,
            'nom_departement' => $depParNumero[$numeroDep] ?? 'Inconnu',
            'nombre_visiteurs' => (int) trim($champs[2])
        ];
    }
}



$depsPresents = [];

foreach ($donnees as $ligne) {
    $depsPresents[] = $ligne['departement'];
}

foreach ($tabDep as $nomDep => $numDep) {

    if (!in_array($numDep, $depsPresents)) { # si numDep n'es pas dans le tableau depsPresents
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

    $parts = explode('=', $ligne); # divise la lignes en 2 nom regions et les numéros
    $region = trim($parts[0]);

    $depsBruts = explode(',', $parts[1]); # "divise" les numéros
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
// fonction trouver sur la doc php, le sort casse les clés donc par sécurité j'utilise usort
usort($donnees, function ($a, $b) {
    return $a['departement'] <=> $b['departement'];
});


echo "${GREEN}INFO : Creation des HTML ...$RESET\n";
echo "${CYAN} |- sites-dept.html $RESET\n";
$TITRE = "Sites de visites par département";

// Inspiré d'un poste sur stackoverflow.com 
//https://stackoverflow.com/questions/4401949/whats-the-use-of-ob-start
//https://www.php.net/manual/en/function.require.php +- même chose que include()

// On récupere le STDOUT du script php pour l'écrire dans un fichier html 
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
$TITRE = "Sites de visites par nombres visiteurs";
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
