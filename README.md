# SPRINT 05 - LAB05

## #Requesitos 

- python >= 3
- pip >= 21.2.1

## Instalación

Levantamos nuestas mv's de vagrant

```bash
vagrant up
```

Tomará su tiempo en aprovisionarse.

Una vez completado el aprovisionamiento

Tendremos que cambiar permisos en las tablas 

Nos conectamos al servidor

```bash
vagrant ssh dbmetrics

# LUEGO DE CONECTARSE INGRESAMOS A LA DB
sudo -u postgres psql -d metrics
#agregamos los siguientes permisos
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE system_metrics TO metrics_user;
GRANT USAGE, SELECT ON SEQUENCE system_metrics_id_seq TO metrics_user;

#Hacemos consulta la tabla 

SELECT * FROM system_metrics;
```

Con esto ya nuestro cron job se encargará de ejecutar nuestra app
de recoleccion de metricas y hara persistencia a la bbbdd.
