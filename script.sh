#!/bin/bash
# copyrights Titouan Moquet & Liam Charpentier - 2026

clear

rm LOGS.log > /dev/null 2>&1
touch LOGS.log

echo "$(date) - Lancement du script principal" >> LOGS.log

RED="\033[31m"
RESET="\033[0m"
CYAN="\033[36m"
GREEN="\033[32m"
YELLOW="\033[38;5;220m"
ORANGE="\033[38;5;208m"
echo "$(date) - Verification des fichiers et dossiers" >> LOGS.log
# sécutité 
if [ ! -x "csv_convert.sh" ]; then
    chmod +x csv_convert.sh
elif [ ! -x "images.sh" ]; then
    chmod +x images.sh
elif [ ! -x "txt_html.sh" ]; then
    chmod +x txt_html.sh
fi

repInput="input"
repSript="scripts"
if [ ! -d "$repInput" ]
then
    echo -e "${RED}Erreur le dossier '$repInput' n'existe pas ! $RESET"
    exit 1 
fi

if [ ! -d "$repSript" ]
then
    echo -e "${RED}Erreur le dossier '$repScript' n'existe pas ! $RESET"
    exit 1 
fi



# création du dossier utilisables si il n'existe pas 
repTemp="utilisables"

if [ -d "$repTemp" ]
then
    rm utilisables/* 2>/dev/null
elif [ ! -d "$repTemp" ]
then
    echo -e "${ORANGE}WARN : Le dossier $repTemp n'existe pas ! Création du dossier : $repTemp $RESET"
    mkdir $repTemp
fi

repOutput="output"
if [ -d "$repOutput" ]
then 
    rm output/* 2>/dev/null
elif [ ! -d "$repOutput" ]
then
    echo -e "${ORANGE}WARN : Le dossier $repOutput  n'existe pas ! Création du dossier : $repOutput $RESET"
    mkdir $repOutput
fi

echo -e "${CYAN}NOTE : Tous les fichiers et répertoires requis sont présents. $RESET"

IMAGES=(
  "bigpapoo/sae103-imagick"
  "bigpapoo/sae103-excel2csv"
  "bigpapoo/sae103-html2pdf"
)

for IMAGE in "${IMAGES[@]}"; do
  if docker image inspect "$IMAGE" > /dev/null 2>&1; then
    echo -e "${CYAN}NOTE : Image déjà présente : $IMAGE $RESET"
  else
    echo -e "${ORANGE}WARN : Image absente, téléchargement : $IMAGE $RESET"
    docker image pull "$IMAGE"
  fi
done

echo "$(date) - Fin de la vérification" >> LOGS.log

# variable pour empêcher le lancement des autres scripts s'ils ne sont pas lancés depuis celui-ci
export CALLED_FROM_SCRIPT1="true"

# Fichier excel
echo ""
echo -e "${YELLOW}NOTE : Traitement EXCEL $RESET"
echo "$(date) - Traitement EXEL" >> LOGS.log
./csv_convert.sh
sleep 1

# Images
echo "" 
echo -e "${YELLOW}NOTE : Traitement IMAGES $RESET"
echo "$(date) - Traitement IMAGES" >> LOGS.log
echo "" 
./images.sh
sleep 1

# Fichier textes
echo -e "${YELLOW}NOTE : Traitement TEXTES $RESET"
echo "$(date) - Traitement TEXTES" >> LOGS.log
echo "" 
./txt_html.sh

# nettoyage 
  # rm utilisables/*
#fin 
echo ""
echo -e "${YELLOW}Fin du programme, Vos fichier sont disponibles dans le dossier : 'output/' $RESET"
echo "$(date) - Fin du programme principal" >> LOGS.log
