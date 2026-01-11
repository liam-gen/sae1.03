#!/usr/bin/bash
# Copyright Titouan Moquet - 2026 


# Vérification 

ROUGE="\033[31m"
RESET="\033[0m"
CYAN="\033[36m"
GREEN="\033[32m"

echo ""
echo -e "${GREEN}INFO : Traitement fichier xlsx $RESET"
echo ""

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

if [ "$nbFichierExcel" -gt 0 ]
then
    # Lancer container docker

    docker run -dit --rm --name excel2csv bigpapoo/sae103-excel2csv bash >/dev/null

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

            docker container cp scripts/csv_convert.php excel2csv:"/app/" >/dev/null
            docker container cp scripts/template-sites-dept.php excel2csv:"/app/" >/dev/null
            docker container cp scripts/template-sites-regions.php excel2csv:"/app/" >/dev/null
            docker container cp "$chemin" excel2csv:"/app/" >/dev/null
            docker container cp input/DEPTS excel2csv:"/app/" >/dev/null
            docker container cp input/REGIONS excel2csv:"/app/" >/dev/null
            docker container cp input/Logo-OFT-horizontal.jpg excel2csv:"/app/" >/dev/null
            # docker container exec excel2csv bash -c "touch template-sites-dept.html template-sites-visites.html"
            docker container exec -it excel2csv ssconvert "$nomFichier" "$nomFichierCsv"
            
            # traitement (suppression du titre et en-tete)
            echo -e "${GREEN}INFO : Traitement de $nomFichierCsv ...$RESET"
            echo ""

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

            
            # tri par numero de département 
            echo -e "${GREEN}INFO : Tri des données ...$RESET"
            echo ""

            docker container exec excel2csv bash -c "
            sort -n -r -t',' -k 2 $nomFichierCsv > temp.csv
            mv temp.csv $nomFichierCsv"



            echo -e "${GREEN}INFO : Lancement script php ...$RESET"
            echo ""

            docker container exec -it excel2csv php /app/csv_convert.php "$nomFichierCsv" DEPTS REGIONS

            docker cp excel2csv:"/app/template-sites-dept.html" utilisables/ >/dev/null
            docker cp excel2csv:"/app/template-sites-visites.html" utilisables/ >/dev/null
            docker cp excel2csv:"/app/template-sites-regions.html" utilisables/ >/dev/null
   
            echo ""
            echo -e "${GREEN}INFO : Traitement terminé : $nomFichier $RESET"


        fi
    done 
    docker container stop excel2csv >/dev/null
    echo ""
fi



echo -e "${GREEN}INFO : Création des PDF ... $RESET"
echo ""

REQUIRED_PATHS2=(
  "input/Logo-OFT-horizontal.jpg"
)

for path in "${REQUIRED_PATHS2[@]}"; do
  if [ ! -e "$path" ]; then
    echo -e "${ROUGE}ERREUR : le fichier ou répertoire '$path' est manquant, les pdf n'auront pas de logo $RESET"
    echo -e "${ROUGE}Le script va continuer dans quelques secondes $RESET"
    sleep 4
  fi
done


nbFichierHTML=$(ls utilisables/*.html 2>/dev/null | wc -l)
if [ "$nbFichierHTML" -eq 0 ]; then
  echo -e "${CYAN}INFO : aucun fichier HTML (.html) trouvé dans le dossier input/ $RESET"
  exit 0
fi

if [ "$nbFichierHTML" -gt 0 ]
then
  
    for pathFichierHTML in utilisables/*.html
    do  
        docker run -dit --rm --name html2pdf_ bigpapoo/sae103-html2pdf bash >/dev/null
        fichierHTML="$(basename "$pathFichierHTML")"
        nomFichierPDF="${fichierHTML%.html}.pdf" # % "supprime de .html"
    
        if [ -f "$pathFichierHTML" ]
        then
            echo -e "${CYAN} |- $nomFichierPDF $RESET"
            docker cp utilisables/$fichierHTML html2pdf_:"/work/" >/dev/null
            docker cp input/Logo-OFT-horizontal.jpg html2pdf_:"/work/" >/dev/null
            docker container exec -it html2pdf_ weasyprint "$fichierHTML" "$nomFichierPDF"
            docker cp html2pdf_:"/work/$nomFichierPDF" output/ >/dev/null
            docker container stop html2pdf_ >/dev/null
        fi

        # rename des fichiers 
        echo -e "${GREEN}INFO : Renommage du fichiers $nomFichierPDF $RESET"
        if [ "output/$nomFichierPDF" == "output/template-sites-dept.pdf" ]
        then
            mv output/template-sites-dept.pdf output/sites-dept.pdf

        elif [ "output/$nomFichierPDF" == "output/template-sites-visites.pdf" ]
        then
            mv output/template-sites-visites.pdf output/sites-visites.pdf

        elif [ "output/$nomFichierPDF" == "output/template-sites-regions.pdf" ]
        then
            mv output/template-sites-regions.pdf output/sites-regions.pdf

        fi
        echo ""
    done 
fi 
echo -e "${GREEN}INFO : Fin traitement fichier xlsx $RESET"

 
