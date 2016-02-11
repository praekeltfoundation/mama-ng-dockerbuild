FROM mama-ng-run
MAINTAINER Praekelt Foundation <dev@praekeltfoundation.org>

RUN apt-get update \
    && $APT_GET_INSTALL libpq5 \
    && rm -rf /var/lib/apt/lists/*

ADD build/seed-identity-store-static /app/static

RUN $PIP_INSTALL seed-identity-store
