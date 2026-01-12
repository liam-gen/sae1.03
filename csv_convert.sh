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

      # echo redirigé vers le fichier logs

      docker container cp scripts/csv_convert.php excel2csv:"/app/" >/dev/null
      echo "$(date) - csv_convert.php copié vers /app/" >> $LOGSFILE

      docker container cp scripts/template-sites-dept.php excel2csv:"/app/" >/dev/null
      echo "$(date) - template-sites-dept.php copié vers /app/" >> $LOGSFILE

      docker container cp scripts/template-sites-regions.php excel2csv:"/app/" >/dev/null
      echo "$(date) - template-sites-regions.php copié vers /app/" >> $LOGSFILE

      docker container cp "$chemin" excel2csv:"/app/" >/dev/null
      echo "$(date) - "$chemin" copié vers /app/" >> $LOGSFILE

      docker container cp input/DEPTS excel2csv:"/app/" >/dev/null
      echo "$(date) - DEPTS copié vers /app/" >> $LOGSFILE

      docker container cp input/REGIONS excel2csv:"/app/" >/dev/null
      echo "$(date) - REGIONS copié vers /app/" >> $LOGSFILE

      docker container cp input/Logo-OFT-horizontal.jpg excel2csv:"/app/" >/dev/null
      echo "$(date) - Logo-OFT-horizontal.jpg copié vers /app/" >> $LOGSFILE
      
      echo "$(date) - EXEC ssconvert in excel2csv " >> $LOGSFILE
      docker container exec -it excel2csv ssconvert "$nomFichier" "$nomFichierCsv" >/dev/null
      
      # traitement (suppression du titre et en-tete)
      echo -e "${GREEN}INFO : Traitement de $nomFichierCsv ...$RESET"
      echo ""

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
      # docker container exec excel2csv bash -c "cat $nomFichierCsv" 

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


# converssion PDF
# echo -e "${GREEN}INFO : Création des PDF ... $RESET"
# echo ""

# REQUIRED_PATHS2=(
#   "input/Logo-OFT-horizontal.jpg"
# )

# for path in "${REQUIRED_PATHS2[@]}"; do
#   if [ ! -e "$path" ]; then
#     echo -e "${ROUGE}ERREUR : le fichier ou répertoire '$path' est manquant, les pdf n'auront pas de logo $RESET"
#     echo -e "${ROUGE}Le script va continuer dans quelques secondes $RESET"
#     sleep 4
#   fi
# done


# nbFichierHTML=$(ls utilisables/*.html 2>/dev/null| wc -l)
# if [ "$nbFichierHTML" -eq 0 ]; then
#   echo -e "${CYAN}INFO : aucun fichier HTML (.html) trouvé dans le dossier input/ $RESET"
#   exit 0
# fi

# if [ "$nbFichierHTML" -gt 0 ]
# then
#     docker run -dit --rm --name html2pdf_ $IMAGE_HTML2PDF bash >/dev/null
#     echo "$(date) - Lancement de bigpapoo/sae103-html2pdf" >> $LOGSFILE

#     docker cp input/Logo-OFT-horizontal.jpg html2pdf_:"/work/" >/dev/null
#     echo "$(date) - Logo-OFT-horizontal.jpg copié vers /work/" >> $LOGSFILE

#     for pathFichierHTML in utilisables/*.html
#     do  
        
#         fichierHTML="$(basename "$pathFichierHTML")"
#         nomFichierPDF="${fichierHTML%.html}.pdf" # % "supprime de .html"
    
#         if [ -f "$pathFichierHTML" ]
#         then
#             echo -e "${CYAN} |- $nomFichierPDF $RESET"
#             docker cp utilisables/$fichierHTML html2pdf_:"/work/" >/dev/null
#             echo "$(date) - $fichierHTML copié vers /work/" >> $LOGSFILE

            

#             docker container exec -it html2pdf_ weasyprint "$fichierHTML" "$nomFichierPDF"
#             echo "$(date) - exec weasyprint" >> $LOGSFILE

#             docker cp html2pdf_:"/work/$nomFichierPDF" output/ >/dev/null
#             echo "$(date) - $nomFichierPDF copié vers output/" >> $LOGSFILE

            
#         fi

#         # rename des fichiers 
#         echo -e "${GREEN}INFO : Renommage du fichiers $nomFichierPDF $RESET"
#         if [ "output/$nomFichierPDF" == "output/template-sites-dept.pdf" ]
#         then
#             mv output/template-sites-dept.pdf output/sites-dept.pdf
#             echo "$(date) - rename template-sites-dept.pdf sites-dept.pdf" >> $LOGSFILE

#         elif [ "output/$nomFichierPDF" == "output/template-sites-visites.pdf" ]
#         then
#             mv output/template-sites-visites.pdf output/sites-visites.pdf
#             echo "$(date) - rename template-sites-visites.pdf sites-visites.pdf" >> $LOGSFILE

#         elif [ "output/$nomFichierPDF" == "output/template-sites-regions.pdf" ]
#         then
#             mv output/template-sites-regions.pdf output/sites-regions.pdf
#             echo "$(date) - rename template-sites-regions.pdff sites-regions.pdf" >> $LOGSFILE

#         fi
#         echo ""
#     done 
#     docker container stop html2pdf_ >/dev/null
#     echo "$(date) - Arrêt html2pdf" >> $LOGSFILE
    
#fi 
echo -e "${GREEN}INFO : Fin traitement fichier xlsx $RESET"
echo "$(date) - Fin du script csv_convert.sh" >> $LOGSFILE
 
