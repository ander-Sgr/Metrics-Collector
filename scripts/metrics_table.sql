CREATE TABLE hosts (
    id SERIAL PRIMARY KEY,
    host_name VARCHAR(255) UNIQUE NOT NULL
);

CREATE TABLE system_metrics (
    id SERIAL PRIMARY KEY,
    host_id INT REFERENCES hosts(id),
    metric_name VARCHAR(255) NOT NULL,
    metric_value FLOAT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (host_id, metric_name, created_at)
);