FROM lsiobase/cloud9:latest

# set version label
ARG BUILD_DATE
ARG VERSION
ARG NODEJS_VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="thelamer"

RUN \
 echo "**** install nodejs and yarn ****" && \
 if [ -z ${NODEJS_VERSION+x} ]; then \
	NODEJS_VERSION=$(curl -sX GET \
	https://deb.nodesource.com/node_12.x/dists/bionic/main/binary-amd64/Packages \
	| grep -A 7 -m 1 'Package: nodejs' \
	| awk -F ': ' '/Version/{print $2;exit}'); \
 fi && \
 curl -s https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add - && \
 curl -s https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
 echo 'deb https://deb.nodesource.com/node_12.x bionic main' \
	> /etc/apt/sources.list.d/nodesource.list && \
 echo 'deb https://dl.yarnpkg.com/debian/ stable main' \
        > /etc/apt/sources.list.d/yarn.list && \
 apt-get update && \
 apt-get install -y \
	nodejs=${NODEJS_VERSION} \
	yarn && \
 echo "**** cleanup ****" && \
 apt-get autoclean && \
 rm -rf \
        /var/lib/apt/lists/* \
        /var/tmp/* \
        /tmp/*
