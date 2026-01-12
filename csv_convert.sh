#!/bin/bash
# Copyrights Titouan Moquet - 2026 
LOGSFILE='LOGS.log'
echo "$(date) - Lancement script csv_convert.sh" >> $LOGSFILE

ROUGE="\033[31m"
RESET="\033[0m"
CYAN="\033[36m"
GREEN="\033[32m"

# récupération des nom des images docker via les arguments 
IMAGE_EXCEL2CSV=$1



# Sécurité : seul script.sh peut exécuter le script
if [ "$CALLED_FROM_SCRIPT1" != "true" ]; then
    echo -e "${ROUGE}ERREUR : Ce script ne peut être exécuté que depuis script.sh. $RESET" >&2
    exit 1
fi

echo ""
echo -e "${GREEN}INFO : Traitement fichier xlsx $RESET"
echo ""

# Vérification des fichiers 
REQUIRED_PATHS=(
  "scripts/csv_convert.php"
  "scripts/template-sites-dept.php"
  "scripts/template-sites-regions.php"
  "input/DEPTS"
  "input/REGIONS"
)

for path in "${REQUIRED_PATHS[@]}"; do
  if [ ! -e "$path" ]; then
    echo -e "${ROUGE}ERREUR : le fichier ou répertoire '$path' est manquant. $RESET"
    exit 1
  fi
done

echo -e "${CYAN}Tous les fichiers et répertoires requis sont présents. $RESET" 

