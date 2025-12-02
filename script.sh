#!/usr/bin/bash

# Charger les images (pas nécessaire rendu final)

docker image pull bigpapoo/sae103-imagick
docker image pull bigpapoo/sae103-excel2csv
docker image pull bigpapoo/sae103-html2pdf

# Récupérer tous les excel

nbFichierExcel=$(ls fichiers/*.xlsx | wc -l)
if [ "$nbFichierExcel" -gt 0 ]
then
    # Lancer container docker

    docker run -dit --name excel2csv bigpapoo/sae103-excel2csv bash

    for chemin in fichiers/*.xlsx
    do
        
        if [ -f "$chemin" ]
        then
            # Récupérer fichier sans dossier
            nomFichier="$(basename "$chemin")"
            # Récupérer fichier avec extension csv
            nomFichierCsv="${nomFichier%.xlsx}.csv"

            docker container cp "$chemin" excel2csv:"/app/$nomFichier"
            docker container exec -it excel2csv ssconvert "$nomFichier" "$nomFichierCsv"
            docker container cp excel2csv:"/app/$nomFichierCsv" utilisables/"$nomFichierCsv"
        fi
    done

    docker container stop excel2csv
    docker container rm excel2csv
fi

nbFichierImg=$(ls fichiers/*.png fichiers/*.jpeg fichiers/*.jpg fichiers/*.webp | wc -l)
if [ "$nbFichierImg" -gt 0 ]
then
    # Lancer container docker

    docker run -dit --name imagick bigpapoo/sae103-imagick

    docker container cp scripts/conversionImage.php imagick:"/data/conversionImage.php"

    for chemin in fichiers/*.png fichiers/*.jpeg fichiers/*.jpg fichiers/*.webp
    do
        if [ -f "$chemin" ]
        then
            # Récupérer fichier sans dossier
            nomFichier="$(basename "$chemin")"
            # Récupérer fichier avec extension webp
            nomFichierWebp="${nomFichier%.*}.webp"
            
            docker container cp "$chemin" imagick:"/data/$nomFichier"
            docker container exec -it imagick php /data/conversionImage.php "$nomFichier"
            docker container cp imagick:"/data/$nomFichierWebp" utilisables/"$nomFichierWebp"
        fi
    done

    

    docker container stop imagick
    docker container rm imagick
fi