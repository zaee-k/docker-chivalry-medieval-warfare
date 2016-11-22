#!/usr/bin/env bash

function install-steamcmd {
    echo "steamcmd not found. Installing..."
    mkdir -p "${INSTALL_DIR}/steamcmd"
    cd "${INSTALL_DIR}/steamcmd"
    curl -Ss http://media.steampowered.com/installer/steamcmd_linux.tar.gz | tar -xz
}

function install-chivalry {
    echo "No game files found. Installing..."
    "${INSTALL_DIR}/steamcmd/steamcmd.sh" +login anonymous +force_install_dir "${INSTALL_DIR}/server" +app_update 220070 +quit
    if [ ! -L "${INSTALL_DIR}/server/Binaries/Linux/lib/steamclient.so" ]; then
        ln -s "${INSTALL_DIR}/server/steamclient.so" "${INSTALL_DIR}/server/Binaries/Linux/lib/steamclient.so"
    fi

    if [ ! -f "${INSTALL_DIR}/server/Binaries/Linux/steam_appid.txt" ]; then
        echo "219640" > "${INSTALL_DIR}/server/Binaries/Linux/steam_appid.txt"
    fi
}

##################################### Main #####################################
# we check if steamcmd is installed
[ ! -f "${INSTALL_DIR}/steamcmd" ] && install-steamcmd

# we check if chivalry is installed or need an update
install-chivalry

[ ! -d "${INSTALL_DIR}/config" ] && mkdir -p "${INSTALL_DIR}/config"

cd "${INSTALL_DIR}/config"
[ ! -L PCServer-UDKGame.ini ] && ln -s ../server/UDKGame/Config/PCServer-UDKGame.ini PCServer-UDKGame.ini

export LD_LIBRARY_PATH=${INSTALL_DIR}/server/linux64:${INSTALL_DIR}/server/Binaries/Linux/lib
cd "${INSTALL_DIR}/server/Binaries/Linux"
./UDKGameServer-Linux aocffa-moor_p\?steamsockets\?adminpassword=${ADMINPASSWORD}\?port=7000\?queryport=7010 -seekfreeloadingserver
