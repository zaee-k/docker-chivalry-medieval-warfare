# Chivalry: "Medieval Warfare" docker for the native linux server

## Cookbook 

* create docker volume on host (/opt/chivalry in example below)
* add liberal r/w at least for uid=1000, gid=999 (user "steam" inside container)
* docker build -t chivalry_server .
* docker run --rm -ti -v /opt/chivalry:/opt/chivalry -p 0.0.0.0:8000:8000/udp -p 0.0.0.0:27015:27015/udp --name chivalry chivalry_server update
  * Update or install steamcmd and game files in volume
* docker run --rm -ti -v /opt/chivalry:/opt/chivalry -p 0.0.0.0:8000:8000/udp -p 0.0.0.0:27015:27015/udp --name chivalry chivalry_server newconfig game
  * create a new config subdirectry
* Customize settings as you see fit in the config subdirectory
* docker run -d --restart=always -v /opt/chivalry:/opt/chivalry -p 0.0.0.0:8000:8000/udp -p 0.0.0.0:27015:27015/udp --name chivalry chivalry_server run game
  * run the game using the settings in the config subdirectory
 
## Notes
* Server name should be max 48 chars to fit Server Browser column size
* [AOC.AOCRCon]\n RConPort=27960 needs to be present in PCServer-UDKGame.ini for RCON binding
* If container cannot find Binaries/Configs, make sure the volume IS readable/writeable (caution when directory is created by root) -> good solution is to create dedicated folder like /opt/chivalry and use it as base volume 

## Features / tested with
* defaults to Black Knight Mod
* easily manage separate config subdirectories
* works with mod LSMOD, Blackknight, giantslayers
* most maps (hoth excluded)
* game.ini can be changed reliable
* mods / workshop items can be changed reliable

## known issues
* Changing container redirected ports WON'T work until it matches config ports (most likely when game server is started it informs Steam about used ports, so if they are different from docker redirected ports it will not work correctly)
* Sometimes the config files get corrupted, maybe it's something with symlinks problem
* scripts can be optimized

## TODO
* Enable passing port/queryport/rconport as env directly to run.sh script so the ports can be configured in a single "docker run ..." line

## Thanks

* thpeng
* fingerland-asso
* jjtt
