FROM lsiobase/ubuntu:bionic as buildstage

ARG COMPOSE_VERSION

RUN \
 echo "**** install packages ****" && \
 apt-get update && \
 apt-get install -y \
	git \
	libffi-dev \
	python3 \
	python3-dev \
	python3-pip \
	zlib1g-dev

RUN \
 echo "**** build compose ****" && \
 cd /tmp && \
 if [ -z ${COMPOSE_VERSION+x} ]; then \
	COMPOSE_VERSION=$(curl -sX GET "https://api.github.com/repos/docker/compose/releases/latest" \
	| awk '/tag_name/{print $4;exit}' FS='[""]'); \
 fi && \
 git clone https://github.com/docker/compose.git && \
 cd compose && \
 git checkout ${COMPOSE_VERSION} && \
 pip3 install \
	pyinstaller && \
 pip3 install \
	-r requirements.txt \
	-r requirements-build.txt && \
 ./script/build/write-git-sha > compose/GITSHA && \
 pyinstaller docker-compose.spec && \
 mv dist/docker-compose /

# runtime stage
FROM lsiobase/cloud9:latest

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="thelamer"

# Docker compose
COPY --from=buildstage /docker-compose /usr/local/bin/

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
