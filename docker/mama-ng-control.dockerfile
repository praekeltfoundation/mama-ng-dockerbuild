FROM mama-ng-run
MAINTAINER Praekelt Foundation <dev@praekeltfoundation.org>

RUN apt-get update \
    && $APT_GET_INSTALL libpq5 \
    && rm -rf /var/lib/apt/lists/*

ADD build/mama-ng-control-static /static

RUN . /appenv/bin/activate && \
    $PIP_INSTALL mama-ng-control
