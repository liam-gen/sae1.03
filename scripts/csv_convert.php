<?php
$nomFichier = $argv[1];
$nomFichierCsv = pathinfo($nomFichier, PATHINFO_FILENAME) . '.csv';


$handle = fopen($nomFichierCsv, "r");
$contents = fread($handle, filesize($nomFichierCsv));
fclose($handle);

echo $contents;