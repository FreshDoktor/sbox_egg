#!/bin/bash
cd /home/container

# SteamCMD Permissions fix (Pelican volume mount can reset these)
chmod +x /opt/steamcmd/steamcmd.sh 2>/dev/null
chmod +x /opt/steamcmd/linux32/steamcmd 2>/dev/null

# SteamCMD Update
if [ "${SBOX_AUTO_UPDATE}" = "1" ]; then
    /opt/steamcmd/steamcmd.sh +force_install_dir /home/container \
        +login anonymous \
        +app_update 1892930 validate \
        +quit
fi

# Pelican STARTUP override
if [ -n "${STARTUP}" ]; then
    eval "${STARTUP}"
else
    exec bash sbox-server.sh
fi
