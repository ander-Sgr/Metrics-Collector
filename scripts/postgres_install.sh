#!/bin/bash
#Config 
DB_NAME="metrics"
DB_USER="metrics_user"
DB_PASS="metrics_pass"

echo "POSTGRES INSTALATION"

#updating pacakges
sudo apt-get update -y

#checking if package is installed	
packages=("postgresql", "postgresql-contrib")
for package in "${packages[@]}"; do
    if ! is_installed "$package"; then
        sudo apt -y install "$package"
    fi
done

db_exists() {
    if psql -tAc "SELECT 1 FROM pg_database WHERE datname='$1'" | grep -q 1; then
        return 0
    else
        return 1
    fi
}

user_exists() {
    psql -tAc "SELECT 1 FROM pg_roles WHERE rolname='$1'" | grep -q 1
}



