#!/usr/bin/bash

# Charger les images (pas nécessaire rendu final)

docker image pull bigpapoo/sae103-imagick
docker image pull bigpapoo/sae103-excel2csv
docker image pull bigpapoo/sae103-html2pdf

# Récupérer tous les excel

nbFichierExcel=$(ls *.xlsx | wc -l)
if [ "$nbFichierExcel" -gt 0 ]
then
    # Lancer container docker

    docker run -dit --name excel2csv bigpapoo/sae103-excel2csv bash

    for fichier in *.xlsx
    do
        if [ -f "$fichier" ]
        then
            echo "$fichier"
        fi
    done
fi