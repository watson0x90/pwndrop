#!/bin/bash

set -e

FILENAME=pwndrop-linux-amd64

# declare pwndrop.ini file content
create_pwndrop_ini() {
    local_ip=$(hostname -I | awk '{print $1}')
    cat <<EOF > pwndrop.ini
[pwndrop]
listen_ip = "$local_ip"                     # the external IP of your pwndrop instance (must be set if you want to use the nameserver feature)
http_port = 80                              # listening port for HTTP and WebDAV
https_port = 443                            # listening port for HTTPS
data_dir = "./data"                         # directory path where data storage will reside (relative paths are from executable directory path)
admin_dir = "./admin"                       # directory path where the admin panel files reside (relative paths are from executable directory path)

[setup]                                     # optional: put in if you want to pre-configure pwndrop (section will be deleted from the config file on first run)
username = "admin"                          # username of the admin account
password = "secretpassword"                 # password of the admin account
redirect_url = "https://www.google.com"     # URL to which visitors will be redirected to if they supply a path, which doesn't point to any shared file (put blank if you want to return 404)
secret_path = "/pwndrop"                    # secret path to access the admin panel (must start with a slash)
EOF
}

# Function to check for necessary commands
check_requirements() {
    for cmd in wget tar; do
        if ! command -v $cmd &> /dev/null; then
            echo "[pwndrop] Error: $cmd is required but it's not installed. Aborting."
            exit 1
        fi
    done
}

# Function to download pwndrop
download_pwndrop() {
    echo "[pwndrop] Downloading pwndrop."
    if wget "https://github.com/kgretzky/pwndrop/releases/latest/download/${FILENAME}.tar.gz"; then
        echo "Download successful."
    else
        echo "Download failed."
        exit 1
    fi
}

# Function to unpack pwndrop
unpack_pwndrop() {
    echo "[pwndrop] Unpacking."
    tar zxvf "${FILENAME}.tar.gz"
    cd pwndrop || exit
    chmod 700 pwndrop
}

# Function to ask user for installation type
ask_user() {
    while true; do
        read -p "Do you want to install pwndrop? (y/n): " response
        case "$response" in
            [yY][eE][sS]|[yY])
                install_pwndrop
                break
                ;;
            [nN][oO]|[nN])
                run_pwndrop_local
                break
                ;;
            *)
                echo "Please answer yes or no."
                ;;
        esac
    done
}

install_pwndrop() {
    echo "[pwndrop] Installing with public domain..."
    # Installation commands here
    echo "[pwndrop] stopping pwndrop."
    ./pwndrop stop
    echo "[pwndrop] installing."
    ./pwndrop install
    ./pwndrop start
    ./pwndrop status
    echo "[pwndrop] cleaning up."
    cd ../..
    rm -rf ${FILENAME}/
}

# Placeholder for install_pwndrop_local function
run_pwndrop_local() {
    echo "[pwndrop] Running for local use only..."
    create_pwndrop_ini
    ./pwndrop -no-autocert -no-dns -config pwndrop.ini
}

# Main script execution
check_requirements
download_pwndrop
unpack_pwndrop

# Check for script arguments and run the appropriate function
if [ "$1" == "--install" ]; then
    install_pwndrop
elif [ "$1" == "--local" ]; then
    run_pwndrop_local
else
    ask_user
fi

echo "[pwndrop] Installation complete."
exit 0
