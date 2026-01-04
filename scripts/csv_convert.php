<?php

$nomFichier = $argv[1];
$nomFichierCsv = pathinfo($nomFichier, PATHINFO_FILENAME) . '.csv';

//$nomFichierDep = $argv[2];
//$lignesDep = file($nomFichierDep);
//$tabDep = [];

//foreach ($lignesDep as $ligne){
//    $tabDep[] = $ligne;
//}

$nomFichierDep = $argv[2];
$lignesDep = file($nomFichierDep);

$tabDep = [];
$numero = 1;

foreach ($lignesDep as $dep) {

    if (strcmp($dep,'Corse-du-Sud') === 0) {

        $tabDep[$dep] = '2A';

    } elseif (strcmp($dep,'Haute-Corse') === 0) {

        $tabDep[$dep] = '2B';
        $numero = 21; // on reprend la numérotation après la Corse

    } else {

        $tabDep[$dep] = str_pad($numero, 2, '0', STR_PAD_LEFT); // met un 0 avant si il n'y a que 2 chiffre
        $numero++;
    }
}


// // Lit le fichier et retourne un tableau de lignes
// $lignes = file($nomFichierCsv);

// // Initialise un tableau pour stocker les données
// $donnees = [];

// // Parcourt chaque ligne du fichier
// foreach ($lignes as $ligne) {
//     // Supprime les espaces et les retours à la ligne
//     $ligne = trim($ligne);
//     // Sépare la ligne en utilisant la virgule comme délimiteur
//     $champs = explode(',', $ligne);
//     // Vérifie qu'il y a bien 3 champ
    
//     if (count($champs) === 3) {
//         $donnees[] = [
//             'nom' => trim($champs[0], '"'), // Supprime les guillemets
//             'nom_departement' => $tabDep[(trim($champs[1]))],
//             'departement' => trim($champs[1]),
//             'nombre_visiteurs' => trim($champs[2])
//         ];
//     }

// }

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



print_r($tabDep);
//print_r($donnees);


?>
