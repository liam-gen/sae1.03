#!/bin/bash
# copyright Flavien Devallan - 2026

echo "$(date) - Lancement script txt_html.sh" >> LOGS.log

# Couleurs

ROUGE="\033[31m"
RESET="\033[0m"
CYAN="\033[36m"
GREEN="\033[32m"

# Répertoires

if [ "$CALLED_FROM_SCRIPT1" != "true" ]; then
    echo -e "${ROUGE}ERREUR : Ce script ne peut être exécuté que depuis script.sh. $RESET" >&2
    exit 1
fi

DIR_IN="input"
DIR_OUT="utilisables"
DIR_LOG="LOGS.log"


# Détection fichiers à traiter

for FICHIER_IN in "$DIR_IN"/*; 
do

    echo "$(date) - Validation de $FICHIER_IN" >> $DIR_LOG # Logs traitement du fichier

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
    NB_P=0



    # Présence fichiers

    REQUIRED_PATHS=("$FICHIER_IN")

    for path in "${REQUIRED_PATHS[@]}"; do
    if [ ! -e "$path" ]; then
        echo -e "${ROUGE}ERREUR : '$path' manquant. $RESET"
        exit 1
    fi
    done


    # Variables

    NB_SECTION=0
    NB_ARTICLE=0

    # Debug

    echo -e "${GREEN}INFO : Traitement de $FICHIER_IN ... $RESET"

    echo "$(date) - Traitement de $FICHIER_IN" >> $DIR_LOG # Logs traitement du fichier

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

    # Body

    while read -r LIGNE || [ -n "$LIGNE" ]; 
    do

        balise=$(echo "$LIGNE" | cut -d'=' -f1)
        contenu=$(echo "$LIGNE" | cut -d'=' -f2-)

    
        if [ "$balise" == "TITLE" ]; then
            # echo "H1"

            # echo "$(date) - TXT -> HTML : H1" >> $DIR_LOG # Logs H1
            
            echo "      <h1> $contenu </h1>" >> "$FICHIER_OUT"


        elif [ "$balise" == "SECT" ]; then
            # echo "SECTION + H2"

            # echo "$(date) - TXT -> HTML : Section + H2" >> $DIR_LOG # Logs Section + H2
            
            
            if [ "$NB_ARTICLE" -ne 0 ]; then
                echo "          </article>" >> "$FICHIER_OUT"
                NB_ARTICLE=0
            fi
            if [ "$NB_SECTION" -ne 0 ]; then
                echo "      </section>" >> "$FICHIER_OUT"
            fi

            
            echo "      <section>" >> "$FICHIER_OUT"
            echo "          <h2> $contenu </h2>" >> "$FICHIER_OUT"
            ((NB_SECTION++))


        elif [ "$balise" == "SUB_SECT" ]; then
            # echo "ARTICLE + H3"

            # echo "$(date) - TXT -> HTML : Article + H3" >> $DIR_LOG # Logs Article + H3

            
            if [ "$NB_ARTICLE" -ne 0 ]; then
                echo "          </article>" >> "$FICHIER_OUT"
            fi

            echo "          <article>" >> "$FICHIER_OUT"
            echo "              <h3> $contenu </h3>" >> "$FICHIER_OUT"
            ((NB_ARTICLE++))


        elif [ "$balise" == "TEXT" ]; then
            # echo "P"

            # echo "$(date) - TXT -> HTML : P" >> $DIR_LOG # P
            
            echo "              <p> $contenu </p>" >> "$FICHIER_OUT"
            ((NB_P++))

        fi 
        
    done < "$FICHIER_IN"

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

# Debug fin

echo -e "${GREEN}INFO : Fin traitement fichiers textes $RESET"

echo "$(date) - Fin script txt_html.sh" >> LOGS.log