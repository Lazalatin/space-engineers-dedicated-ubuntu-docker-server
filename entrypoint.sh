#!/bin/bash
# Licenced under the MIT from Johan Bregell, and adapted.
# Find the original here:
# https://github.com/bregell/docker_space_engineers_server/blob/38c7d3d8f2b6bdbfcfb45f84b3b2df1c128eb99f/entrypoint.sh

set -eo pipefail

mkdir -p "${CONFIG}"/{Saves,Mods,Updater}
if [[ -d "${WORK}"/"${WORLD_NAME}" ]]; then
  cp -r --reflink=auto --no-preserve=ownership \
    "${WORK}"/"${WORLD_NAME}" "${CONFIG}"/Saves/
fi

if [[ ! -s "${CONFIG}"/SpaceEngineers-Dedicated.cfg ]]; then
  # Upsert a default configuration with sane defaults for this containerized environment.
  : ${WORLD_SAVE_WINE_PATH:="C:\\\users\\\root\\\AppData\\\Roaming\\\SpaceEngineersDedicated\\\Saves\\"}
  : ${PREMADE_WINE_PATH:="C:\\\space-engineers-server\\\Content\\\CustomWorlds\\\Star System"}

  declare -A defaults=(
    [SteamPort]="${STEAM_PORT}"
    [ServerPort]="${SERVER_PORT}"
    [RemoteApiPort]="${REMOTE_API_PORT}"
    [RemoteSecurityKey]="${REMOTE_SECURITY_KEY}"
    [ServerName]="${SERVER_NAME}"
    [WorldName]="${WORLD_NAME}"
    [LoadWorld]="${WORLD_SAVE_WINE_PATH}\\${WORLD_NAME}"
    [PremadeCheckpointPath]="${PREMADE_WINE_PATH}"
  )
  modifications=()
  for tag in "${!defaults[@]}"; do
    modifications+=("-e" "s=<${tag}>.*</${tag}>=<${tag}>${defaults[$tag]}</${tag}>=g")
  done

  </home/root/SpaceEngineers-Dedicated.cfg sed "${modifications[@]}" >"${CONFIG}"/SpaceEngineers-Dedicated.cfg
fi

steamcmd \
  +login anonymous \
  +force_install_dir "${WORK}" \
  +app_update 298740 \
  +quit

# Allow for a different IP in case the operator runs this image with "--net=host"
# on a multi-homed server, or multiple instances of this game.
: ${SERVER_IP:="0.0.0.0"}

exec wine64 \
  C:\\SpaceEngineersDedicatedServer\\DedicatedServer64\\SpaceEngineersDedicated.exe \
  -noconsole -ignorelastsession \
  -ip "${SERVER_IP}" -path "$(winepath -w -0 "${CONFIG}")"
