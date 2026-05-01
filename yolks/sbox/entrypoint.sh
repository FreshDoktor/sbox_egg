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

# LD_LIBRARY_PATH for s&box native libs
export LD_LIBRARY_PATH="$(pwd)/bin/linuxsteamrt64:${LD_LIBRARY_PATH}"

# Server starten
ARGS="+hostname \"${SERVER_NAME:-s&box Server}\""
[ -n "${GAME}" ] && ARGS="+game ${GAME} ${ARGS}"
[ -n "${MAP}" ] && ARGS="+game ${GAME} ${MAP} ${ARGS}"
[ -n "${TOKEN}" ] && ARGS="${ARGS} +net_game_server_token ${TOKEN}"
[ -n "${SERVER_PORT}" ] && ARGS="${ARGS} +port ${SERVER_PORT}"
[ -n "${QUERY_PORT}" ] && ARGS="${ARGS} +net_query_port ${QUERY_PORT}"
[ -n "${MAX_PLAYERS}" ] && ARGS="${ARGS} +maxplayers ${MAX_PLAYERS}"
[ -n "${SBOX_EXTRA_ARGS}" ] && ARGS="${ARGS} ${SBOX_EXTRA_ARGS}"

# Pelican STARTUP override
if [ -n "${STARTUP}" ]; then
    eval "${STARTUP}"
else
    eval "dotnet sbox-server.dll ${ARGS}"
fi