# Programme
nbFichierExcel=$(ls input/*.xlsx 2>/dev/null | wc -l) #n'affiche pas d'erreur si il n'y a pas de fichier
if [ "$nbFichierExcel" -eq 0 ]; then
  echo -e "${CYAN}INFO : aucun fichier Excel (.xlsx) trouvé dans le dossier input/ $RESET"
  exit 0
fi
# si nombre de fichier superieur à 0
if [ "$nbFichierExcel" -gt 0 ]
then
  # Lancer container docker

  docker run -dit --rm --name excel2csv $IMAGE_EXCEL2CSV bash >/dev/null
  echo "$(date) - Lancement $IMAGE_EXCEL2CSV" >> $LOGSFILE # redirection de messages pour avoir des logs
  for chemin in input/*.xlsx
  do
      
    if [ -f "$chemin" ]
    then
      # Récupérer fichier 
      nomFichier="$(basename "$chemin")"
      echo ""
      echo -e "${GREEN}INFO : Traitement de $nomFichier $RESET"
      echo ""
      # Récupérer fichier avec extension csv
      nomFichierCsv="${nomFichier%.xlsx}.csv"  # % "supprime de .xlsx"

      # ajout des num département dans DEPS

      boucle=1
      tr ' ' '-' < input/DEPTS >input/tempfile
      mv input/tempfile utilisables/DEPTS
      rm utilisables/DEPTS_NUM >/dev/null 2>&1
      for ligne in $(cat "utilisables/DEPTS"); # récupéré du script de Flavien
      do 
        if [ "$ligne" == "Corse-du-Sud" ]; then
          echo "2A,$ligne" >> utilisables/DEPTS_NUM
        elif [ "$ligne" == "Haute-Corse" ]; then 
          echo "2B,$ligne" >> utilisables/DEPTS_NUM
          boucle=21 
        else
          if [ "$boucle" -lt 10 ]; then
              echo "0$boucle,$ligne" >> utilisables/DEPTS_NUM
          else
              echo "$boucle,$ligne" >> utilisables/DEPTS_NUM
          fi
          ((boucle++))
        fi

      done

      # echo redirigé vers le fichier logs

      docker container cp scripts/csv_convert.php excel2csv:"/app/" >/dev/null
      echo "$(date) - csv_convert.php copié vers /app/" >> $LOGSFILE

      docker container cp scripts/template-sites-dept.php excel2csv:"/app/" >/dev/null
      echo "$(date) - template-sites-dept.php copié vers /app/" >> $LOGSFILE

      docker container cp scripts/template-sites-regions.php excel2csv:"/app/" >/dev/null
      echo "$(date) - template-sites-regions.php copié vers /app/" >> $LOGSFILE

      docker container cp "$chemin" excel2csv:"/app/" >/dev/null
      echo "$(date) - "$chemin" copié vers /app/" >> $LOGSFILE

      docker container cp utilisables/DEPTS_NUM excel2csv:"/app/DEPTS" >/dev/null
      echo "$(date) - DEPTS_NUM copié vers /app/" >> $LOGSFILE

      docker container cp input/REGIONS excel2csv:"/app/" >/dev/null
      echo "$(date) - REGIONS copié vers /app/" >> $LOGSFILE

      docker container cp input/Logo-OFT-horizontal.jpg excel2csv:"/app/" >/dev/null
      echo "$(date) - Logo-OFT-horizontal.jpg copié vers /app/" >> $LOGSFILE
      
      echo "$(date) - EXEC ssconvert in excel2csv " >> $LOGSFILE
      docker container exec -it excel2csv ssconvert "$nomFichier" "$nomFichierCsv" >/dev/null
      
      # traitement (suppression du titre et en-tete)
      echo -e "${GREEN}INFO : Traitement de $nomFichierCsv ...$RESET"
      echo ""

      # si le fichier ne correspond pas au motif, on saute
      if [[ "input/$nomFichier" != input/sites_touristiques_france*.xlsx ]]; then
        docker cp excel2csv:"/app/$nomFichierCsv" output/ >/dev/null
        echo "$(date) - $nomFichierCsv copié vers output/" >> $LOGSFILE
        continue  # passe au prochain fichier
      fi

      echo "$(date) - suppression du titre et en-tete " >> $LOGSFILE
      
      docker container exec excel2csv bash -c "
          if [ -f \"/app/$nomFichierCsv\" ]
          then
              premiere_ligne=\$(head -n 1 \"/app/$nomFichierCsv\")  
        
              if ! echo "$premiere_ligne" | grep -q '*,,'
              then

                  tail -n +4 /app/$nomFichierCsv > /app/tmp.csv
                  mv /app/tmp.csv /app/$nomFichierCsv
              fi
          fi
      "

      # Tri (inversé) par numero de département 
      echo -e "${GREEN}INFO : Tri des données ...$RESET"
      echo ""
      echo "$(date) - tri des données du fichier csv " >> $LOGSFILE

      docker container exec excel2csv bash -c "
      sort -n -r -t',' -k 2 $nomFichierCsv > temp.csv
      mv temp.csv $nomFichierCsv"
      

      # Lancement script php

      echo -e "${GREEN}INFO : Lancement script php ...$RESET"
      echo ""

      echo "$(date) - EXEC sv_convert.php script in excel2csv" >> $LOGSFILE
      docker container exec -it excel2csv php /app/csv_convert.php "$nomFichierCsv" DEPTS REGIONS
     
      #Fin du php & copie des fichiers vers utilisables pour etre convertie en pdf

      docker cp excel2csv:"/app/template-sites-dept.html" utilisables/ >/dev/null
      echo "$(date) - template-sites-dept.html copié vers utilisables/" >> $LOGSFILE
      docker cp excel2csv:"/app/template-sites-visites.html" utilisables/ >/dev/null
      echo "$(date) - template-sites-visites.html copié vers utilisables/" >> $LOGSFILE
      docker cp excel2csv:"/app/template-sites-regions.html" utilisables/ >/dev/null
      echo "$(date) - template-sites-regions.html copié vers utilisables/" >> $LOGSFILE

      echo ""
      echo -e "${GREEN}INFO : Traitement terminé : $nomFichier $RESET"
    fi
  done 
  docker container stop excel2csv >/dev/null
  echo "$(date) - Arrêt excel2csv" >> $LOGSFILE
  echo ""
fi

echo -e "${GREEN}INFO : Fin traitement fichier xlsx $RESET"
echo "$(date) - Fin du script csv_convert.sh" >> $LOGSFILE
 
