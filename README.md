# Chivalry: "Medieval Warfare" docker for the native linux server

## Cookbook 

* create docker volume on host (/opt/chivalry in example below)
* add liberal r/w at least for uid=1000, gid=999 (user "steam" inside container)
* docker build -t chivalry_server .
* docker run --rm -ti -v /opt/chivalry:/opt/chivalry -p 0.0.0.0:8000:8000/udp -p 0.0.0.0:27015:27015/udp --name chivalry -t chivalry_server update
  * Update or install steamcmd and game files in volume
* docker run --rm -ti -v /opt/chivalry:/opt/chivalry -p 0.0.0.0:8000:8000/udp -p 0.0.0.0:27015:27015/udp --name chivalry -t chivalry_server newconfig game
  * create a new config subdirectry
* Customize settings as you see fit in the config subdirectory
* docker run --rm -ti -v /opt/chivalry:/opt/chivalry -p 0.0.0.0:8000:8000/udp -p 0.0.0.0:27015:27015/udp --name chivalry -t chivalry_server run game
  * run the game using the settings in the config subdirectory

## Features / tested with
* defaults to Black Knight Mod
* easily manage separate config subdirectories
* works with mod LSMOD, Blackknight, giantslayers
* most maps (hoth excluded)
* game.ini can be changed reliable
* mods / workshop items can be changed reliable

## known issues
* scripts can be optimized
* no restart if the server has a coredump


## Thanks

* thpeng
* fingerland-asso
