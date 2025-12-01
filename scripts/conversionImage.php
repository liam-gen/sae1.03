
<?php
list($width, $height, $type, $attr) = getimagesize("image.jpg");
echo "Dimensions: $width x $height";

/*
- Fichier bash
    Récupérer dernière image imagick
    Lancer conteneur en éhpémère
    Copier tous (ou seulement les images ??) les fichiers dans ce conteneur
    Copier le script php
    Lancer le script php

- Script php images
    Pour toutes les images
        Récupérer dimensions image
        Si image trop grande et ratio faisable
            Redimensionner image
        
        Récupérer taille fichier
        Si fichier trop lourd
            Compresser fichier

        Récupérer type de fichier
        Si pas WebP
            Conversion vers WebP
        
        Copier fichier en dehors du conteneur
*/
?>