#!/usr/bin/bash

# Vérification 

ROUGE="\033[31m"
RESET="\033[0m"
CYAN="\033[36m"

if [ "$nbFichierExcel" -eq 0 ]; then
  echo -e "${CYAN}INFO : aucun fichier Excel (.xlsx) trouvé dans le dossier input/ $RESET"
  exit 1
fi

REQUIRED_PATHS=(
  "scripts/csv_convert.php"
  "scripts/template-sites-dept.php"
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
if [ "$nbFichierExcel" -gt 0 ]
then
    # Lancer container docker

    docker run -dit --rm --name excel2csv bigpapoo/sae103-excel2csv bash

    for chemin in input/*.xlsx
    do
        
        if [ -f "$chemin" ]
        then
            # Récupérer fichier 
            nomFichier="$(basename "$chemin")"

            echo "Traitement de $nomFichier"

            # Récupérer fichier avec extension csv
            nomFichierCsv="${nomFichier%.xlsx}.csv"  # % "supprime de .xlsx"

            docker container cp scripts/csv_convert.php excel2csv:"/app/"
            docker container cp scripts/template-sites-dept.php excel2csv:"/app/"

            docker container cp "$chemin" excel2csv:"/app/"
            docker container cp input/DEPTS excel2csv:"/app/"
            docker container cp input/REGIONS excel2csv:"/app/"
            docker container cp input/Logo-OFT-horizontal.jpg excel2csv:"/app/"
           # docker container exec excel2csv bash -c "touch template-sites-dept.html template-sites-visites.html"
            docker container exec -it excel2csv ssconvert "$nomFichier" "$nomFichierCsv"
            
            # traitement (suppression du titre et en-tete)
            echo "Traitement de $nomFichierCsv ..."
            echo " "
            echo "Suppresion du titre de $nomFichierCsv ..."
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
            echo "Ok"
            
            # tri par numero de département 
            echo "Tri des données ..."

            docker container exec excel2csv bash -c "
            sort -n -r -t',' -k 2 $nomFichierCsv > temp.csv
            mv temp.csv $nomFichierCsv"

            echo "Ok"

            echo "Lancement script php ..."
            
            docker container exec -it excel2csv php /app/csv_convert.php "$nomFichierCsv" DEPTS

            docker cp excel2csv:"/app/template-sites-dept.html" utilisables/
            docker cp excel2csv:"/app/template-sites-visites.html" utilisables/
            #for fichier in $(docker exec excel2csv bash -c "ls /app/*.html"); do
              #  docker cp excel2csv:"$fichier" utilisables/
            #done

            echo "Traitement terminé : $nomFichierCsv"
            echo "Traitement terminé : $nomFichier"
        fi
    done 
    docker container stop excel2csv

fi

echo "Création des PDF ..."

nbFichierHTML=$(ls utilisables/*.html 2>/dev/null | wc -l)
if [ "$nbFichierHTML" -gt 0 ]
then
  
    
    for pathFichierHTML in utilisables/*.html
    do  
        docker run -dit --rm --name html2pdf_ bigpapoo/sae103-html2pdf bash
        fichierHTML="$(basename "$pathFichierHTML")"
        nomFichierPDF="${fichierHTML%.html}.pdf" # % "supprime de .html"
    
        if [ -f "$pathFichierHTML" ]
        then
            docker cp utilisables/$fichierHTML html2pdf_:"/work/"
            docker cp input/Logo-OFT-horizontal.jpg html2pdf_:"/work/"
            docker container exec -it html2pdf_ weasyprint "$fichierHTML" "$nomFichierPDF"
            docker cp html2pdf_:"/work/$nomFichierPDF" output/
            docker container stop html2pdf_
        fi

        # rename des fichiers 

        if [ "output/$nomFichierPDF" == "output/template-sites-dept.pdf" ]
        then
            mv output/template-sites-dept.pdf output/sites-dept.pdf
        fi

        if [ "output/$nomFichierPDF" == "output/template-sites-visites.pdf" ]
        then
            mv output/template-sites-visites.pdf output/sites-visites.pdf
        fi
    done 
fi 



