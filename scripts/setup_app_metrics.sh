#!/bin/bash

APP_DIR="${HOME}/services/metrics"
VENV_DIR="$APP_DIR/.venv"

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





setup_app() {


    install_packages()
    create_virtual_env()
    echo "[INFO] =============== App metrics installation completed"
}

setup_app