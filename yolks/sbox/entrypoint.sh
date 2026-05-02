#!/bin/bash
cd /home/container

mkdir -p download/assets/models
mkdir -p config/convar

# Set TTY window size so Console.WindowWidth doesn't return -1 in .NET.
# s&box crashes with ArgumentOutOfRangeException if no window size is set
# on the PTY (Pelican allocates a TTY but doesn't set dimensions).
stty cols 120 rows 30 2>/dev/null || true

export TERM=xterm-256color

# SteamCMD Permissions fix (Pelican volume mount can reset these)
chmod +x /opt/steamcmd/steamcmd.sh 2>/dev/null
chmod +x /opt/steamcmd/linux32/steamcmd 2>/dev/null

# SteamCMD Update
if [ "${SBOX_AUTO_UPDATE}" = "1" ]; then
    /opt/steamcmd/steamcmd.sh +force_install_dir /home/container \
        +login anonymous \
        +app_update 1892930 ${SBOX_BRANCH:+-beta ${SBOX_BRANCH}} validate \
        +quit
fi

# Append optional args kept out of STARTUP so they stay conditional
if [ "${ENABLE_DIRECT_CONNECT:-0}" = "1" ]; then
    STARTUP="${STARTUP} +port ${SERVER_PORT} +net_hide_address 0"
fi
if [ -n "${TOKEN:-}" ]; then
    STARTUP="${STARTUP} +net_game_server_token ${TOKEN}"
fi
if [ -n "${QUERY_PORT:-}" ]; then
    STARTUP="${STARTUP} +net_query_port ${QUERY_PORT}"
fi

# Pelican STARTUP override
# Pipe through grep to suppress the periodic stats ticker lines that s&box
# outputs (Network/Physics/NavMesh/Animation/Update timings). pipefail ensures
# the server's exit code is propagated, not grep's.
if [ -n "${STARTUP}" ]; then
    exec bash -o pipefail -c "${STARTUP} 2>&1 | grep --line-buffered -Ev '(Network|Physics|NavMesh|Animation|Update)[[:space:]]+[0-9]+\.[0-9]+ms'"
else
    exec bash sbox-server.sh
fi
