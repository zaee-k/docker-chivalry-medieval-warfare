#!/usr/bin/env bash

function install-steamcmd {
    echo "steamcmd not found. Installing..."
    mkdir -p "/opt/chivalry/steamcmd"
    cd "/opt/chivalry/steamcmd"
    curl -Ss http://media.steampowered.com/installer/steamcmd_linux.tar.gz | tar -xz
}

function install-chivalry {
    echo "No game files found. Installing..."
    "/opt/chivalry/steamcmd/steamcmd.sh" +login anonymous +force_install_dir "/opt/chivalry/server" +app_update 220070 +quit
    if [ ! -L "/opt/chivalry/server/Binaries/Linux/lib/steamclient.so" ]; then
        ln -s "/opt/chivalry/steamcmd/linux32/steamclient.so" "/opt/chivalry/server/Binaries/Linux/lib/steamclient.so"
    fi

    if [ ! -f "/opt/chivalry/server/Binaries/Linux/steam_appid.txt" ]; then
        echo "219640" > "/opt/chivalry/server/Binaries/Linux/steam_appid.txt"
    fi
}

##################################### Main #####################################
# we check if steamcmd is installed
[ ! -f "/opt/chivalry/steamcmd" ] && install-steamcmd
# we check if chivalry is installed or need an update
install-chivalry

[ ! -d "/opt/chivalry/config" ] && mkdir -p "/opt/chivalry/config"

cd "/opt/chivalry/config"
[ ! -L PCServer-UDKGame.ini ] && ln -s ../server/UDKGame/Config/PCServer-UDKGame.ini PCServer-UDKGame.ini


# link the gamefile created in .local to volume one. else the downloaded maps are not accessible
[ ! -L "/home/steam/.local/share/TornBanner/Chivalry/UDKGame" ] && mkdir -p "/home/steam/.local/share/TornBanner/Chivalry" && ln -s /opt/chivalry/server/UDKGame /home/steam/.local/share/TornBanner/Chivalry/UDKGame

# use the predefined ini in order to configure the server
cp /usr/local/bin/PCServer-UDKGame.ini /opt/chivalry/server/UDKGame/Config/PCServer-UDKGame.ini

#add libraries to env
export LD_LIBRARY_PATH=/opt/chivalry/server/linux64:/opt/chivalry/server/Binaries/Linux/lib
cd "/opt/chivalry/server/Binaries/Linux"
#launch
./UDKGameServer-Linux AOCFFA-Moor_p\?steamsockets\?Port=8000\?QueryPort=27015\?adminpassword=erased\?password=erased -seekfreeloadingserver
