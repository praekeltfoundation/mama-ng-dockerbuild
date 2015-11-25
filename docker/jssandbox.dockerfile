FROM mama-ng-run
MAINTAINER Praekelt Foundation <dev@praekeltfoundation.org>

RUN apt-get update \
    && $APT_GET_INSTALL nodejs \
    && rm -rf /var/lib/apt/lists/*

ENV NODE_PATH=/node_modules

ADD build/node_modules /node_modules

RUN $PIP_INSTALL vxsandbox
