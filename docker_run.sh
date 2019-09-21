#!/bin/bash

docker run --rm -p 8080:8080/tcp -p 27016:27016/udp -p 8766:8766/udp \
--volume /tmp/SpaceEngineersDedicated:/root/.wine/drive_c/users/root/AppData/Roaming/SpaceEngineersDedicated \
lazalatin/space-engineers-dedicated-ubuntu-docker-server:v1 \
wine64 '/root/.wine/drive_c/Program Files (x86)/Steam/steamapps/common/SpaceEngineersDedicatedServer/DedicatedServer64/SpaceEngineersDedicated' \
-noconsole -ip 0.0.0.0 -path 'C:\users\root\AppData\Roaming\SpaceEngineersDedicated\'
