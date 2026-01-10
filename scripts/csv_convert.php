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

    if (count($champs) === 3) {

        $numeroDep = normaliserNumeroDep(trim($champs[1]));

        $donnees[] = [
            'nom' => $champs[0],
            'departement' => $numeroDep,
            'nom_departement' => $depParNumero[$numeroDep] ?? 'Inconnu', // associe le nom du dep avec son numéro 
            'nombre_visiteurs' => (int) $champs[2]
        ];
    }
}
echo "Ok \n";

echo "Creation du HTML ...\n";


// Source - https://stackoverflow.com/q
// Posted by omg, modified by community. See post 'Timeline' for change history
// Retrieved 2026-01-10, License - CC BY-SA 2.5
$file = 'template-sites-visites.html';
ob_start();
require 'template-sites-visites.php'; 
$contents = ob_get_contents();
ob_end_clean();
file_put_contents($file,$contents);
//
echo "Ok\n";
//echo "\nTableau de département : \n";
//print_r($tabDep);
//echo "\nTableau des sites touristiques : \n ";
//print_r($donnees);


?>
