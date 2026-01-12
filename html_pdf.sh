#!/bin/bash
# copyrights Flavien Devallan - 2026
LOGSFILE='LOGS.log'

echo "$(date) - Lancement script html_pdf.sh" >> $LOGSFILE

# Couleurs

ROUGE="\033[31m"
RESET="\033[0m"
CYAN="\033[36m"
GREEN="\033[32m"
: '
# Sécurité : seul script.sh peut exécuter le script
if [ "$CALLED_FROM_SCRIPT1" != "true" ]; then
    echo -e "${ROUGE}ERREUR : Ce script ne peut être exécuté que depuis script.sh. $RESET" >&2
    exit 1
fi'

# Récupération des nom des images docker via les arguments 
IMAGE_HTML2PDF=$1

# Répertoires
DIR_IN="utilisables"
DIR_OUT="output"
DIR_LOG="LOGS.log"


# Récupération HTML

nbFichierHTML=$(ls $DIR_IN/*.html 2>/dev/null| wc -l)

if [ "$nbFichierHTML" -eq 0 ]; then
  echo -e "${CYAN}INFO : aucun fichier HTML (.html) trouvé dans le dossier $DIR_IN/ $RESET"
  exit 0
fi


# Traitement HTML to PDF

if [ "$nbFichierHTML" -gt 0 ]
then
    docker run -dit --rm --name html2pdf_ bigpapoo/sae103-html2pdf bash >/dev/null
    echo "$(date) - Lancement de bigpapoo/sae103-html2pdf" >> $LOGSFILE

    docker cp input/Logo-OFT-horizontal.jpg html2pdf_:"/work/" >/dev/null
    echo "$(date) - Logo-OFT-horizontal.jpg copié vers /work/" >> $LOGSFILE

    for pathFichierHTML in "$DIR_IN"/*.html
    do  
        
        fichierHTML="$(basename "$pathFichierHTML")"
        nomFichierPDF="${fichierHTML%.html}.pdf" # % "supprime de .html"
    
        if [ -f "$pathFichierHTML" ]
        then
            echo -e "${CYAN} \|- $nomFichierPDF $RESET"
            docker cp "$DIR_IN/$fichierHTML" html2pdf_:"/work/" >/dev/null
            echo "$(date) - $fichierHTML copié vers /work/" >> $LOGSFILE

            

            docker container exec -it html2pdf_ weasyprint "$fichierHTML" "$nomFichierPDF"
            echo "$(date) - exec weasyprint" >> $LOGSFILE

            docker cp html2pdf_:"/work/$nomFichierPDF" "$DIR_OUT/" >/dev/null
            echo "$(date) - $nomFichierPDF copié vers $DIR_OUT/" >> $LOGSFILE

            
        fi
        
        
    done 

    docker container stop html2pdf_ >/dev/null
    echo "$(date) - Arrêt html2pdf" >> $LOGSFILE
    
fi 

# Suppression fichiers

echo -e "${GREEN}INFO : Supression des HTML dans $DIR_IN $RESET"
echo "$(date) - Supression des HTML dans $DIR_IN" >> $LOGSFILE

rm $DIR_IN/*.html


# Debug fin

echo -e "${GREEN}INFO : Fin traitement fichiers textes $RESET"
echo "$(date) - Fin script html_pdf.sh" >> $LOGSFILE

