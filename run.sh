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



##################################### ENVS #####################################

if [[ -z $CHIV_PORT ]] || [[ $CHIV_PORT -lt 1024 ]] || [[ $CHIV_PORT -gt 65534 ]] ; then
  echo "CHIV_PORT is not set or within invalid port range, defaulting to 8000"
  PORT="8000"
else
  PORT=$CHIV_PORT
fi

if [[ -z $CHIV_QPORT ]] || [[ $CHIV_QPORT -lt 1024 ]] || [[ $CHIV_QPORT -gt 65534 ]] ; then
  echo "CHIV_QPORT is not set or within invalid port range, defaulting to 27015"
  QPORT="27105"
else
  QPORT=$CHIV_QPORT
fi

if [[ -z $CHIV_STARTMAP ]]; then
  echo "CHIV_STARTMAP not set, defaulting to AOCFFA-Dininghall_p"
  STARTMAP="AOCFFA-Dininghall_p"
else
  STARTMAP=$CHIV_STARTMAP
fi

if [[ -z $CHIV_MODNAME ]]; then
  echo "CHIV_MODNAME not set, game will start without initial mod"
  INITIAL_MOD_NAME=""
else
  INITIAL_MOD_NAME="\?modname=$CHIV_MODNAME"
fi

MODE="$1"
CONFIG="$2"

echo "Port is $PORT"
echo "QPort is $QPORT"
echo "Start map is $STARTMAP"
echo "Starting mod name (if set) is $INITIAL_MOD_NAME"


##################################### Main #####################################

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
  ./UDKGameServer-Linux $STARTMAP\?steamsockets\?Port=$PORT\?QueryPort=$QPORT\?adminpassword=erased\?password=erased -sdkfileid=232823090 -configsubdir="$CONFIG" -seekfreeloadingserver < <(sleep 999999999)
  ;;
*)
  usage
  ;;
esac
