#!/bin/bash
# Licenced under the MIT from Johan Bregell, and adapted.
# Find the original here:
# https://github.com/bregell/docker_space_engineers_server/blob/38c7d3d8f2b6bdbfcfb45f84b3b2df1c128eb99f/entrypoint.sh

set -eu

mkdir -p "${WORK}"
mkdir -p "${CONFIG}"

mkdir -p "${CONFIG}"/Saves
mkdir -p "${CONFIG}"/Mods
mkdir -p "${CONFIG}"/Updater

if [[ -d "${WORK}"/"${WORLD_NAME}" ]]; then
  # Copy save to save location
  cp -r "${WORK}"/"${WORLD_NAME}" "${CONFIG}"/Saves/
  chown -R root:root "${CONFIG}"/Saves/"${WORLD_NAME}"
fi

if [[ ! -s "${CONFIG}"/SpaceEngineers-Dedicated.cfg ]]; then
  cp /home/root/SpaceEngineers-Dedicated.cfg "${CONFIG}"/

  : ${WORLD_SAVE_WINE_PATH:="C:\\\users\\\root\\\AppData\\\Roaming\\\SpaceEngineersDedicated\\\Saves\\"}
  : ${PREMADE_WINE_PATH:="C:\\\space-engineers-server\\\Content\\\CustomWorlds\\\Star System"}

  sed -i \
    -e "s=<SteamPort>.*</SteamPort>=<SteamPort>${STEAM_PORT}</SteamPort>=g" \
    -e "s=<ServerPort>.*</ServerPort>=<ServerPort>${SERVER_PORT}</ServerPort>=g" \
    -e "s=<RemoteApiPort>.*</RemoteApiPort>=<RemoteApiPort>${REMOTE_API_PORT}</RemoteApiPort>=g" \
    -e "s=<RemoteSecurityKey>.*</RemoteSecurityKey>=<RemoteSecurityKey>${REMOTE_SECURITY_KEY}</RemoteSecurityKey>=g" \
    -e "s=<ServerName>.*</ServerName>=<ServerName>${SERVER_NAME}</ServerName>=g" \
    -e "s=<WorldName>.*</WorldName>=<WorldName>${WORLD_NAME}</WorldName>=g" \
    -e "s=<LoadWorld>.*</LoadWorld>=<LoadWorld>${WORLD_SAVE_WINE_PATH}\\${WORLD_NAME}</LoadWorld>=g" \
    -e "s=<PremadeCheckpointPath>.*</PremadeCheckpointPath>=<PremadeCheckpointPath>${PREMADE_WINE_PATH}</PremadeCheckpointPath>=g" \
    "${CONFIG}"/SpaceEngineers-Dedicated.cfg
fi

steamcmd \
  +login anonymous \
  +force_install_dir "${WORK}" \
  +app_update 298740 \
  +quit

export CONFIG_WINE_PATH="$(winepath -w -0 "${CONFIG}")"

exec wine64 \
  C:\\SpaceEngineersDedicatedServer\\DedicatedServer64\\SpaceEngineersDedicated.exe \
  -noconsole \
  -ip 0.0.0.0 \
  -ignorelastsession \
  -path "${CONFIG_WINE_PATH}"
