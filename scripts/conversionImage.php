<?php
const MAX_TAILLE = 180000; // 18 ko

const MIN_LARGEUR = 350;
const MIN_HAUTEUR = 250;

const MAX_LARGEUR = 900;
const MAX_HAUTEUR = 620;

const TYPE_WEBP = 18;

$nomFichier = $argv[1];

// Récupérer les dimensions
list($width, $height, $type, $attr) = getimagesize($nomFichier);

if($width > MAX_LARGEUR || $height > MAX_HAUTEUR){
    // Commande pour redimensionner
    //exec("");
    
}

if(filesize($nomFichier) > MAX_TAILLE){
    // Commande pour optimiser taille
    //exec("");
    
}

if($type != TYPE_WEBP){
    // Commande pour changer format en webp
    //exec("");
    
}

echo "Dimensions: $width x $height\n";
echo "Taille: " . filesize($nomFichier)."\n";
echo "Type: " . $type."\n\n";