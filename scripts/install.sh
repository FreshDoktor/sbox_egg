#!/bin/bash
# ============================================================
#  s&box Dedicated Server — Install Script (aus egg-sbox.json)
#  Laeuft im Installer-Container (ghcr.io/parkervcp/installers:debian)
#  als root. Zielverzeichnis: /mnt/server
# ============================================================

apt-get update
apt-get install -y --no-install-recommends curl lib32gcc-s1 lib32stdc++6

mkdir -p /mnt/server
mkdir -p /opt/steamcmd

curl -sqL https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz | tar -xzvf - -C /opt/steamcmd

BRANCH_ARG=""
if [ -n "${SBOX_BRANCH}" ]; then
    BRANCH_ARG="-beta ${SBOX_BRANCH}"
fi

/opt/steamcmd/steamcmd.sh +force_install_dir /mnt/server \
    +login anonymous \
    +app_update 1892930 ${BRANCH_ARG} validate \
    +quit

chown -R 999:999 /mnt/server
