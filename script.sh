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
./images.sh

#rm utilisables/*
echo "Fin du programme"
