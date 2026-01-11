#!/usr/bin/bash

# Vérification 

ROUGE="\033[31m"
RESET="\033[0m"
CYAN="\033[36m"
VERT="\033[32m"

if [ "$CALLED_FROM_SCRIPT1" != "true" ]; then
    echo -e "${ROUGE}ERREUR : Ce script ne peut être exécuté que depuis script.sh. $RESET" >&2
    exit 1
fi

nbFichierImg=$(ls input/*.png input/*.jpeg input/*.jpg input/*.webp 2>/dev/null | wc -l)

if [ "$nbFichierImg" -eq 0 ]; then
  echo -e "${CYAN}INFO : aucun fichier image (png, jpeg, jpg, webp) trouvé dans le dossier input/ $RESET\n"
  exit 1
fi

# Images

if [ "$nbFichierImg" -gt 0 ]
then
    # Lancer container docker
    echo -e "${VERT}INFO : Traitement des images ...$RESET \n"

    docker run -dit --name imagick bigpapoo/sae103-imagick > /dev/null

    docker container cp scripts/conversionImage.php imagick:"/data/conversionImage.php" > /dev/null

    for chemin in input/*.png input/*.jpeg input/*.jpg input/*.webp
    do
        if [ -f "$chemin" ]
        then
            # Récupérer fichier sans dossier
            nomFichier="$(basename "$chemin")"
            # Récupérer fichier avec extension webp
            nomFichierWebp="${nomFichier%.*}.webp"

            echo "Traitement de $nomFichierWebp..."
            
            docker container cp "$chemin" imagick:"/data/$nomFichier" > /dev/null
            docker container exec -it imagick php /data/conversionImage.php "$nomFichier"
            docker container cp imagick:"/data/$nomFichierWebp" output/"$nomFichierWebp" > /dev/null

            echo -e "${VERT}Fichier $nomFichierWebp traité $RESET"
        fi
    done

    

    docker container stop imagick > /dev/null
    docker container rm imagick > /dev/null

    echo -e "\n${VERT}INFO : Fin du traitement des images${RESET}\n"
fi