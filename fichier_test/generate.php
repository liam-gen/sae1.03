#!/usr/bin/php
<?php

// 1) Données PHP (comme si elles venaient d’un CSV)
$departements = [
    'Ain' => '01',
    'Corse-du-Sud' => '2A',
    'Haute-Corse' => '2B'
];

// 2) On inclut le fichier HTML/PHP de rendu
require 'template.php';

?>