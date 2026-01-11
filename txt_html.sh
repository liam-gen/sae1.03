#!/usr/bin/bash

ROUGE="\033[31m"
RESET="\033[0m"
CYAN="\033[36m"

REQUIRED_PATHS=(
  "input/presentation_musee_louvre"
)


for path in "${REQUIRED_PATHS[@]}"; do
  if [ ! -e "$path" ]; then
    echo -e "${ROUGE}ERREUR : le fichier ou répertoire '$path' est manquant. $RESET"
    exit 1
  fi
done

echo -e "${CYAN}Tous les fichiers et répertoires requis sont présents. $RESET"

FICHIER_IN="input/presentation_musee_louvre"

touch output/presentation_musee_louvre

FICHIER_OUT="utilisables/presentation_musee_louvre.html"

# Création HTML

SECTION_OPEN=False
ARTICLE_OPEN=False
P_OPEN=False

# Base

echo "<!doctype html>" > $FICHIER_OUT
echo '<html lang="fr">' >> $FICHIER_OUT

echo "<head>" >> $FICHIER_OUT
echo '<meta charset="utf-8">' >> $FICHIER_OUT
echo "<title>$FICHIER_IN</title>" >> $FICHIER_OUT
echo "</head>" > $FICHIER_OUT

echo "<body>" >> $FICHIER_OUT
echo "<main>" >> $FICHIER_OUT

# Body

for i in (wc -l < FICHIER_IN);
do
    if [[]]
done