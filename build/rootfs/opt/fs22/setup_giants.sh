#!/bin/bash

export WINEDLLOVERRIDES=mscoree=d
export WINEDEBUG=-all
export WINEPREFIX=~/apps/fs25-server
export WINEARCH=win64
export USER=nobody

# Debug info/warning/error color

NOCOLOR='\033[0;0m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'

# Create a clean 64bit Wineprefix

if [ -d ~/apps/fs25-server ]
then
    rm -r ~/apps/fs25-server && wine wineboot
else
wine wineboot
fi

if [ -d /opt/fs25/config/FarmingSimulator2025 ]
then
    echo -e "${GREEN}INFO: The host config directory exists, no need to create it!${NOCOLOR}"
else
mkdir -p /opt/fs25/config/FarmingSimulator2025

fi

# it's important to check if the game directory exists on the host mount path. If it doesn't exist, create it.

if [ -d /opt/fs25/game/Farming\ Simulator\ 2025 ]
then
    echo -e "${GREEN}INFO: The host game directory exists, no need to create it!${NOCOLOR}"
else
mkdir -p /opt/fs25/game/Farming\ Simulator\ 2025

fi

# Symlink the host game path inside the wine prefix to preserve the installation on image deletion or update.


if [ -d /opt/fs25/game/Farming\ Simulator\ 2025 ]
then
    ln -s /opt/fs25/game/Farming\ Simulator\ 2025 ~/apps/fs25-server/drive_c/Program\ Files\ \(x86\)/Farming\ Simulator\ 2025
else
echo -e "${RED}Error: There is a problem... the host game directory does not exist, unable to create the symlink, the installation has failed!${NOCOLOR}"

fi

# Symlink the host config path inside the wine prefix to preserver the config files on image deletion or update.

if [ -d ~/apps/fs25-server/drive_c/users/$USER/Documents/My\ Games/FarmingSimulator2025 ]
then
    echo -e "${GREEN}INFO: The symlink is already in place, no need to create one!${NOCOLOR}"
else
mkdir -p ~/apps/fs25-server/drive_c/users/$USER/Documents/My\ Games && ln -s /opt/fs25/config/FarmingSimulator2025 ~/apps/fs25-server/drive_c/users/$USER/Documents/My\ Games/FarmingSimulator2025

fi

if [ -d ~/apps/fs25-server/drive_c/users/$USER/Documents/My\ Games/FarmingSimulator2025/dedicated_server/logs ]
then
    echo -e "${GREEN}INFO: The log directories are in place!${NOCOLOR}"
else
    mkdir -p ~/apps/fs25-server/drive_c/users/$USER/Documents/My\ Games/FarmingSimulator2025/dedicated_server/logs

fi

if [ -f ~/apps/fs25-server/drive_c/Program\ Files\ \(x86\)/Farming\ Simulator\ 2025/FarmingSimulator2025.exe ]
then
    echo -e "${GREEN}INFO: Game already installed, we can skip the installer!${NOCOLOR}"
else
    wine "/opt/fs25/installer/FarmingSimulator2025.exe"
fi

# Cleanup Desktop

if [ -f ~/Desktop/ ]
then
    rm -r "~/Desktop/Farming\ Simulator\ 25\ .*"
else
    echo -e "${GREEN}INFO: Nothing to cleanup!${NOCOLOR}"
fi

# Do we have a license file installed?

count=`ls -1 ~/apps/fs25-server/drive_c/users/$USER/Documents/My\ Games/FarmingSimulator2025/*.dat 2>/dev/null | wc -l`
if [ $count != 0 ]
then
    echo -e "${GREEN}INFO: Generating the game license files as needed!${NOCOLOR}"
else
    wine ~/apps/fs25-server/drive_c/Program\ Files\ \(x86\)/Farming\ Simulator\ 2025/FarmingSimulator2025.exe
fi

count=`ls -1 ~/apps/fs25-server/drive_c/users/$USER/Documents/My\ Games/FarmingSimulator2025/*.dat 2>/dev/null | wc -l`
if [ $count != 0 ]
then
    echo -e "${GREEN}INFO: The license files are in place!${NOCOLOR}"
