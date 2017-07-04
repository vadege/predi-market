FROM jshimko/meteor-launchpad:latest
MAINTAINER Kjetil Thuen

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -y graphicsmagick
