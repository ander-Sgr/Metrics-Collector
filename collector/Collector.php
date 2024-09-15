<?php

class Collector
{
    private $conn;

    public function __construct(PDO $pdo)
    {
        $this->conn = $pdo;
    }

    public function recallMetrics($endpoints)
    {
        $results = array();
        foreach ($endpoints as $node)
        {
            $ch = curl_init();
            curl_setopt($ch, CURLOPT_URL, $node);
            curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
            $response = curl_exec($ch);
            curl_close($ch);
            $results[] = json_decode($response, true);
        }

        return $results;
    }

    public function insertMetrics($endpoints)
    {
        $data = $this->recallMetrics($endpoints);
        $query = "INSERT INTO system_metrics (host_name, metric_name, metric_value, created_at) VALUES (:host_name, :metric_name, :metric_value, NOW())";
        $stmt = $this->conn->prepare($query);

        foreach ($data as $item)
        {
            if (isset($item['system_hostname'])) {
                // Insertar métricas directamente en la tabla system_metrics
                $metrics = [
                    'cpu_usage_percent' => $item['cpu_usage_percent'],
                    'disk_free' => $item['disk_free'],
                    'disk_total' => $item['disk_total'],
                    'disk_used' => $item['disk_used'],
                    'disk_used_percent' => $item['disk_used_percent'],
                    'memory_available' => $item['memory_available'],
                    'memory_total' => $item['memory_total'],
                    'memory_used' => $item['memory_used'],
                    'memory_used_percent' => $item['memory_used_percent'],
                    'system_uptime_seconds' => $item['system_uptime_seconds']
                ];

                foreach ($metrics as $metricName => $metricValue) {
                    $stmt->bindParam(':host_name', $item['system_hostname']);
                    $stmt->bindParam(':metric_name', $metricName);
                    $stmt->bindParam(':metric_value', $metricValue);
                    $stmt->execute();
                }
            }
        }
    }
}
