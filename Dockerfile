ARG COMPOSE_VERSION="latest"

# docker compose
FROM ghcr.io/linuxserver/docker-compose:amd64-${COMPOSE_VERSION} as compose

# runtime stage
FROM ghcr.io/linuxserver/baseimage-cloud9:latest

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="thelamer"

# Docker compose
COPY --from=compose /usr/local/bin/docker-compose /usr/local/bin/docker-compose

RUN \
 echo "**** install docker deps ****" && \
 curl -s \
	https://download.docker.com/linux/debian/gpg | \
	apt-key add - && \
 echo 'deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable' > \
	/etc/apt/sources.list.d/docker-ce.list && \
 apt-get update && \
 apt-get install -y --no-install-recommends \
	docker-ce && \
 echo "**** Cleanup and user perms ****" && \
 apt-get autoclean && \
 rm -rf \
	/var/lib/apt/lists/* \
	/var/tmp/* \
	/tmp/*
