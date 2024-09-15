#!/bin/bash
# Configuration 
DB_NAME="metrics"
DB_HOSTS="hosts"
DB_USER="metrics_user"
SQL_FILE="/vagrant/scripts/metrics_table.sql"


# Function to check if a package is installed
is_installed() {
    dpkg -l | grep -qw "$1"
}

# Verify if the service postgresql is running
check_service_postgres() {
    if sudo systemctl is-active --quiet postgresql; then
        echo "[INFO] Postgres is running"
    else
        echo "[WARNING] Postgres is not running, try to start the service"
        sudo systemctl start postgresql
        if sudo systemctl is-active --quiet postgresql; then
            echo "[INFO] Postgres is running"
        else
            echo "Postgres is not running, please check the service"
            exit 1
        fi
    fi
}

#verify if the database exists
db_exists() {
    if sudo -u postgres psql -tAc "SELECT 1 FROM pg_database WHERE datname='$1'" | grep -q 1; then
        return 0
    else
        return 1
    fi
}

#verify if the user exists
user_exists() {
    sudo -u postgres psql -tAc "SELECT 1 FROM pg_roles WHERE rolname='$1'" | grep -q 1
}

#creating the database
create_db() {
    if db_exists "$DB_NAME"; then
        echo "[INFO] Database $DB_NAME already exists"
    else
        echo "[INFO] Creating database $DB_NAME"
        sudo -u postgres psql -c "CREATE DATABASE $DB_NAME"
        echo "[INFO] Database $DB_NAME created"
    fi
}

#creating the user
create_user() {
    if user_exists "$DB_USER"; then
        echo "[INFO] User $DB_USER already exists"
    else
        echo "[INFO] Creating user $DB_USER"
        sudo -u postgres psql -c "CREATE USER $DB_USER WITH PASSWORD '$DB_PASS';"
        echo "[INFO] User $DB_USER created"

        # Permisos sobre la base de datos
        sudo -u postgres psql -c "GRANT CONNECT ON DATABASE $DB_NAME TO $DB_USER;"

        sudo -u postgres psql -c "GRANT USAGE ON SCHEMA public TO $DB_USER;"

        sudo -u postgres psql -c "GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO $DB_USER;"

        sudo -u postgres psql -c "GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO $DB_USER;"

        sudo -u postgres psql -c "ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO $DB_USER;"
        sudo -u postgres psql -c "ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT USAGE, SELECT ON SEQUENCES TO $DB_USER;"
    fi
}


#creating the table on the db
create_table() {
    echo "[INFO] Creating table metrics"
    if [ -f "$SQL_FILE" ]; then
        sudo -u postgres psql -d $DB_NAME -f $SQL_FILE
        echo "[INFO] Table metrics created"
    else
            echo "[ERROR] SQL file $SQL_FILE not found."
            exit 1
        fi
    }
    
# Updating packages
# Installing packages
install_postgresql() {
    echo "[INFO] =============== Installing postgresql ==============="
    sudo apt-get update -y

    packages=("postgresql" "postgresql-contrib")
    for package in "${packages[@]}"; do
        if ! is_installed "$package"; then
            sudo apt -y install "$package"
        fi
    done
}

load_env() {
    if [ -f /vagrant/.env ]; then
        set -a
        source /vagrant/.env
        set +a
    else
        echo "[ERROR] .env file not found in the project root."
        exit 1
    fi

    if [ -z "$DB_PASS" ]; then
        echo "[ERROR] DB_PASS is not set. Please set it in the .env file."
        exit 1
    fi
}

postgres_setup() {
    install_postgresql
    load_env
    create_db
    create_user
    create_table
    echo "[INFO] =============== Postgres setup completed ==============="
}

postgres_setup