<?php

$nomFichier = $argv[1];
$nomFichierCsv = pathinfo($nomFichier, PATHINFO_FILENAME) . '.csv';

$nomFichierDep = $argv[2];



$lignesDep = file($nomFichierDep);
$tabDep = [];

foreach ($lignesDep as $ligne){
    $tabDep[] = $ligne;
}

// Lit le fichier et retourne un tableau de lignes
$lignes = file($nomFichierCsv);

// Initialise un tableau pour stocker les données
$donnees = [];

// Parcourt chaque ligne du fichier
foreach ($lignes as $ligne) {
    // Supprime les espaces et les retours à la ligne
    $ligne = trim($ligne);
    // Sépare la ligne en utilisant la virgule comme délimiteur
    $champs = explode(',', $ligne);
    // Vérifie qu'il y a bien 3 champ
    
    if (count($champs) === 3) {
        $donnees[] = [
            'nom' => trim($champs[0], '"'), // Supprime les guillemets
            'nom_departement' => $tabDep[(trim($champs[1])+1)],
            'departement' => trim($champs[1]),
            'nombre_visiteurs' => trim($champs[2])
        ];
    }

}


print_r($tabDep);
#print_r($donnees);


?>
