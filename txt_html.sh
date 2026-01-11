#!/usr/bin/bash

# Couleurs

ROUGE="\033[31m"
RESET="\033[0m"
CYAN="\033[36m"
GREEN="\033[32m"

# a modifier (faire une détection)

FICHIER="presentation_musee_louvre"
FICHIER_IN="input/$FICHIER"
touch "output/$FICHIER"
FICHIER_OUT="utilisables/$FICHIER.html"




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

# Base HTML

{
    echo "<!doctype html>"
    echo '<html lang="fr">'
    echo ""
    echo "<head>"
    echo '  <meta charset="utf-8">'
    echo "  <title>$FICHIER</title>"
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
        echo "      <h1> $contenu </h1>" >> $FICHIER_OUT


    elif [ "$balise" == "SECT" ]; then
        # echo "SECTION + H2"
        
        
        if [ "$NB_ARTICLE" -ne 0 ]; then
             echo "          </article>" >> $FICHIER_OUT
             NB_ARTICLE=0
        fi
        if [ "$NB_SECTION" -ne 0 ]; then
             echo "      </section>" >> $FICHIER_OUT
        fi

        
        echo "      <section>" >> $FICHIER_OUT
        echo "          <h2> $contenu </h2>" >> $FICHIER_OUT
        ((NB_SECTION++))


    elif [ "$balise" == "SUB_SECT" ]; then
        # echo "ARTICLE + H3"

        
        if [ "$NB_ARTICLE" -ne 0 ]; then
            echo "          </article>" >> $FICHIER_OUT
        fi

        echo "          <article>" >> $FICHIER_OUT
        echo "              <h3> $contenu </h3>" >> $FICHIER_OUT
        ((NB_ARTICLE++))


    elif [ "$balise" == "TEXT" ]; then
        # echo "P"
        
        echo "              <p> $contenu </p>" >> $FICHIER_OUT
        ((NB_P++))

    fi 
    
done < "$FICHIER_IN"

# Dernière Ligne

if [ "$NB_ARTICLE" -ne 0 ]; then
    echo "          </article>" >> $FICHIER_OUT
fi

if [ "$NB_SECTION" -ne 0 ]; then
    echo "      </section>" >> $FICHIER_OUT
fi

# Fin HTML

echo "" >> $FICHIER_OUT
echo "  </main>" >> $FICHIER_OUT
echo "</body>" >> $FICHIER_OUT
echo "</html>" >> $FICHIER_OUT



# Debug fin

echo -e "${GREEN}INFO : Fin traitement fichiers textes $RESET"