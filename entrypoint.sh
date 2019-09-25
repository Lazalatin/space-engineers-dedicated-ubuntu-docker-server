#!/bin/bash
# entrypoint.sh gladly taken
# from https://github.com/bregell/docker_space_engineers_server/blob/38c7d3d8f2b6bdbfcfb45f84b3b2df1c128eb99f/entrypoint.sh
# Licenced under MIT by Johan Bregell

set -x

if [ ! -d "${WORK}" ]; then
  # Setup folder for steamcmd data
  mkdir -p "${WORK}"
fi

if [ ! -d "${CONFIG}" ]; then
  # Setup folder for space engineers data
  mkdir -p "${CONFIG}"
fi

if [ ! -d "${CONFIG}"/Saves ]; then
  # Setup folder for saves
  mkdir -p "${CONFIG}"/Saves
fi

if [ ! -d "${CONFIG}"/Mods ]; then
  # Setup folder for mods
  mkdir -p "${CONFIG}"/Mods
fi

if [ ! -d "${CONFIG}"/Updater ]; then
  # Setup folder for updater
  mkdir -p "${CONFIG}"/Updater
fi

if [ -d "${WORK}"/"${WORLD_NAME}" ]; then
  # Copy save to save location
  cp -r "${WORK}"/"${WORLD_NAME}" "${CONFIG}"/Saves/
  chown -R root:root "${CONFIG}"/Saves/"${WORLD_NAME}"
fi

if [ ! -f "${CONFIG}"/SpaceEngineers-Dedicated.cfg ]; then
  # Copy standard config file to correct location
  cp /home/root/SpaceEngineers-Dedicated.cfg "${CONFIG}"/

  # Change ports
  sed -i "s=<SteamPort>.*</SteamPort>=<SteamPort>${STEAM_PORT}</SteamPort>=g" ${CONFIG}/SpaceEngineers-Dedicated.cfg
  sed -i "s=<ServerPort>.*</ServerPort>=<ServerPort>${SERVER_PORT}</ServerPort>=g" ${CONFIG}/SpaceEngineers-Dedicated.cfg
  sed -i "s=<RemoteApiPort>.*</RemoteApiPort>=<RemoteApiPortPort>${REMOTE_API_PORT}</RemoteApiPort>=g" ${CONFIG}/SpaceEngineers-Dedicated.cfg

  # Change save path to value from config
  sed -i "s=<ServerName>.*</ServerName>=<ServerName>${SERVER_NAME}</ServerName>=g" ${CONFIG}/SpaceEngineers-Dedicated.cfg
  sed -i "s=<WorldName>.*</WorldName>=<WorldName>${WORLD_NAME}</WorldName>=g" ${CONFIG}/SpaceEngineers-Dedicated.cfg
  export WORLD_SAVE_WINE_PATH="C:\\\users\\\root\\\AppData\\\Roaming\\\SpaceEngineersDedicated\\\Saves\\"
  sed -i "s=<LoadWorld>.*</LoadWorld>=<LoadWorld>${WORLD_SAVE_WINE_PATH}\\${WORLD_NAME}</LoadWorld>=g" ${CONFIG}/SpaceEngineers-Dedicated.cfg
  export PREMADE_WINE_PATH="C:\\\space-engineers-server\\\Content\\\CustomWorlds\\\Star System"
  sed -i "s=<PremadeCheckpointPath>.*</PremadeCheckpointPath>=<PremadeCheckpointPath>${PREMADE_WINE_PATH}</PremadeCheckpointPath>=g" ${CONFIG}/SpaceEngineers-Dedicated.cfg
fi

steamcmd +login anonymous +force_install_dir ${WORK} +app_update 298740 +quit
CONFIG_WINE_PATH="$(winepath -w -0 ${CONFIG})"
export CONFIG_WINE_PATH
wine64 C:\\SpaceEngineersDedicatedServer\\DedicatedServer64\\SpaceEngineersDedicated.exe -noconsole -ip 0.0.0.0 -ignorelastsession -path ${CONFIG_WINE_PATH}
