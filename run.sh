#!/usr/bin/env bash

if [ ! -d "/chivalry/steamcmd" ]; then
    mkdir -p /chivalry/steamcmd
    cd /chivalry/steamcmd
    curl -Ss http://media.steampowered.com/installer/steamcmd_linux.tar.gz | tar -xz
fi

/chivalry/steamcmd/steamcmd.sh +login anonymous +force_install_dir /chivalry +app_update 220070 +quit

if [ ! -L "/chivalry/Binaries/Linux/lib/steamclient.so" ]; then
    ln -s /chivalry/steamclient.so /chivalry/Binaries/Linux/lib/steamclient.so
fi

if [ ! -f "/chivalry/Binaries/Linux/steam_appid.txt" ]; then
    echo "219640" > "/chivalry/Binaries/Linux/steam_appid.txt"
fi

export LD_LIBRARY_PATH=/chivalry/linux64:/chivalry/Binaries/Linux/lib
/chivalry/Binaries/Linux/UDKGameServer-Linux