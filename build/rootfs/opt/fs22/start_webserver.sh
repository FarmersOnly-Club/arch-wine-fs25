#!/bin/bash

export WINEDEBUG=-all
export WINEPREFIX=~/apps/fs25-server


# Start the server

if [ -f ~/apps/fs25-server/drive_c/Program\ Files\ \(x86\)/Farming\ Simulator\ 2025/dedicatedServer.exe ]
then
    wine ~/apps/fs25-server/drive_c/Program\ Files\ \(x86\)/Farming\ Simulator\ 2025/dedicatedServer.exe
else
    echo "Game not installed?" && exit
fi

exit 0
