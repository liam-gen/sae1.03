#!/usr/bin/bash

# Récupérer tous les excel

nbFichierExcel=$(ls fichiers/*.xlsx | wc -l)
if [ "$nbFichierExcel" -gt 0 ]
then
    # Lancer container docker

    docker run -dit --name excel2csv bigpapoo/sae103-excel2csv bash

    for chemin in fichiers/*.xlsx
    do
        
        if [ -f "$chemin" ]
        then
            # Récupérer fichier 
            nomFichier="$(basename "$chemin")"
            # Récupérer fichier avec extension csv
            nomFichierCsv="${nomFichier%.xlsx}.csv"
            docker container cp scripts/csv_convert.php excel2csv:"/app/csv_convert.php"
            docker container cp "$chemin" excel2csv:"/app/$nomFichier"
            docker container cp fichiers/DEPTS excel2csv:"/app/DEPTS"
            docker container cp fichiers/REGIONS excel2csv:"/app/REGIONS"
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
            sort -n -t',' -k 2 $nomFichierCsv > temp.csv
            mv temp.csv $nomFichierCsv"

            echo "Ok"

            echo "Lancement script php ..."
            docker container exec -it excel2csv php /app/csv_convert.php "$nomFichier" DEPTS
            echo "Traitement terminé : $nomFichierCsv"
        fi
    done 
    docker container stop excel2csv
    docker container rm excel2csv
fi

    