else
    echo -e "${RED}ERROR: No license files detected, they are generated after you enter the cd-key during setup... most likely the setup is failing to start!${NOCOLOR}" && exit
fi

# Copy webserver config..

if [ -d ~/apps/fs25-server/drive_c/Program\ Files\ \(x86\)/Farming\ Simulator\ 2025/ ]
then
    cp "/opt/fs25/xml/default_dedicatedServer.xml" ~/apps/fs25-server/drive_c/Program\ Files\ \(x86\)/Farming\ Simulator\ 2025/dedicatedServer.xml
else
    echo -e "${RED}ERROR: Game is not installed?${NOCOLOR}" && exit
fi

# Copy server config

if [ -d ~/apps/fs25-server/drive_c/users/$USER/Documents/My\ Games/FarmingSimulator2025/ ]
then
    cp "/opt/fs25/xml/default_dedicatedServerConfig.xml" ~/apps/fs25-server/drive_c/users/$USER/Documents/My\ Games/FarmingSimulator2025/dedicated_server/dedicatedServerConfig.xml
else
    echo -e "${RED}ERROR: Game didn't start for first time, no directories?${NOCOLOR}" && exit
fi


echo -e "${YELLOW}INFO: Checking for updates, if you get warning about gpu drivers make sure to click no!${NOCOLOR}"
wine ~/apps/fs25-server/drive_c/Program\ Files\ \(x86\)/Farming\ Simulator\ 2025/FarmingSimulator2025.exe

# Check config if not exist exit

if [ -f ~/apps/fs25-server/drive_c/users/$USER/Documents/My\ Games/FarmingSimulator2025/dedicated_server/dedicatedServerConfig.xml ]
then
    echo -e "${GREEN}INFO: We can run the server now by clicking on 'Start Server' on the desktop!${NOCOLOR}"
else
    echo -e "${RED}ERROR: We are missing files?${NOCOLOR}" && exit
fi

# Lets purge the logs so we won't have errors/warnings at server start...

if [ -f ~/apps/fs25-server/drive_c/users/$USER/Documents/My\ Games/FarmingSimulator2025/dedicated_server/logs/server.log ]
then
    rm ~/apps/fs25-server/drive_c/users/$USER/Documents/My\ Games/FarmingSimulator2025/dedicated_server/logs/server.log && touch ~/apps/fs25-server/drive_c/users/$USER/Documents/My\ Games/FarmingSimulator2025/dedicated_server/logs/server.log
else
    touch ~/apps/fs25-server/drive_c/users/$USER/Documents/My\ Games/FarmingSimulator2025/dedicated_server/logs/server.log
fi

if [ -f ~/apps/fs25-server/drive_c/users/$USER/Documents/My\ Games/FarmingSimulator2025/dedicated_server/logs/webserver.log ]
then
    rm ~/apps/fs25-server/drive_c/users/$USER/Documents/My\ Games/FarmingSimulator2025/dedicated_server/logs/webserver.log && touch ~/apps/fs25-server/drive_c/users/$USER/Documents/My\ Games/FarmingSimulator2025/dedicated_server/logs/webserver.log
else
    touch ~/apps/fs25-server/drive_c/users/$USER/Documents/My\ Games/FarmingSimulator2025/dedicated_server/logs/webserver.log
fi

if [ -f ~/apps/fs25-server/drive_c/users/$USER/Documents/My\ Games/FarmingSimulator2025/log.txt ]
then
    rm ~/apps/fs25-server/drive_c/users/$USER/Documents/My\ Games/FarmingSimulator2025/log.txt && touch ~/apps/fs25-server/drive_c/users/$USER/Documents/My\ Games/FarmingSimulator2025/log.txt
else
    touch ~/apps/fs25-server/drive_c/users/$USER/Documents/My\ Games/FarmingSimulator2025/log.txt
fi


echo -e "${YELLOW}INFO: Checking for updates, if you get warning about gpu drivers make sure to click no!${NOCOLOR}"
wine ~/apps/fs25-server/drive_c/Program\ Files\ \(x86\)/Farming\ Simulator\ 2025/FarmingSimulator2025.exe

echo -e "${YELLOW}INFO: All done, closing this window in 20 seconds...${NOCOLOR}"

exec sleep 20
