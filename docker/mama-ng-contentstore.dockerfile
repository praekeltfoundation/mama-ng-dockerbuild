FROM mama-ng-run
MAINTAINER Praekelt Foundation <dev@praekeltfoundation.org>

RUN apt-get update \
    && $APT_GET_INSTALL libpq5 \
    && rm -rf /var/lib/apt/lists/*

ADD build/mama-ng-contentstore-static /app/static

RUN $PIP_INSTALL mama-ng-contentstore
