<?php
const MAX_TAILLE = 180000; // 18 ko

const MIN_LARGEUR = 350;
const MIN_HAUTEUR = 250;

const MAX_LARGEUR = 900;
const MAX_HAUTEUR = 620;

const TYPE_WEBP = 18;

$nomFichier = $argv[1];
$nomFichierWebp = pathinfo($nomFichier, PATHINFO_FILENAME) . '.webp';

// Récupérer les dimensions
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

    while (filesize($nomFichierWebp) > MAX_TAILLE && $qualite > 50) {
        exec("convert ".escapeshellarg($nomFichierWebp)." -quality $qualite ".escapeshellarg($nomFichierWebp));
        echo "Qualité: $qualite% ";
        $qualite -= 5;
    }
    
}

echo "Dimensions: $width x $height\n";
echo "Taille: " . filesize($nomFichier)." puis ". filesize($nomFichierWebp) ."\n";
echo "Type: " . $type."\n\n";