<?php

// Copyright Liam Charpentier - 2026

const MAX_TAILLE = 180000; // 18 ko

const MIN_LARGEUR = 350;
const MIN_HAUTEUR = 250;

const MAX_LARGEUR = 900;
const MAX_HAUTEUR = 620;

const TYPE_WEBP = 18;

$nomFichier = $argv[1];
$nomFichierWebp = pathinfo($nomFichier, PATHINFO_FILENAME) . '.webp';

// récupérer les dimensions de l'image
list($width, $height, $type, $attr) = getimagesize($nomFichier);

if($width > MAX_LARGEUR || $height > MAX_HAUTEUR){
    // calculer dimensions avec ratio
    $ratio = min(MAX_LARGEUR / $width, MAX_HAUTEUR / $height);
    $largeur = floor($width * $ratio);
    $hauteur = floor($height * $ratio);
    
    // commande pour redimensionner le fichier
    exec("convert ".escapeshellarg($nomFichier)." -resize {$largeur}x{$hauteur} ".escapeshellarg($nomFichier));
    
    // ? mettre à jour pour affichage
    $width = $largeur;
    $height = $hauteur;
}

if($type != TYPE_WEBP){
    // Conversion en Webp
    exec("convert $nomFichier $nomFichierWebp"); 
}

if(filesize($nomFichierWebp) > MAX_TAILLE){

    // début à 90% de qualite
    $qualite = 90;

    // tant qu'on fait plus de 15ko par contre on dépasse pas 50% de qualité
    // ? si on a atteint 50% et que le fichier dépasse toujours ?
    while (filesize($nomFichierWebp) > MAX_TAILLE && $qualite > 50) {
        exec("convert ".escapeshellarg($nomFichierWebp)." -quality $qualite ".escapeshellarg($nomFichierWebp));
        $qualite -= 5;
    }
    
}

/*echo "Dimensions: $width x $height\n";
echo "Taille: " . filesize($nomFichier)." puis ". filesize($nomFichierWebp) ."\n";
echo "Type: " . $type."\n\n";*/