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
            # Récupérer fichier sans dossier
            nomFichier="$(basename "$chemin")"
            # Récupérer fichier avec extension csv
            nomFichierCsv="${nomFichier%.xlsx}.csv"
            docker container cp scripts/csv_convert.php excel2csv:"/data/csv_convert.php"
            docker container cp "$chemin" excel2csv:"/app/$nomFichier"
            docker container exec -it excel2csv ssconvert "$nomFichier" "$nomFichierCsv"
            
            # traitement (suppression du titre et en-tete)
            echo "Traitement de $nomFichierCsv"
            echo "Suppresion du titre de $nomFichierCsv"
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
            echo "done"
            
            #docker cp excel2csv:"/app/$nomFichierCsv" utilisables/"$nomFichierCsv"
            echo "Traitement terminé : $nomFichierCsv"

            docker container exec -it excel2csv php /data/csv_convert.php "$nomFichier"
            #docker container exec excel2csv bash -c "ls"

        fi
    done 
    docker container stop excel2csv
    docker container rm excel2csv
fi

    
