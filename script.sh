#!/usr/bin/bash

# Charger les images (pas nécessaire rendu final)

clear

# sécutité 

IMAGES=(
  "bigpapoo/sae103-imagick"
  "bigpapoo/sae103-excel2csv"
  "bigpapoo/sae103-html2pdf"
)

for IMAGE in "${IMAGES[@]}"; do
  if docker image inspect "$IMAGE" > /dev/null 2>&1; then
    echo "Image déjà présente : $IMAGE"
  else
    echo "Image absente, téléchargement : $IMAGE"
    docker image pull "$IMAGE"
  fi
done

repInput="input"
repSript="scripts"
if [ ! -d "$repInput" ]
then
    echo "Erreur le dossier '$repInput' n'existe pas !"
    exit 1 
fi

if [ ! -d "$repSript" ]
then
    echo "Erreur le dossier '$repScript' n'existe pas !"
    exit 1 
fi



# création du dossier utilisables si il n'existe pas 
repTemp="utilisables"

if [ -d "$repTemp" ]
then
    rm utilisables/* 2>/dev/null
fi
if [ ! -d "$repTemp" ]
then
    echo "Création du dossier : $repTemp"
    mkdir $repTemp
    echo "OK"
fi

repOutput="output"
if [ -d "$repOutput" ]
then 
    rm output/* 2>/dev/null
fi
if [ ! -d "$repOutput" ]
then
    echo "Création du dossier : $repOutput"
    mkdir $repOutput
    echo "OK"
fi


# Fichier excel
./csv_convert.sh

# Images
nbFichierImg=$(ls input/*.png input/*.jpeg input/*.jpg input/*.webp | wc -l)
if [ "$nbFichierImg" -gt 0 ]
then
    # Lancer container docker
    echo "Traitement des images ..."

    docker run -dit --name imagick bigpapoo/sae103-imagick

    docker container cp scripts/conversionImage.php imagick:"/data/conversionImage.php"

    for chemin in input/*.png input/*.jpeg input/*.jpg input/*.webp
    do
        if [ -f "$chemin" ]
        then
            # Récupérer fichier sans dossier
            nomFichier="$(basename "$chemin")"
            # Récupérer fichier avec extension webp
            nomFichierWebp="${nomFichier%.*}.webp"
            
            docker container cp "$chemin" imagick:"/data/$nomFichier"
            docker container exec -it imagick php /data/conversionImage.php "$nomFichier"
            docker container cp imagick:"/data/$nomFichierWebp" output/"$nomFichierWebp"
        fi
    done

    

    docker container stop imagick
    docker container rm imagick

    echo "Ok"
fi

#rm utilisables/*
echo "Fin du programme"
