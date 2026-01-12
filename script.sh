#!/bin/bash
# copyrights Titouan Moquet & Liam Charpentier - 2026
RED="\033[31m"
RESET="\033[0m"
CYAN="\033[36m"
GREEN="\033[32m"
YELLOW="\033[38;5;220m"
ORANGE="\033[38;5;208m"

clear
LOGSFILE='LOGS.log'
rm $LOGSFILE > /dev/null 2>&1
touch $LOGSFILE
# Vérification si l'utilisateur est à l'IUT ou pas.
IUT=false

if [[ -z "$1" ]] # chaine nul
then
    echo -e "${RED}Aucun argument, ou argument non valide, arguments disponibles : $RESET" 
    echo -e  "${RED} -i : pour utiliser le programme à l'IUT. $RESET"
    echo -e  "${RED} -h : pour utiliser le programme chez vous. $RESET"
    exit 1

elif [[ "$1" == "-h" ]]
then
    echo "$(date) - Execution en dehors de l'iut" >> $LOGSFILE

elif [[ "$1" == "-i" ]]
then
    $IUT=true
    echo "$(date) - Execution dans l'iut" >> $LOGSFILE
else
    echo -e "${RED}Aucun argument, ou argument non valide, arguments disponibles  : $RESET" 
    echo -e  "${RED} -i : pour utiliser le programme à l'IUT. $RESET"
    echo -e  "${RED} -h : pour utiliser le programme chez vous. $RESET"
    exit 1
fi

echo "$(date) - Lancement du script principal" >> $LOGSFILE
echo "$(date) - Verification des fichiers et dossiers" >> $LOGSFILE

# change les droits d'execution si ils n'ont pas ces droits
if [ ! -x "csv_convert.sh" ]; then
    chmod +x csv_convert.sh
elif [ ! -x "images.sh" ]; then
    chmod +x images.sh
elif [ ! -x "txt_html.sh" ]; then
    chmod +x txt_html.sh
elif [ ! -x "html_pdf.sh" ]; then
    chmod +x html_pdf.sh
fi

# Vérifiaction des dossiers obligatoires 
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



# Création du dossier utilisables & output si ils n'existent pas 
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

# different nom images en fonction de si IUT ou non 
if [ "$IUT" == true ]
then
  IMAGES=(
    "sae103-imagick"
    "sae103-excel2csv"
    "sae103-html2pdf"
  )

  for IMAGE in "${IMAGES[@]}"; do
    if docker image inspect "$IMAGE" > /dev/null 2>&1; then
      echo -e "${CYAN}NOTE : Image déjà présente : $IMAGE $RESET"
    else
      echo -e "${ORANGE}WARN : Image absente, téléchargement : $IMAGE $RESET"
      docker image pull "$IMAGE"
    fi
  done

  IMAGE_EXCEL2CSV="sae103-excel2csv"
  IMAGE_HTML2PDF="sae103-html2pdf"
  IMAGE_IMAGICK="sae103-imagick"
  

elif [ "$IUT" == false ]
then
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

  IMAGE_EXCEL2CSV="bigpapoo/sae103-excel2csv"
  IMAGE_HTML2PDF="bigpapoo/sae103-html2pdf"
  IMAGE_IMAGICK="bigpapoo/sae103-imagick"
fi

# variable pour empêcher le lancement des autres scripts s'ils ne sont pas lancés depuis celui-ci
export CALLED_FROM_SCRIPT1="true"

# fin verfication et init des éléments nécessaires 

echo "$(date) - Fin de la vérification" >> $LOGSFILE

echo -e "${CYAN}NOTE : Tous les fichiers et répertoires requis sont présents. $RESET"
echo -e  "${YELLOW}NOTE : Le programme peut prendre du temps à s'exécuter !$RESET"
sleep 2



# Fichier excel
echo ""
echo -e "${YELLOW}NOTE : Traitement EXCEL $RESET"
echo "$(date) - Traitement EXEL" >> $LOGSFILE
./csv_convert.sh $IMAGE_EXCEL2CSV 
sleep 1
  
# Images
echo "" 
echo -e "${YELLOW}NOTE : Traitement IMAGES $RESET"
echo "$(date) - Traitement IMAGES" >> $LOGSFILE
echo "" 
./images.sh $IMAGE_IMAGICK 
sleep 1

# Fichier textes
echo -e "${YELLOW}NOTE : Traitement TEXTES $RESET"
echo "$(date) - Traitement TEXTES" >> $LOGSFILE
echo "" 
./txt_html.sh 



echo -e "${YELLOW}NOTE : Traitement HTML to PDF $RESET"
echo "$(date) - Traitement PDF" >> $LOGSFILE
echo "" 
./html_pdf.sh $IMAGE_HTML2PDF


# nettoyage 
rm utilisables/* >/dev/null 2>&1

#fin 
echo ""
echo -e "${YELLOW}Fin du programme, Vos fichier sont disponibles dans le dossier : 'output/' $RESET"
echo "$(date) - Fin du programme principal" >> $LOGSFILE
