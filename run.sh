#!/usr/bin/env bash

function usage {
    echo "Accepted parameters:"
    echo -e " update\t\t\t- update (or install) steamcmd and game data"
    echo -e " newconfig <configname>\t- create new configsubdir in <volume>/config"
    echo -e " run <configname>\t- run server using configsubdir"
    exit
}

function install-steamcmd {
    echo "Downloading and unpacking steamcmd"
    mkdir -p "/opt/chivalry/steamcmd"
    cd "/opt/chivalry/steamcmd"
    curl -Ss http://media.steampowered.com/installer/steamcmd_linux.tar.gz | tar -xz
}

function install-chivalry {
    echo "Updating/Installing game files"
    "/opt/chivalry/steamcmd/steamcmd.sh" +login anonymous +force_install_dir "/opt/chivalry/server" +app_update 220070 +quit
    if [ ! -L "/opt/chivalry/server/Binaries/Linux/lib/steamclient.so" ]; then
        ln -s "/opt/chivalry/steamcmd/linux32/steamclient.so" "/opt/chivalry/server/Binaries/Linux/lib/steamclient.so"
    fi

    if [ ! -f "/opt/chivalry/server/Binaries/Linux/steam_appid.txt" ]; then
        echo "219640" > "/opt/chivalry/server/Binaries/Linux/steam_appid.txt"
    fi
}

function pristine-config {
    if [ ! -d "/opt/chivalry/config/pristine" ]; then
        echo "Creating the <volume>/config directory with a pristine copy of the default config"
        mkdir -p "/opt/chivalry/config"
        cp -r /opt/chivalry/server/UDKGame/Config /opt/chivalry/config/pristine
    fi
}

function new-config {
    if [ ! -d "/opt/chivalry/config/$1" ]; then
        cp -r /opt/chivalry/config/pristine "/opt/chivalry/config/$1"
        ln -s "/opt/chivalry/config/$1" "/opt/chivalry/server/UDKGame/Config/$1"
        # use the predefined ini in order to configure the server
        cp /usr/local/bin/PCServer-UDKGame.ini "/opt/chivalry/config/$1/PCServer-UDKGame.ini"
        echo "Customise server config before running: <volume>/config/$1/PCServer-UDKGame.ini"
    else
        echo "$1 already exists"
    fi
}

##################################### Main #####################################

MODE="$1"
CONFIG="$2"

case $MODE in
update)
  if [ $# -ne 1 ]; 
    then usage
  fi
  echo "Update (or install) steamcmd and game data"
  install-steamcmd
  install-chivalry
  ;;
newconfig)
  if [ $# -ne 2 ]; 
    then usage
  fi
  echo "Creating new configsubdir: <volume>/config/$CONFIG"
  pristine-config
  new-config "$CONFIG"
  ;;
run)
  if [ $# -ne 2 ]; 
    then usage
  fi
  echo "Running server using config from <volume>/config/$CONFIG"
  # link the gamefile created in .local to volume one. else the downloaded maps are not accessible
  # this seems to be important also for black knight mod
  # move this to Dockerfile?
  [ ! -L "/home/steam/.local/share/TornBanner/Chivalry/UDKGame" ] && mkdir -p "/home/steam/.local/share/TornBanner/Chivalry" && ln -s /opt/chivalry/server/UDKGame /home/steam/.local/share/TornBanner/Chivalry/UDKGame
  #add libraries to env
  export LD_LIBRARY_PATH=/opt/chivalry/server/linux64:/opt/chivalry/server/Binaries/Linux/lib
  cd "/opt/chivalry/server/Binaries/Linux"
  #launch
  ./UDKGameServer-Linux AOCLTS-Arena3_p\?steamsockets\?Port=8000\?QueryPort=27015\?adminpassword=erased\?password=erased\?modname=BlackKnight -sdkfileid=232823090 -configsubdir="$CONFIG" -seekfreeloadingserver
  ;;
*)
  usage
  ;;
esac
