 #!/usr/bin/bash

ROUGE="\033[31m"
RESET="\033[0m"
CYAN="\033[36m"
GREEN="\033[32m"

if [ "$CALLED_FROM_SCRIPT1" != "true" ]; then
    echo -e "${ROUGE}ERREUR : Ce script ne peut être exécuté que depuis script.sh. $RESET" >&2
    exit 1
fi

REQUIRED_PATHS=("input/presentation_musee_louvre")

for path in "${REQUIRED_PATHS[@]}"; do
  if [ ! -e "$path" ]; then
    echo -e "${ROUGE}ERREUR : '$path' manquant. $RESET"
    exit 1
  fi
done

FICHIER_IN="input/presentation_musee_louvre"
touch output/presentation_musee_louvre
FICHIER_OUT="utilisables/presentation_musee_louvre.html"


# Variables

NB_SECTION=0
NB_ARTICLE=0
NB_P=0

# Base HTML

echo -e "${GREEN}INFO : Traitement de $FICHIER_IN ... $RESET"

echo "<!doctype html>" > $FICHIER_OUT
echo '<html lang="fr">' >> $FICHIER_OUT

echo "<head>" >> $FICHIER_OUT
echo '  <meta charset="utf-8">' >> $FICHIER_OUT
echo "  <title>$FICHIER_IN</title>" >> $FICHIER_OUT
echo "</head>" >> $FICHIER_OUT

echo "<body>" >> $FICHIER_OUT
echo "  <main>" >> $FICHIER_OUT 

# Body

NB_LIGNES=$(wc -l < "$FICHIER_IN")

for i in $(seq 1 $NB_LIGNES); 
do
    
    LIGNE=$(sed -n "${i}p" "$FICHIER_IN")
    balise=$(echo "$LIGNE" | cut -d'=' -f1)
    contenu=$(echo "$LIGNE" | cut -d'=' -f2)

   
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
    


    # Dernière Ligne

    if [ "$i" -eq "$NB_LIGNES" ]; then
        # echo "DERNIERE LIGNE"
        
        
        if [ "$NB_ARTICLE" -ne 0 ]; then
            echo "          </article>" >> $FICHIER_OUT
        fi

        if [ "$NB_SECTION" -ne 0 ]; then
            echo "      </section>" >> $FICHIER_OUT
        fi

        # Fin HTML
        
        echo "  </main>" >> $FICHIER_OUT
        echo "</body>" >> $FICHIER_OUT
        echo "</html>" >> $FICHIER_OUT

    fi

done

echo -e "${GREEN}INFO : Fin traitement fichiers textes $RESET"