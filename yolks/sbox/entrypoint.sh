#!/bin/bash
cd /home/container

mkdir -p download/assets/models
mkdir -p config/convar

# Set TTY window size so Console.WindowWidth doesn't return -1 in .NET.
# s&box crashes with ArgumentOutOfRangeException if no window size is set
# on the PTY (Pelican allocates a TTY but doesn't set dimensions).
stty cols 120 rows 30 2>/dev/null || true

# Prevent s&box from using cursor-up/carriage-return sequences to update
# stats in-place. With TERM=dumb, .NET skips VT100 sequences; PTY dimensions
# set above via stty are unaffected (kernel-level, independent of TERM).
export TERM=dumb

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
if [ -n "${TOKEN:-}" ]; then
    STARTUP="${STARTUP} +net_game_server_token ${TOKEN}"
fi
if [ -n "${QUERY_PORT:-}" ]; then
    STARTUP="${STARTUP} +net_query_port ${QUERY_PORT}"
fi

# Pelican STARTUP override
if [ -n "${STARTUP}" ]; then
    exec bash -c "${STARTUP}"
else
    exec bash sbox-server.sh
fi
