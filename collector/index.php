<?php

require_once("Connection.php");
require_once("Collector.php");

$endpoints = [
    'http://10.0.0.50:8000/metrics',
    'http://10.0.0.51:8000/metrics'
];

// Crea una instancia de la conexión a la base de datos
$pdo = Connection::instance();

// Crea una instancia del recolector
$collector = new Collector($pdo);

$collector->insertMetrics($endpoints);

echo "[INFO] Datos insertados correctamente.\n";

