FROM ubuntu:18.04 as preStage
MAINTAINER Lazalatin <lazalatin@tutamail.com>

RUN set -x
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies needed for installation and using PPAs and Locales
RUN apt-get update && \
    apt-get install --no-install-recommends --no-install-suggests -y apt-utils wget xvfb software-properties-common \
        apt-transport-https gnupg lib32stdc++6 lib32gcc1 ca-certificates sed xvfb locales && \
    localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

# Clean Apt Data
RUN apt-get clean autoclean \
    	&& apt-get autoremove -y \
    	&& rm -rf /var/lib/{apt,dpkg,cache,log}/



FROM preStage as wineStage
#### PREPARE WINE ENVIRONMENT FOR SPACE ENGINEERS DEDICATED SERVER ####
ENV WINEARCH=win64
# Initalize winetricks script and additional dependencies
ADD resources/install_winetricks.sh /root/install_winetricks.sh
RUN apt-get install --no-install-recommends --no-install-suggests -y cabextract apt-transport-https samba && \
    bash /root/install_winetricks.sh && rm /root/install_winetricks.sh

# Initialize repositories for wine and install it
RUN dpkg --add-architecture i386 && \
    wget -nc https://dl.winehq.org/wine-builds/winehq.key && \
    apt-key add winehq.key && rm winehq.key && \
    apt-add-repository https://dl.winehq.org/wine-builds/ubuntu/ && \
    add-apt-repository ppa:cybermax-dexter/sdl2-backport
RUN apt-get update && \
    apt-get install --no-install-recommends --no-install-suggests -y \
        winehq-devel wine-devel wine-devel-i386 wine-devel-amd64

# Cleanup .wine folder (in case a default prefix got accidentially created)
# Prepare new 64-bit prefix and install dotNet472 and vcrun2017
# This one-liner is necessary because wineserver must be started via wineboot in order to use winetricks
RUN rm -rf /root/.wine && env WINEDLLOVERRIDES="mscoree,mshtml=" wineboot --init && \
    xvfb-run winetricks --unattended vcrun2013 vcrun2017
RUN wineboot --init && winetricks --unattended dotnet472 corefonts dxvk

# Make Wine quiet(er)
# Only err: messages will be shown
ENV WINEDEBUG=fixme-all

# Clean Apt Data
RUN apt-get clean autoclean \
    	&& apt-get autoremove -y \
    	&& rm -rf /var/lib/{apt,dpkg,cache,log}/



FROM wineStage as setupStage
#### PREPARE ALL ENVIRONMENT DEFAULTS FOR USAGE WITH DOCKER COMPOSE ####
# The following part was gladly adapted and extended
# from https://github.com/bregell/docker_space_engineers_server/blob/38c7d3d8f2b6bdbfcfb45f84b3b2df1c128eb99f/Dockerfile
# Licenced under MIT by Johan Bregell
ENV WORK "/mnt/root/space-engineers-server"
ENV CONFIG "/mnt/root/space-engineers-server/config"
ENV SERVER_NAME DockerDedicated
ENV WORLD_NAME DockerWorld
ENV STEAM_PORT 8766
ENV SERVER_PORT 27016
ENV REMOTE_CLIENT_PORT 8080

RUN mkdir -p ${WORK}
RUN mkdir -p ${CONFIG}
WORKDIR /home/root
COPY entrypoint.sh /entrypoint.sh
COPY resources/SpaceEngineers-Dedicated.cfg /home/root/SpaceEngineers-Dedicated.cfg
RUN chmod +x /entrypoint.sh

WORKDIR ${WORK}
ENTRYPOINT ["/entrypoint.sh"]

VOLUME ${WORK}

EXPOSE ${STEAM_PORT}/udp
EXPOSE ${SERVER_PORT}/udp
EXPOSE ${REMOTE_CLIENT_PORT}/tcp