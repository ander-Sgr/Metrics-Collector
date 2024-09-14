#!/bin/bash

APP_DIR="/home/vagrant/services/metrics"
VENV_DIR="$APP_DIR/.venv"
USER="metric_service"
SOURCE_FILE_DAEMON="/etc/systemd/system/metrics.service"

is_installed () {
    dpkg -l | grep -q "$1"
}

install_packages () {
    echo "[INFO] =============== Installing Packages =============== "
    sudo apt-get update -y

    packages=("python3-pip" "python3-dev" "build-essential" "libssl-dev" \\
        "libffi-dev" "python3-setuptools" "python3-venv")

    for package in "${packages[@]}"; do
        if ! is_installed "$package"; then
            sudo apt -y install "$package"
        fi
    done
    echo "[INFO] Packages installed"
}

create_virtual_env () {
    echo "[INFO] Checking if a virtualenv exists..."

    if [ ! -d "$VENV_DIR" ]; then
        echo "[INFO] Creating virtual env"
        python3 -m venv "$VENV_DIR"
    fi
    echo "[INFO] Activating virtualenv"
    source "$VENV_DIR/bin/activate"
}


install_app_dependencies () {
    if [[ ! -d "$APP_DIR" ]]; then
        echo "[ERROR] Check project dir, not found"
        exit 1
    else
        if ! pip show flask &> /dev/null && ! pip show gunicorn &> /dev/null; then
            echo "[INFO] Installing dependencies"
            pip install wheel flask gunicorn psutil   
        fi
    fi
}

#create a user for execute the daemon flask with gunicorn
create_user() {
    if getent passwd "$USER" > /dev/null 2>&1; then
        echo "[INFO] User $USER already exists"
    else
        echo "[INFO] Creating user"
        if sudo adduser --system --no-create-home --group "$USER"; then
            echo "[INFO] User $USER created successfully"
        else
            echo "[ERROR] Failed to create user $USER" >&2
            exit 1
        fi
    fi

    # Set permissions after user creation and after files are copied
    echo "[INFO] Setting permissions for $APP_DIR"
    
    # Ensure the APP_DIR exists before setting permissions
    if [ ! -d "$APP_DIR" ]; then
        echo "[ERROR] Directory $APP_DIR does not exist. Exiting."
        exit 1
    fi

    # Apply permissions
    if sudo chown -R "$USER":"$USER" "$APP_DIR" && sudo chmod -R 755 "$APP_DIR"; then
        echo "[INFO] Permissions set successfully on $APP_DIR"
    else
        echo "[ERROR] Failed to set permissions on $APP_DIR" >&2
        exit 1
    fi
}

create_deamon () {
    if [[ ! -f "$SOURCE_FILE_DAEMON" ]]; then
        sudo bash -c "cat > /etc/systemd/system/metrics.service <<EOF
        [Unit]
        Description=Gunicorn instnace to serve Flask app
        After=network.target

        [Service]
        User=${USER}
        Group=${USER}
        WorkingDirectory=${APP_DIR}
        ExecStart=${APP_DIR}/.venv/bin/gunicorn --workers 3 --bind 0.0.0.0:8000 metric_app:app

        [Install]
        WantedBy=multi-user.target

EOF"
    sudo systemctl daemon-reload
    fi
}

check_state_daemon () {
    #check if service is enabled
    echo "[INFO] Enabling metric service"
    if ! sudo systemctl is-enabled metrics &> /dev/null; then
        echo "[INFO] Enabling  metric service"
        sudo systemctl enable metrics
    fi

    if ! sudo systemctl is-active metrics &> /dev/null;  then
        echo "[INFO] Activating  metrics service"
        sudo systemctl start metrics
    fi

}

setup_app() {
    install_packages
    create_virtual_env
    install_app_dependencies
    create_user
    create_deamon
    check_state_daemon
    echo "[INFO] =============== App Metrics Installation Completed Successfully ==============="
}

setup_app