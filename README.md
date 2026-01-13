<img src="https://img.shields.io/github/contributors/liam-gen/sae1.03?style=for-the-badge">
<img src="https://img.shields.io/badge/LICENCE-MIT-0?style=for-the-badge">

# SAE 1.03 - Installation d'un poste pour le développement 

Ce projet a pour objectif d’automatiser le traitement des fichiers pour le site internet (fictif) du Ministère du Tourisme français. Notre but est de soulager la charge de travail de l'équipe de développeurs web en transformant de manière automatique le flux de fichiers dans les formats web demandés.

### Conditions
- Les tableurs exel doivent être transformé CSV
- Conversion de certains tableurs en PDF
- Conversion d'images qui doivent faire à la fin moins de 180 Ko, doivent être au format WebP et doivent respecter les dimensions minimum 350x250 et maximum 900x620
- Les fichiers textes doivent être transformés en PDF

## Technologies utilisées

<img src="https://skillicons.dev/icons?i=php,bash,docker,github,markdown,vscode">

## Installation

1. Clonez ce repository
   ```bash
   git clone https://github.com/liam-gen/sae1.05.git
   ```
2. Donnez les permissions d'executer le script
   ```bash
   chmod +x script.sh
   ```

## Exécution 
> [!WARNING]  
> **Le seul point d'entrée de ce programme est ./script.sh, ne lancez pas les autres scripts !**

Lancez le programme
Si vous n'êtes pas sur les pc de l'IUT de Lannion : 
```bash
./script.sh -h
```
Sinon si vous êtes sur les pc de l'IUT de Lannion :
```bash
./script.sh -i
```

> [!WARNING]  
> Les dossiers input/ et script/ sont obligatoires, de plus les scripts ont besoin de certains fichiers pour fonctionner
> **input/** : DEPT, REGION, Logo-OFT-horizontal.jpg    
> **scripts/** : conversionImage.php, csv_convert.php, template-sites-dept.php, template-sites-regions.php  
> **sae1.03/** : csv_convert.sh, images.sh, txt_html.sh, html_pdf.sh

> [!NOTE]
> Fonctionne uniquement sur Linux (et MacOS avec Bash installé)

## Informations

Projet sous licence MIT — libre d’utilisation, modification et redistribution.

## Crédits

<a href="https://github.com/github.com/liam-gen/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=github.com/liam-gen/" />
</a>
