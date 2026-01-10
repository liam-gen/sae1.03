#!/usr/bin/bash

# Vérification
nbFichierExcel=$(ls input/*.xlsx 2>/dev/null | wc -l) #n'affiche pas d'erreur si il n'y a pas de fichier

ROUGE="\033[31m"
RESET="\033[0m"
CYAN="\033[36m"

if [ "$nbFichierExcel" -eq 0 ]; then
  echo -e "${CYAN}INFO : aucun fichier Excel (.xlsx) trouvé dans le dossier input/ $RESET"
  exit 1
fi

REQUIRED_PATHS=(
  "scripts/csv_convert.php"
  "scripts/template-sites-visites.php"
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

if [ "$nbFichierExcel" -gt 0 ]
then
    # Lancer container docker

    docker run -dit --name excel2csv bigpapoo/sae103-excel2csv bash

    for chemin in input/*.xlsx
    do
        
        if [ -f "$chemin" ]
        then
            # Récupérer fichier 
            nomFichier="$(basename "$chemin")"

            echo "Traitement de $nomFichier"

            # Récupérer fichier avec extension csv
            nomFichierCsv="${nomFichier%.xlsx}.csv"  # % "supprime de .html"

            docker container cp scripts/csv_convert.php excel2csv:"/app/csv_convert.php"
            docker container cp scripts/template-sites-visites.php excel2csv:"/app/template-sites-visites.php"

            docker container cp "$chemin" excel2csv:"/app/$nomFichier"
            docker container cp input/DEPTS excel2csv:"/app/DEPTS"
            docker container cp input/REGIONS excel2csv:"/app/REGIONS"
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
            docker container exec -it excel2csv php /app/csv_convert.php "$nomFichier" DEPTS

            docker cp excel2csv:"/app/template-sites-visites.html" utilisables/
            echo "Traitement terminé : $nomFichierCsv"
            echo "Traitement terminé : $nomFichier"
        fi
    done 
    docker container stop excel2csv
    docker container rm excel2csv
fi

echo "Création des PDF ..."

nbFichierHTML=$(ls utilisables/*.html | wc -l)
if [ "$nbFichierHTML" -gt 0 ]
then

    docker run -dit --rm --name html2pdf_ bigpapoo/sae103-html2pdf bash
    
    for pathFichierHTML in utilisables/*.html
    do
    fichierHTML="$(basename "$pathFichierHTML")"
    nomFichierPDF="${fichierHTML%.html}.pdf" # % "supprime de .html"
    
        if [ -f "$pathFichierHTML" ]
        then
            docker cp utilisables/$fichierHTML html2pdf_:"/work/"
            
            docker container exec -it html2pdf_ weasyprint "$fichierHTML" "$nomFichierPDF"
            docker container exec -it html2pdf_ bash -c "ls"
            docker cp html2pdf_:"/work/$nomFichierPDF" output/
        fi
    done 

    docker container stop html2pdf_
fi 



