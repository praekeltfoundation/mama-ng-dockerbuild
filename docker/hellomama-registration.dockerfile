FROM mama-ng-run
MAINTAINER Praekelt Foundation <dev@praekeltfoundation.org>

RUN apt-get update \
    && $APT_GET_INSTALL libpq5 \
    && rm -rf /var/lib/apt/lists/*

ADD build/hellomama-registration-static /app/static

RUN $PIP_INSTALL hellomama-registration
