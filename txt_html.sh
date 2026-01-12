#!/bin/bash
# copyrights Flavien Devallan - 2026
LOGSFILE='LOGS.log'

echo "$(date) - Lancement script txt_html.sh" >> $LOGSFILE
# Couleurs

ROUGE="\033[31m"
RESET="\033[0m"
CYAN="\033[36m"
GREEN="\033[32m"

# Sécurité : seul script.sh peut exécuter le script
if [ "$CALLED_FROM_SCRIPT1" != "true" ]; then
    echo -e "${ROUGE}ERREUR : Ce script ne peut être exécuté que depuis script.sh. $RESET" >&2
    exit 1
fi

# récupération des nom des images docker via les arguments 
IMAGE_HTML2PDF=$1

# Répertoires
DIR_IN="input"
DIR_OUT="utilisables"
DIR_LOG="LOGS.log"


# Détection fichiers à traiter

for FICHIER_IN in "$DIR_IN"/*; 
do

    echo "$(date) - Validation de $FICHIER_IN" >> $DIR_LOG 

    # Conditions de validités
    
    if [ ! -f "$FICHIER_IN" ]; 
    then 
        continue;
    fi
    
    read -r PREMIERE_LIGNE < "$FICHIER_IN"

    if [[ "$PREMIERE_LIGNE" != *"="* ]]; 
    then 
        continue; 
    fi

    CLE=$(echo "$PREMIERE_LIGNE" | cut -d'=' -f1)

    if [[ "$CLE" != "TITLE" && "$CLE" != "SECT" && "$CLE" != "SUB_SECT" && "$CLE" != "TEXT" ]]; 
    then
        continue
    fi

    NOM_FICHIER=$(basename "$FICHIER_IN")
    FICHIER_OUT="${DIR_OUT}/${NOM_FICHIER}.html"

    # Variables compteur HTML

    NB_SECTION=0
    NB_ARTICLE=0

    # Présence fichiers

    REQUIRED_PATHS=("$FICHIER_IN")

    for path in "${REQUIRED_PATHS[@]}"; do
        if [ ! -e "$path" ]; then
            echo -e "${ROUGE}ERREUR : '$path' manquant. $RESET"
            exit 1
        fi
    done

    # Debug

    echo -e "${GREEN}INFO : Traitement de $FICHIER_IN ... $RESET"
    echo "$(date) - Traitement de $FICHIER_IN" >> $DIR_LOG 

    # Base HTML
    {
        echo "<!doctype html>"
        echo '<html lang="fr">'
        echo ""
        echo "<head>"
        echo '  <meta charset="utf-8">'
        echo "  <title>$NOM_FICHIER</title>"
        echo "</head>"
        echo ""
        echo "<body>"
        echo "  <main>"
        echo ""
    } > "$FICHIER_OUT" 
    
    # Sauvegarde du séparateur actuel

    SAVEIFS=$IFS

    # Définition du séparateur par un saut de ligne

    IFS=$'\n'

    for LIGNE in $(cat "$FICHIER_IN"); 
    do

        balise=$(echo "$LIGNE" | cut -d'=' -f1)
        contenu=$(echo "$LIGNE" | cut -d'=' -f2-)
    
        if [ "$balise" == "TITLE" ]; 
        then
            echo "      <h1> $contenu </h1>" >> "$FICHIER_OUT"

        elif [ "$balise" == "SECT" ]; 
        then
            
            if [ "$NB_ARTICLE" -ne 0 ]; 
            then
                echo "          </article>" >> "$FICHIER_OUT"
                NB_ARTICLE=0
            fi

            if [ "$NB_SECTION" -ne 0 ]; 
            then
                echo "      </section>" >> "$FICHIER_OUT"
            fi
            
            echo "      <section>" >> "$FICHIER_OUT"
            echo "          <h2> $contenu </h2>" >> "$FICHIER_OUT"

            ((NB_SECTION++))

        elif [ "$balise" == "SUB_SECT" ]; 
        then
            
            if [ "$NB_ARTICLE" -ne 0 ]; 
            then
                echo "          </article>" >> "$FICHIER_OUT"
            fi

            echo "          <article>" >> "$FICHIER_OUT"
            echo "              <h3> $contenu </h3>" >> "$FICHIER_OUT"

            ((NB_ARTICLE++))

        elif [ "$balise" == "TEXT" ]; 
        then
            
            echo "              <p> $contenu </p>" >> "$FICHIER_OUT"
            ((NB_P++))

        fi 
        
    done 

    # Restauration du séparateur de base

    IFS=$SAVEIFS


    # Dernière Ligne

    if [ "$NB_ARTICLE" -ne 0 ]; then
        echo "          </article>" >> "$FICHIER_OUT"
    fi

    if [ "$NB_SECTION" -ne 0 ]; then
        echo "      </section>" >> "$FICHIER_OUT"
    fi

    # Fin HTML

    echo "" >> "$FICHIER_OUT"
    echo "  </main>" >> "$FICHIER_OUT"
    echo "</body>" >> "$FICHIER_OUT"
    echo "</html>" >> "$FICHIER_OUT"

done

# voir done / install docker

nbFichierHTML=$(ls utilisables/*.html 2>/dev/null| wc -l)
if [ "$nbFichierHTML" -eq 0 ]; then
  echo -e "${CYAN}INFO : aucun fichier HTML (.html) trouvé dans le dossier input/ $RESET"
  exit 0
fi


if [ "$nbFichierHTML" -gt 0 ]
then
    docker run -dit --rm --name html2pdf_ bigpapoo/sae103-html2pdf bash >/dev/null
    echo "$(date) - Lancement de bigpapoo/sae103-html2pdf" >> $LOGSFILE

    docker cp input/Logo-OFT-horizontal.jpg html2pdf_:"/work/" >/dev/null
    echo "$(date) - Logo-OFT-horizontal.jpg copié vers /work/" >> $LOGSFILE

    for pathFichierHTML in utilisables/*.html
    do  
        
        fichierHTML="$(basename "$pathFichierHTML")"
        nomFichierPDF="${fichierHTML%.html}.pdf" # % "supprime de .html"
    
        if [ -f "$pathFichierHTML" ]
        then
            echo -e "${CYAN} |- $nomFichierPDF $RESET"
            docker cp utilisables/$fichierHTML html2pdf_:"/work/" >/dev/null
            echo "$(date) - $fichierHTML copié vers /work/" >> $LOGSFILE

            

            docker container exec -it html2pdf_ weasyprint "$fichierHTML" "$nomFichierPDF"
            echo "$(date) - exec weasyprint" >> $LOGSFILE

            docker cp html2pdf_:"/work/$nomFichierPDF" output/ >/dev/null
            echo "$(date) - $nomFichierPDF copié vers output/" >> $LOGSFILE

            
        fi

        : '

        # rename des fichiers 
        echo -e "${GREEN}INFO : Renommage du fichiers $nomFichierPDF $RESET"
        if [ "output/$nomFichierPDF" == "output/template-sites-dept.pdf" ]
        then
            mv output/template-sites-dept.pdf output/sites-dept.pdf
            echo "$(date) - rename template-sites-dept.pdf sites-dept.pdf" >> $LOGSFILE

        elif [ "output/$nomFichierPDF" == "output/template-sites-visites.pdf" ]
        then
            mv output/template-sites-visites.pdf output/sites-visites.pdf
            echo "$(date) - rename template-sites-visites.pdf sites-visites.pdf" >> $LOGSFILE

        elif [ "output/$nomFichierPDF" == "output/template-sites-regions.pdf" ]
        then
            mv output/template-sites-regions.pdf output/sites-regions.pdf
            echo "$(date) - rename template-sites-regions.pdff sites-regions.pdf" >> $LOGSFILE

        fi
        '
        
        
    done 
    docker container stop html2pdf_ >/dev/null
    echo "$(date) - Arrêt html2pdf" >> $LOGSFILE
    
fi 

# Debug fin

echo -e "${GREEN}INFO : Fin traitement fichiers textes $RESET"
echo "$(date) - Fin script txt_html.sh" >> $LOGSFILE