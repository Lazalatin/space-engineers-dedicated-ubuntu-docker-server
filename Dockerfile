FROM ubuntu:18.04 as preStage
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies needed for installation and using PPAs and Locales
RUN apt-get -q update && \
    apt-get --no-install-recommends --no-install-suggests -y install \
        apt-utils apt-transport-https ca-certificates \
        software-properties-common gnupg \
        lib32stdc++6 lib32gcc1 \
        sed wget xvfb locales cabextract \
        && \
    localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 && \
    export LANG=en_US.UTF-8 && \
    apt-get clean autoclean && apt-get -y autoremove && rm -rf /var/lib/{apt,dpkg,cache,log}/

FROM preStage as wineStage
ENV WINEARCH=win64 WINEDEBUG=fixme-all

RUN (cd /usr/bin; \
        wget "https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks") && \
    chmod a+x /usr/bin/winetricks && \
    (cd /usr/share/bash-completion/completions; \
        wget "https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks.bash-completion")

RUN dpkg --add-architecture i386 && \
    wget -nc https://dl.winehq.org/wine-builds/winehq.key && \
    apt-key add winehq.key && rm winehq.key && \
    add-apt-repository https://dl.winehq.org/wine-builds/ubuntu/ && \
    add-apt-repository ppa:cybermax-dexter/sdl2-backport && \
    apt-get -q update && \
    apt-get --no-install-recommends --no-install-suggests -y install \
        winehq-devel wine-devel wine-devel-i386 wine-devel-amd64 \
        && \
    rm -rf /root/.wine && \
    env WINEDLLOVERRIDES="mscoree,mshtml=" wineboot --init && \
    xvfb-run winetricks --unattended vcrun2013 vcrun2017 && \
    wineboot --init && \
    winetricks --unattended dotnet472 corefonts dxvk && \
    apt-get clean autoclean && apt-get autoremove -y && rm -rf /var/lib/{apt,dpkg,cache,log}/

FROM wineStage as steamStage
# Install steamcmd and clear apts caches
# Link steamcmd binary to /usr/bin to use it in PATH
RUN echo steam steam/question select "I AGREE" | debconf-set-selections && \
    apt-get -q update && \
    apt-get -y install \
        steamcmd:i386 \
        winbind \
        && \
    ln -s /usr/games/steamcmd /usr/bin/steamcmd && \
    apt-get clean autoclean && apt-get autoremove -y && rm -rf /var/lib/{apt,dpkg,cache,log}/

FROM steamStage as setupStage
#### PREPARE ALL ENVIRONMENT DEFAULTS FOR USAGE WITH DOCKER COMPOSE ####
# The following part was gladly adapted and extended
# from https://github.com/bregell/docker_space_engineers_server/blob/38c7d3d8f2b6bdbfcfb45f84b3b2df1c128eb99f/Dockerfile
# Licenced under MIT by Johan Bregell
ENV WORK="/root/.wine/drive_c/SpaceEngineersDedicatedServer" \
    CONFIG="/root/.wine/drive_c/users/root/AppData/Roaming/SpaceEngineersDedicated" \
    SERVER_NAME=DockerDedicated \
    WORLD_NAME=DockerWorld \
    STEAM_PORT=8766 \
    SERVER_PORT=27016 \
    REMOTE_API_PORT=8080

COPY entrypoint.sh /entrypoint.sh
COPY resources/SpaceEngineers-Dedicated.cfg /home/root/SpaceEngineers-Dedicated.cfg

RUN mkdir -p "${WORK}" && \
    mkdir -p "${CONFIG}" && \
    chmod +x /entrypoint.sh

VOLUME ${WORK}
WORKDIR ${WORK}
ENTRYPOINT ["/entrypoint.sh"]
EXPOSE ${STEAM_PORT}/udp ${SERVER_PORT}/udp ${REMOTE_API_PORT}/tcp
