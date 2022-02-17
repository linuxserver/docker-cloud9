FROM ghcr.io/linuxserver/baseimage-cloud9:latest

# set version label
ARG BUILD_DATE
ARG VERSION
ARG GO_VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="thelamer"

# Env 
ENV GOPATH=$HOME/work
ENV PATH=$PATH:/usr/local/go/bin:$GOPATH/bin

RUN \
 echo "**** install Golang ****" && \
 if [ -z ${GO_VERSION+x} ]; then \
        GO_VERSION=$(curl -sL https://go.dev/dl/ \
	| awk -F '(go|.linux-amd64.tar.gz)' '/linux-amd64.tar.gz/ {print $2;exit}'); \
 fi && \
 apt-get update && \
 apt-get install -y \
	build-essential && \
 curl -o \
	/tmp/go.tar.gz -L \
	https://go.dev/dl/go"${GO_VERSION}".linux-amd64.tar.gz && \
 cd /tmp && \
 tar xf \
	go.tar.gz && \
 chown -R root:root ./go && \
 mv go /usr/local && \
 echo "**** cleanup ****" && \
 apt-get autoclean && \
 rm -rf \
	/var/lib/apt/lists/* \
	/var/tmp/* \
	/tmp/*
